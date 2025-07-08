#!/bin/bash

set -e

FONT_NAME="CaskaydiaCove"
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

echo "Installing Caskaydia Cove Nerd Font..."

# Create font directory
mkdir -p "$FONT_DIR"

# Download and unzip the font
echo "Downloading font..."
curl -L -o "${FONT_NAME}.zip" "$DOWNLOAD_URL"

echo "Extracting font..."
unzip -o "${FONT_NAME}.zip" -d "$FONT_DIR"

# Clean up the zip file
rm "${FONT_NAME}.zip"

# Update font cache
echo "Updating font cache..."
fc-cache -fv

echo "Caskaydia Cove Nerd Font installed successfully!"

