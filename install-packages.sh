#!/bin/bash

# Correct way to get current directory
CURRENT_DIR=$(pwd)

PACKAGE_FILE="$CURRENT_DIR/packages.txt"
PACKAGE_FILE2="$CURRENT_DIR/packages2.txt"

# Check if package files exist
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: File '$PACKAGE_FILE' not found!"
    exit 1
fi

if [ ! -f "$PACKAGE_FILE2" ]; then
    echo "Error: File '$PACKAGE_FILE2' not found!"
    exit 1
fi

# System update
echo "Updating system with pacman..."
sudo pacman -Syu --noconfirm

# Install packages via pacman
echo "Installing packages from '$PACKAGE_FILE' using pacman..."
xargs -a "$PACKAGE_FILE" sudo pacman -S --noconfirm --needed

# Install packages via yay
echo "Installing packages from '$PACKAGE_FILE2' using yay..."
xargs -a "$PACKAGE_FILE2" yay -S --noconfirm --needed

echo "All packages processed."

<<<<<<< HEAD
# Copy configuration files to ~/.config using rsync
# Copy the contents of .config subdirectory to ~/.config
CONFIG_DIR="$CURRENT_DIR/Config/.config"
if [ -d "$CONFIG_DIR" ] && [ "$(ls -A "$CONFIG_DIR")" ]; then
    echo "Copying configuration files from .config to ~/.config..."
    mkdir -p "$HOME/.config"
    rsync -avv --exclude='.*' "$CONFIG_DIR/" "$HOME/.config/" > rsync_config.log 2>&1
    echo "Configuration files copied."
else
    echo "Warning: '$CONFIG_DIR' does not exist or is empty. Skipping configuration copy."
fi

# Copy scripts to ~/.local/share/bin using rsync
BIN_DIR="$CURRENT_DIR/bin2"
if [ -d "$BIN_DIR" ] && [ "$(ls -A "$BIN_DIR")" ]; then
    echo "Copying scripts to ~/.local/share/bin..."
    mkdir -p ~/.local/share/bin
    rsync -av --exclude='.*' "$BIN_DIR/" ~/.local/share/bin/
    echo "Scripts copied to ~/.local/share/bin."
else
    echo "Warning: '$BIN_DIR' does not exist or is empty. Skipping script copy."
fi
=======
# Move Config directory contents to ~/.config
echo "Copying configuration files to ~/.config..."
mkdir -p ~/.config
cp -r "$CURRENT_DIR/Config/"* ~/.config/

echo "Configuration files copied."

# Move 'bin2' contents to ~/.local/share/bin
echo "Copying scripts to ~/.local/share/bin..."
mkdir -p ~/.local/share/bin
cp -r "$CURRENT_DIR/bin2/"* ~/.local/share/bin/

# Make all .sh scripts executable
echo "Making scripts executable..."
chmod +x ~/.local/share/bin/*.sh

echo "Scripts copied and made executable."

# Install zoxide using the official install script
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

echo "zoxide installation complete."
# >>>>>>> 7f242cf (add more script and config)
