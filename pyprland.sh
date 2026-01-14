#!/bin/bash

# Check if yay is installed
if ! command -v yay &>/dev/null; then
    echo "Error: 'yay' is not installed. Please install yay (AUR helper) first."
    exit 1
fi

echo "--- Starting Pyprland Installation ---"

# Install pyprland from AUR
echo "Installing pyprland from AUR..."
yay -S --noconfirm pyprland

echo "--- Pyprland Installation Complete ---"

