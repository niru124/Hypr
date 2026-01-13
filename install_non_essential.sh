#!/bin/bash

# Correct way to get current directory
CURRENT_DIR=$(pwd)

PACKAGE_FILE="$CURRENT_DIR/non-essential.txt"

# Check if package files exist
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: File '$PACKAGE_FILE' not found!"
    exit 1
fi

# Select packages using fzf
echo "Loading non-essential packages from $PACKAGE_FILE..."
selected=$(cat "$PACKAGE_FILE" | fzf -m --prompt="Select non-essential packages to install (Tab to select, Enter to confirm): ")

if [ -z "$selected" ]; then
    echo "No packages selected."
    exit 0
fi

echo "Selected packages:"
echo "$selected"
echo

# Install selected packages via yay
echo "Installing selected packages..."
echo "$selected" | xargs yay -S --noconfirm --needed

echo "Installation complete."
