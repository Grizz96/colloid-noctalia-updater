# Colloid Noctalia Dynamic Icon Updater

This repository provides an optimized way to update Colloid icon colors dynamically based on your Noctalia color scheme. It uses a "ping-pong" technique (switching between two identical theme variants) to force GTK applications to refresh their icons instantly without glitches.

https://github.com/Grizz96/colloid-noctalia-updater/raw/main/show.mp4

## Features
- **Fast Updates**: Uses `perl` and `grep` for high-performance SVG color replacement.
- **Parallel Processing**: Utilizes multiple CPU cores to update icon files.
- **Instant Refresh**: Avoids GTK icon caching issues by toggling between two theme versions.
- **Automatic**: Designed to be triggered by wallpaper change hooks.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/Grizz96/colloid-noctalia-updater.git
   cd colloid-noctalia-updater
   ```

2. Run the installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

### What does `install.sh` do?
- **Dependency Check**: Ensures `curl`, `git`, `perl`, and `gsettings` are installed.
- **Smart Base Theme Setup**: 
  - Checks if `Noctalia-Colloid-Dark` is already installed in `~/.icons`.
  - If not found, it downloads and runs the base installer from [noctalia-dynamic-icons](https://github.com/ezequielgk/noctalia-dynamic-icons).
- **Dual-Theme Strategy (The "Ping-Pong"):** 
  - The installer **copies** the base theme to create a second variant: `Noctalia-Colloid-Dark-2`.
  - **Why two themes?** GNOME and other desktop environments often cache icons. By switching back and forth between two identical themes (Theme 1 ↔ Theme 2), we force the system to refresh all icons instantly whenever the colors are updated.
- **Script Deployment**: Installs the `update-colloid.sh` script to `~/.config/noctalia/`.

## Usage

To automatically update your icon colors when the wallpaper changes, add the following line to your wallpaper change script/hook:

```bash
sleep 0.5 && /bin/bash ~/.config/noctalia/update-colloid.sh
```

> **Note**: The `sleep 0.5` delay ensures that your system has finished writing the new Noctalia color files before this script starts. If you have a powerful machine, you can try reducing this (e.g., `0.2`), or increase it if the colors don't update consistently.

### Manual Update
You can also run the update script manually at any time:
```bash
~/.config/noctalia/update-colloid.sh
```

## Requirements
- `curl`, `git`, `unzip`
- `perl` (for fast text replacement)
- `gsettings` (for theme switching)
- `gtk-update-icon-cache` (usually provided by GTK)

## Credits
- Based on the [Colloid Icon Theme](https://github.com/vinceliuice/Colloid-icon-theme).
- Icons are downloaded from the [Noctalia Dynamic Icons](https://github.com/ezequielgk/noctalia-dynamic-icons) project.
