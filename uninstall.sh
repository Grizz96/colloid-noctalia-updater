#!/bin/bash
# Uninstaller for Noctalia Colloid Dynamic Icons

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $1"; }
success() { echo -e "${GREEN}[ok]${NC} $1"; }
warning() { echo -e "${RED}[warning]${NC} $1"; }

CONFIG_DIR="$HOME/.config/noctalia"
ICONS_DIR="$HOME/.icons"
THEME1_PATH="$ICONS_DIR/Noctalia-Colloid-Dark"
THEME2_PATH="$ICONS_DIR/Noctalia-Colloid-Dark-2"
UPDATE_SCRIPT="$CONFIG_DIR/update-colloid.sh"

info "Uninstalling Noctalia Colloid Dynamic Icons..."

# 1. Reset theme to the original one if currently using the variant
CURRENT_THEME=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
if [ "$CURRENT_THEME" == "Noctalia-Colloid-Dark-2" ]; then
    info "Resetting icon theme to Noctalia-Colloid-Dark..."
    gsettings set org.gnome.desktop.interface icon-theme "Noctalia-Colloid-Dark"
fi

# 2. Remove the second theme variant (ping-pong variant)
if [ -d "$THEME2_PATH" ]; then
    info "Removing theme variant: $THEME2_PATH"
    rm -rf "$THEME2_PATH"
    success "Theme variant removed."
else
    info "Theme variant $THEME2_PATH not found, skipping."
fi

# 3. Remove the update script
if [ -f "$UPDATE_SCRIPT" ]; then
    info "Removing update script: $UPDATE_SCRIPT"
    rm "$UPDATE_SCRIPT"
    success "Update script removed."

    # Check if directory is empty and remove it if it is
    if [ -d "$CONFIG_DIR" ] && [ -z "$(ls -A "$CONFIG_DIR")" ]; then
        rmdir "$CONFIG_DIR"
        info "Removed empty config directory: $CONFIG_DIR"
    fi
else
    info "Update script not found, skipping."
fi

# 4. Optional: Ask about removing the base theme
echo -e "\n${RED}Do you also want to remove the base theme (Noctalia-Colloid-Dark)?${NC} (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [ -d "$THEME1_PATH" ]; then
        info "Removing base theme: $THEME1_PATH"
        rm -rf "$THEME1_PATH"
        success "Base theme removed."
    else
        info "Base theme not found, skipping."
    fi
else
    info "Keeping base theme."
fi

echo -e "\n${BLUE}=== UNINSTALLATION COMPLETE ===${NC}"
echo -e "Don't forget to remove the update script from your wallpaper change hook if you added it."
