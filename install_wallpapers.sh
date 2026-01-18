#!/bin/bash
set -e
THEMES_REPO="https://github.com/niru124/themes"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYDE_WALLPAPER_DIR="$HOME/.config/hyde/themes"
TEMP_DIR=$(mktemp -d)
echo "--- Installing Wallpaper Repository ---"
echo "Cloning themes repository..."
if ! git clone "$THEMES_REPO" "$TEMP_DIR"; then
	echo "Error: Failed to clone repository"
	rm -rf "$TEMP_DIR"
	exit 1
fi
echo "Setting up wallpapers..."
mkdir -p "$HYDE_WALLPAPER_DIR"
if [ -d "$TEMP_DIR/themes" ]; then
	cp -r "$TEMP_DIR/themes/"* "$HYDE_WALLPAPER_DIR/"
	echo "Wallpapers copied to $HYDE_WALLPAPER_DIR"
elif [ -d "$TEMP_DIR" ]; then
	cp -r "$TEMP_DIR/"* "$HYDE_WALLPAPER_DIR/" 2>/dev/null || true
	echo "Contents copied to $HYDE_WALLPAPER_DIR"
else
	echo "Warning: No wallpapers found in repository"
fi
rm -rf "$TEMP_DIR"
echo "--- Wallpaper Installation Complete ---"
