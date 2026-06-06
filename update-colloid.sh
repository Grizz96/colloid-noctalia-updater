#!/bin/bash
# Optimized ping-pong icon theme switcher for Noctalia
# Changes: faster file replacement, reduced subshells, smarter caching

# Paths
COLOR_FILE="$HOME/.local/share/color-schemes/noctalia.colors"
THEME1_NAME="Noctalia-Colloid-Dark"
THEME1_PATH="$HOME/.icons/Noctalia-Colloid-Dark"
THEME2_NAME="Noctalia-Colloid-Dark-2"
THEME2_PATH="$HOME/.icons/Noctalia-Colloid-Dark-2"

[[ ! -f "$COLOR_FILE" ]] && { echo "Error: $COLOR_FILE not found"; exit 1; }

# ── 1. Identify current / target theme (single gsettings call) ───────────────
CURRENT_NAME=$(gsettings get org.gnome.desktop.interface icon-theme)
CURRENT_NAME="${CURRENT_NAME//\'/}"   # strip quotes without spawning tr

if [[ "$CURRENT_NAME" == "$THEME1_NAME" ]]; then
    CURRENT_PATH="$THEME1_PATH"
    TARGET_NAME="$THEME2_NAME"
    TARGET_PATH="$THEME2_PATH"
elif [[ "$CURRENT_NAME" == "$THEME2_NAME" ]]; then
    CURRENT_PATH="$THEME2_PATH"
    TARGET_NAME="$THEME1_NAME"
    TARGET_PATH="$THEME1_PATH"
else
    # Default to theme 1 if neither is set
    CURRENT_PATH=""
    TARGET_NAME="$THEME1_NAME"
    TARGET_PATH="$THEME1_PATH"
fi

# ── 2. Parse NEW_HEX from color file (awk: single pass, no grep chain) ───────
RGB=$(awk '
    /^\[Colors:Selection\]/ { in_section=1; next }
    in_section && /^\[/     { exit }
    in_section && /^BackgroundNormal=/ {
        sub(/^BackgroundNormal=/, "")
        gsub(/\r/, "")
        print; exit
    }
' "$COLOR_FILE")

[[ -z "$RGB" ]] && { echo "Error: BackgroundNormal not found in $COLOR_FILE"; exit 1; }

IFS=',' read -r R G B <<< "$RGB"
NEW_HEX=$(printf "#%02x%02x%02x" "$R" "$G" "$B")

# ── 3. Early-exit if current theme already matches ───────────────────────────
if [[ -n "$CURRENT_PATH" ]]; then
    SAMPLE_SVG_CURRENT="$CURRENT_PATH/places/scalable/folder.svg"
    if [[ -f "$SAMPLE_SVG_CURRENT" ]]; then
        # Check if ALL colors in current theme match NEW_HEX
        MISMATCH=$(grep -oP "color:\K#[0-9a-fA-F]{6}" "$SAMPLE_SVG_CURRENT" | grep -vi "$NEW_HEX" || true)
        if [[ -z "$MISMATCH" ]]; then
            echo "Already up to date: $CURRENT_NAME ($NEW_HEX)"
            exit 0
        fi
    fi
fi

# ── 4. Detect OLD_COLORS in target ──────────────────────────────────────────
[[ ! -d "$TARGET_PATH" ]] && { echo "Error: $TARGET_PATH not found"; exit 1; }

SAMPLE_SVG="$TARGET_PATH/places/scalable/folder.svg"
[[ ! -f "$SAMPLE_SVG" ]] && { echo "Error: $SAMPLE_SVG not found"; exit 1; }

# Get all unique hex colors from the style block
OLD_COLORS=$(grep -oP "color:\K#[0-9a-fA-F]{6}" "$SAMPLE_SVG" | sort -u)

if [[ -z "$OLD_COLORS" ]]; then
    echo "Error: Could not detect any colors in $TARGET_PATH"
    exit 1
fi

# ── 5. Replace colors in target theme ────────────────────────────────────────
PERL_EXPR=""
for OLD_HEX in $OLD_COLORS; do
    if [[ "$OLD_HEX" != "$NEW_HEX" ]]; then
        echo "Updating $TARGET_NAME: $OLD_HEX → $NEW_HEX"
        PERL_EXPR+="s/\Q${OLD_HEX}\E/${NEW_HEX}/gi; "
    fi
done

if [[ -n "$PERL_EXPR" ]]; then
    NPROC=$(nproc)
    # Search for any of the old colors to build the file list
    SEARCH_PATTERN=$(echo "$OLD_COLORS" | paste -sd '|' -)

    LC_ALL=C grep -rlE "$SEARCH_PATTERN" "$TARGET_PATH/places" \
        | xargs -P "$NPROC" -I{} perl -pi -e "$PERL_EXPR" {}

    # Rebuild icon cache in background
    {
        command -v gtk4-update-icon-cache &>/dev/null \
            && gtk4-update-icon-cache -q -f -t "$TARGET_PATH"
        command -v gtk-update-icon-cache &>/dev/null \
            && gtk-update-icon-cache  -q -f -t "$TARGET_PATH"
    } &
    CACHE_PID=$!
else
    echo "$TARGET_NAME already at $NEW_HEX — just switching."
    CACHE_PID=""
fi

# ── 6. Async thumbnail wipe + theme switch ───────────────────────────────────
# Wipe thumbnails to force file manager to reload icons
find "$HOME/.cache/thumbnails" -maxdepth 3 -type f -name "*.png" -delete &
THUMB_PID=$!

# Switch theme immediately
gsettings set org.gnome.desktop.interface icon-theme "$TARGET_NAME"

# Only wait for cache rebuild (affects icon display)
[[ -n "$CACHE_PID" ]] && wait "$CACHE_PID"

echo "Done! → $TARGET_NAME ($NEW_HEX)"
