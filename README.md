# Colloid Noctalia Dynamic Icon Updater

This repository provides an optimized way to update Colloid icon colors dynamically based on your Noctalia color scheme. It uses a "ping-pong" technique (switching between two identical theme variants) to force GTK applications to refresh their icons instantly without glitches.

## Features
- **Fast Updates**: Uses `perl` and `grep` for high-performance SVG color replacement.
- **Parallel Processing**: Utilizes multiple CPU cores to update icon files.
- **Instant Refresh**: Avoids GTK icon caching issues by toggling between two theme versions.
- **Automatic**: Designed to be triggered by wallpaper change hooks.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/colloid-noctalia-updater.git
   cd colloid-noctalia-updater
   ```

2. Run the installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   *The installer will download the base Colloid icons and set up the necessary configurations.*

## Usage

To automatically update your icon colors when the wallpaper changes, add the following line to your wallpaper change script/hook:

```bash
sleep 0.5 && /bin/bash ~/.config/noctalia/update_colloid_colors.sh
```

### Manual Update
You can also run the update script manually at any time:
```bash
~/.config/noctalia/update_colloid_colors.sh
```

## Requirements
- `curl`, `git`, `unzip`
- `perl` (for fast text replacement)
- `gsettings` (for theme switching)
- `gtk-update-icon-cache` (usually provided by GTK)

## Credits
- Based on the [Colloid Icon Theme](https://github.com/vinceliuice/Colloid-icon-theme).
- Inspired by the [Noctalia Dynamic Icons](https://github.com/ezequielgk/noctalia-dynamic-icons) project.
