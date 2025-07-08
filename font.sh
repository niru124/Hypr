#!/bin/bash

set -e

install_font() {
    local FONT_NAME="$1"
    local DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
    local FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

    echo "Installing ${FONT_NAME} Nerd Font..."

    # Create font directory
    mkdir -p "$FONT_DIR"

    # Download and unzip the font
    echo "Downloading ${FONT_NAME}..."
    curl -L -o "${FONT_NAME}.zip" "$DOWNLOAD_URL"

    echo "Extracting ${FONT_NAME}..."
    unzip -o "${FONT_NAME}.zip" -d "$FONT_DIR"

    # Clean up the zip file
    rm "${FONT_NAME}.zip"

    echo "${FONT_NAME} installed in ${FONT_DIR}"
}

# Install both fonts
install_font "CaskaydiaCove"
install_font "0xProto"

# Update font cache once after all installations
echo "Updating font cache..."
fc-cache -fv

echo "✅ All fonts installed successfully!"

