#!/bin/bash

PACKAGE_FILE=$pwd"packages.txt"
PACKAGE_FILE2=$pwd"packages2.txt"

# Check if the file exists
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: File '$PACKAGE_FILE' not found!"
    exit 1
fi

# Read the package names and install them
echo "Installing packages from '$PACKAGE_FILE'..."
sudo pacman -Syu --noconfirm
xargs -a "$PACKAGE_FILE" sudo pacman -S --noconfirm

# Read the package names and install them
echo "Installing packages from '$PACKAGE_FILE'... with yay"
xargs -a "$PACKAGE_FILE" yay -S --noconfirm

echo "All packages processed."

# Move Config directory contents to ~/.config
echo "Copying configuration files to ~/.config..."
mkdir -p ~/.config
cp -r Config/* ~/.config/

echo "Configuration files copied."

# Move 'bin2' contents to ~/.local/share/bin
echo "Copying scripts to ~/.local/share/bin..."
mkdir -p ~/.local/share/bin
cp -r "$CURRENT_DIR/bin2/"* ~/.local/share/bin/
