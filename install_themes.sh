#!/bin/bash

current_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
themes_dir="$current_directory/themes"

# Create directories
mkdir -p "$HOME/.themes"
mkdir -p "$HOME/.icons"

# Unzip all zip files in themes directory
for zip_file in "$themes_dir"/*.zip; do
    if [ -f "$zip_file" ]; then
        unzip -o "$zip_file" -d "$themes_dir"
        echo "Unzipped: $zip_file"
    fi
done

# Move Catppuccin to .themes
catppuccin_dir="$themes_dir/Catppuccin-B-MB-Dark"
if [ -d "$catppuccin_dir" ]; then
    cp -r "$catppuccin_dir"/* "$HOME/.themes/"
    echo "Copied Catppuccin to $HOME/.themes/"
else
    echo "Catppuccin directory not found: $catppuccin_dir"
fi

# Move Bibata to .icons
bibata_dir="$themes_dir/Bibata-Modern-Ice"
if [ -d "$bibata_dir" ]; then
    cp -r "$bibata_dir"/* "$HOME/.icons/"
    echo "Copied Bibata to $HOME/.icons/"
else
    echo "Bibata directory not found: $bibata_dir"
fi
