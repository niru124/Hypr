#!/bin/bash

# Check if hyprpm is installed
if ! command -v hyprpm &>/dev/null; then
	echo "hyprpm could not be found. Please ensure Hyprland (version 0.34.0 or later) or hyprland-git is installed."
	echo "You might need to update your Hyprland installation or install a git version if hyprpm is not available."
	exit 1
fi

echo "hyprpm found. Proceeding with plugin installation."

echo ""
echo "--------------------------------------------------------------------------------"
echo "IMPORTANT: For C++ plugins, you might need to install build dependencies."
echo "If you encounter compilation errors, please ensure you have the following installed:"
echo "  - git"
echo "  - cmake"
echo "  - a C++ compiler (e.g., g++)"
echo "  - a build system (e.g., make or ninja)"
echo "  - cpio"
echo "  - meson"
echo "Example for Debian/Ubuntu: sudo apt install git cmake g++ make cpio meson"
echo "Example for Arch Linux: sudo pacman -S git cmake gcc make cpio meson"
echo "--------------------------------------------------------------------------------"
echo ""

echo "Running hyprpm update..."
hyprpm update

echo "Adding hyprscroller plugin..."
hyprpm -v add https://github.com/cpiber/hyprscroller

echo "Script finished. You may need to enable the plugin with 'hyprpm enable hyprscroller' and then 'hyprpm reload' or restart Hyprland."
