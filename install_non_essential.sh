#!/bin/bash

# Correct way to get current directory
CURRENT_DIR=$(pwd)

PACKAGE_FILE="$CURRENT_DIR/non-essential.txt"

# Check if package files exist
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: File '$PACKAGE_FILE' not found!"
    exit 1
fi

# Install packages via yay
echo "Installing packages from '$PACKAGE_FILE' using yay..."
xargs -a "$PACKAGE_FILE" yay -S --noconfirm --needed

echo "All packages processed."
