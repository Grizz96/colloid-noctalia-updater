#!/bin/bash
# Installer for Noctalia Colloid Dynamic Icons

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $1"; }
success() { echo -e "${GREEN}[ok]${NC} $1"; }
error()   { echo -e "${RED}[error]${NC} $1"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/noctalia"
ICONS_DIR="$HOME/.icons"
THEME1_PATH="$ICONS_DIR/Noctalia-Colloid-Dark"
THEME2_PATH="$ICONS_DIR/Noctalia-Colloid-Dark-2"

info "Installing Noctalia Colloid Dynamic Icons..."

# 1. Check dependencies
dependencies=(curl git unzip perl gsettings)
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        error "$dep is not installed. Please install it first."
    fi
done

# 2. Download and run the base Colloid Noctalia installer
# Using a temp file instead of psub for bash compatibility
if [ ! -d "$THEME1_PATH" ]; then
    info "Downloading base Colloid Noctalia theme..."
    TMP_SCRIPT=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/ezequielgk/noctalia-dynamic-icons/main/colloid.sh -o "$TMP_SCRIPT"
    chmod +x "$TMP_SCRIPT"

    info "Running Colloid Noctalia installer (Please select option 1 if prompted)..."
    # We run it in a way that allows user interaction
    bash "$TMP_SCRIPT"
    rm "$TMP_SCRIPT"
else
    success "Base theme already installed at $THEME1_PATH, skipping download."
fi

# 3. Create the second theme variant for ping-pong switching
if [ -d "$THEME1_PATH" ]; then
    info "Creating theme variant for faster switching..."
    rm -rf "$THEME2_PATH"
    cp -r "$THEME1_PATH" "$THEME2_PATH"

    # Update the name in index.theme for the second variant
    sed -i 's/Name=Noctalia-Colloid-Dark/Name=Noctalia-Colloid-Dark-2/' "$THEME2_PATH/index.theme"
    success "Created $THEME2_PATH"
else
    error "Base theme not found at $THEME1_PATH. Installation might have failed."
fi

# 4. Install the update script
info "Installing update script to $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"
cp "$REPO_DIR/update-colloid.sh" "$CONFIG_DIR/update-colloid.sh"
chmod +x "$CONFIG_DIR/update-colloid.sh"
success "Update script installed."

# 5. Instructions
echo -e "\n${BLUE}=== INSTALLATION COMPLETE ===${NC}"
echo -e "To automate color updates, add the following to your wallpaper change hook:"
echo -e "${GREEN}sleep 0.5 && /bin/bash $CONFIG_DIR/update-colloid.sh${NC}"
echo -e "\nNote: This script switches between two theme versions to ensure instant icon refresh."
