#!/bin/bash

PACKAGE_FILE=$pwd"packages.txt"

# Check if the file exists
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: File '$PACKAGE_FILE' not found!"
    exit 1
fi

# Read the package names and install them
echo "Installing packages from '$PACKAGE_FILE'..."
sudo pacman -Syu --noconfirm
xargs -a "$PACKAGE_FILE" sudo pacman -S --noconfirm

echo "All packages processed."
