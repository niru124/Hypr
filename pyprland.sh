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

# Update hyprpm
hyprpm update

# Add hyprscroller plugin
hyprpm add https://github.com/cpiber/hyprscroller

# Enable hyprscroller plugin
hyprpm enable hyprscroller

echo "--- Pyprland Installation Complete ---"

