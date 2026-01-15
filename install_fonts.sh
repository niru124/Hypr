#!/bin/bash

# Check if yay is installed (needed for potential AUR fonts)
if ! command -v yay &>/dev/null; then
    echo "Warning: 'yay' is not installed. If font installation fails, install yay first."
fi

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
install_nerd_font "GeistMono"

# Install Noto Color Emoji for emoji support
echo "Installing Noto Color Emoji..."
sudo pacman -S --needed --noconfirm noto-fonts-emoji

# Install custom fonts
install_custom_font "Abocat" "https://font.download/dl/font/abocat.zip"
install_custom_font "Steelfish" "https://dl.dafont.com/dl/?f=steelfish"
install_custom_font "Mexcellent" "https://dl.dafont.com/dl/?f=mexcellent"

# Update font cache once after all installations
echo "Updating font cache..."
fc-cache -fv

# Set zsh as default shell
echo "Setting zsh as default shell..."
chsh -s $(which zsh) || true

echo "--- Font Installation Complete ---"