#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Correct way to get current directory of the script
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Helper function for user confirmation ---
confirm_action() {
	read -p "Do you want to install/run: $1? (y/N): " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		return 0 # User confirmed yes
	else
		return 1 # User confirmed no
	fi
}

# --- Main Script Logic ---
echo "Welcome to the HyDE Installation Script!"
echo "This script will guide you through installing various components for your Hyprland setup."
echo

# Core Packages
if confirm_action "Core Packages (pacman/yay packages, config files, scripts, zoxide)"; then
	if [ -f "./install_core.sh" ]; then
		chmod +x ./install_core.sh
		./install_core.sh
	else
		echo "install_core.sh not found."
	fi
	echo
fi

# Oh My Zsh
if confirm_action "Oh My Zsh (theme, plugins, .zshrc)"; then
	if [ -f "./install_zsh.sh" ]; then
		chmod +x ./install_zsh.sh
		./install_zsh.sh
	else
		echo "install_zsh.sh not found."
	fi
	echo
fi

# Wallpapers
if confirm_action "Wallpapers (themes repository)"; then
	if [ -f "./install_wallpapers.sh" ]; then
		chmod +x ./install_wallpapers.sh
		./install_wallpapers.sh
	else
		echo "install_wallpapers.sh not found."
	fi
	echo
fi

# GPU Drivers
if confirm_action "GPU Drivers (NVIDIA/AMD/Intel)"; then
	if [ -f "./install_gpu_drivers.sh" ]; then
		chmod +x ./install_gpu_drivers.sh
		./install_gpu_drivers.sh
	else
		echo "install_gpu_drivers.sh not found."
	fi
	echo
fi

# Non-Essential Packages
if confirm_action "Non-Essential Packages (from non-essential.txt)"; then
	if [ -f "./install_non_essential.sh" ]; then
		chmod +x ./install_non_essential.sh
		./install_non_essential.sh
	else
		echo "install_non_essential.sh not found."
	fi
	echo
fi

# Fonts
if confirm_action "Nerd Fonts (CaskaydiaCove, 0xProto, JetBrainsMono) and Custom Fonts (Abocat, Steelfish Outline, Mexcellent)"; then
	if [ -f "./install_fonts.sh" ]; then
		chmod +x ./install_fonts.sh
		./install_fonts.sh
	else
		echo "install_fonts.sh not found."
	fi
	echo
fi

# Pyprland
if confirm_action "Pyprland (in a Python virtual environment)"; then
	if [ -f "./pyprland.sh" ]; then
		chmod +x ./pyprland.sh
		./pyprland.sh
	else
		echo "pyprland.sh not found."
	fi
	echo
fi

# TUI Greet Configuration
if confirm_action "TUI Greet Display Manager Configuration (requires sudo)"; then
	if [ -f "./tui_greet.sh" ]; then
		chmod +x ./tui_greet.sh
		./tui_greet.sh
	else
		echo "tui_greet.sh not found."
	fi
	echo
fi

# AstroNvim
if confirm_action "AstroNvim (Neovim configuration)"; then
	if [ -f "./install_astronvim.sh" ]; then
		chmod +x ./install_astronvim.sh
		./install_astronvim.sh
	else
		echo "install_astronvim.sh not found."
	fi
	echo
fi

# Additional Installations
if confirm_action "Run Non-Essential Packages Installation (install_non_essential.sh)"; then
	if [ -f "./install_non_essential.sh" ]; then
		chmod +x ./install_non_essential.sh
		./install_non_essential.sh
	else
		echo "install_non_essential.sh not found."
	fi
	echo
fi

if confirm_action "Run Hyprpm Plugins Installation (install_hyprpm_plugins.sh)"; then
	if [ -f "./install_hyprpm_plugins.sh" ]; then
		chmod +x ./install_hyprpm_plugins.sh
		./install_hyprpm_plugins.sh
	else
		echo "install_hyprpm_plugins.sh not found."
	fi
	echo
fi

echo "Installation script finished. Please review the output for any errors."
echo "You may need to log out and back in for some changes to take effect."
