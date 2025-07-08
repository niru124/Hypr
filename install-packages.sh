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

# Move Config directory contents to ~/.config
echo "Copying configuration files to ~/.config..."
mkdir -p ~/.config
cp -r "$CURRENT_DIR/Config/"* ~/.config/

echo "Configuration files copied."

# Move 'bin2' contents to ~/.local/share/bin
echo "Copying scripts to ~/.local/share/bin..."
mkdir -p ~/.local/share/bin
cp -r "$CURRENT_DIR/bin2/"* ~/.local/share/bin/

echo "Scripts copied to ~/.local/share/bin"

