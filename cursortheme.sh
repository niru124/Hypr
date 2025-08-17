#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Cursor Theme Installation and Configuration ---"

# Install Bibata Cursor Theme via yay
echo "Installing bibata-cursor-theme using yay..."
yay -S --noconfirm --needed bibata-cursor-theme

# Define Hyprland config file path
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

# Check if hyprland.conf exists
if [ ! -f "$HYPRLAND_CONF" ]; then
    echo "Error: Hyprland config file not found at '$HYPRLAND_CONF'. Skipping cursor theme configuration."
    exit 1
fi

# Set HYPRCURSOR_THEME and HYPRCURSOR_SIZE in hyprland.conf
echo "Setting HYPRCURSOR_THEME and HYPRCURSOR_SIZE in $HYPRLAND_CONF..."

# Remove existing HYPRCURSOR_THEME and HYPRCURSOR_SIZE lines if they exist
sed -i '/^env = HYPRCURSOR_THEME/d' "$HYPRLAND_CONF"
sed -i '/^env = HYPRCURSOR_SIZE/d' "$HYPRLAND_CONF"

# Add the new env lines
echo "env = HYPRCURSOR_THEME,Bibata-Modern-Ice" >> "$HYPRLAND_CONF"
echo "env = HYPRCURSOR_SIZE,24" >> "$HYPRLAND_CONF"

echo "--- Cursor Theme Installation and Configuration Complete ---"
