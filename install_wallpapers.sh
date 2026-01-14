#!/bin/bash

set -e

echo "--- Installing Wallpaper Repository ---"

THEMES_REPO="https://github.com/niru124/themes"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYDE_WALLPAPER_DIR="$SCRIPT_DIR/Config/.config/hyde/wallpapers"
TEMP_DIR=$(mktemp -d)

echo "Cloning themes repository..."
git clone "$THEMES_REPO" "$TEMP_DIR/themes"

echo "Setting up wallpapers..."
mkdir -p "$HYDE_WALLPAPER_DIR"

if [ -d "$TEMP_DIR/themes/wallpapers" ]; then
    cp -r "$TEMP_DIR/themes/wallpapers/"* "$HYDE_WALLPAPER_DIR/"
    echo "Wallpapers copied to $HYDE_WALLPAPER_DIR"
elif [ -d "$TEMP_DIR/themes" ]; then
    cp -r "$TEMP_DIR/themes/"* "$HYDE_WALLPAPER_DIR/"
    echo "Contents copied to $HYDE_WALLPAPER_DIR"
else
    echo "Warning: No wallpapers found in repository"
fi

rm -rf "$TEMP_DIR"
echo "--- Wallpaper Installation Complete ---"
