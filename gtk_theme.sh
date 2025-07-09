#!/bin/bash

set -e

# Install Catppuccin GTK Theme
echo "Installing Catppuccin GTK Theme using yay..."
yay -S --noconfirm --needed catppuccin-gtk-theme-lavender

# Grant Flatpak access to local themes
echo "Granting Flatpak access to ~/.local/share/themes..."
sudo flatpak override --filesystem=$HOME/.local/share/themes

echo "✅ Catppuccin GTK Theme installed and Flatpak access configured."
