#!/bin/bash

echo "--- Starting Font Installation ---"

install_nerd_font() {
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

install_custom_font() {
    local FONT_NAME="$1"
    local DOWNLOAD_URL="$2"
    local FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

    echo "Installing ${FONT_NAME} font..."

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

# Install Nerd Fonts
install_nerd_font "CaskaydiaCove"
install_nerd_font "0xProto"
install_nerd_font "JetBrainsMono"

# Install custom fonts (PLACEHOLDER URLs - YOU MAY NEED TO FIND ACTUAL DIRECT DOWNLOAD LINKS)
# These URLs are examples and might not work. You'll need to find direct .zip download links.
install_custom_font "Abocat" "https://example.com/abocat.zip" # Placeholder URL
install_custom_font "SteelfishOutline" "https://example.com/steelfishoutline.zip" # Placeholder URL
install_custom_font "Mexcellent" "https://example.com/mexcellent.zip" # Placeholder URL

# Update font cache once after all installations
echo "Updating font cache..."
fc-cache -fv

echo "--- Font Installation Complete ---"