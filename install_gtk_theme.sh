#!/bin/bash

echo "--- Starting GTK Theme Installation ---"

# Install Catppuccin GTK Theme
echo "Installing Catppuccin GTK Theme using yay..."
yay -S --noconfirm --needed catppuccin-gtk-theme-lavender

# Grant Flatpak access to local themes
echo "Granting Flatpak access to ~/.local/share/themes..."
sudo flatpak override --filesystem=$HOME/.local/share/themes

echo "--- GTK Theme Installation Complete ---"