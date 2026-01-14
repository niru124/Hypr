#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# first install fzf here as it is later req in the script
sudo pacman -S fzf

# Install build dependencies for yay
sudo pacman -S --needed --noconfirm fakeroot binutils debugedit base-devel

# Install yay AUR helper
echo "Installing yay AUR helper..."
if ! command -v yay &> /dev/null; then
    YAY_DIR=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/yay.git "$YAY_DIR"
    cd "$YAY_DIR"
    makepkg -si --noconfirm
    cd "$CURRENT_DIR"
    rm -rf "$YAY_DIR"
    echo "yay installation complete."
else
    echo "yay is already installed."
fi

# Set up fzf key bindings and fuzzy completion
# Properly append fzf initialization to .zshrc if not already present
if ! grep -q 'eval "$(fzf --zsh)"' ~/.zshrc 2>/dev/null; then
    echo 'eval "$(fzf --zsh)"' >> ~/.zshrc
fi
# Also add fzf initialization to .bashrc for bash shells
if [ -f ~/.bashrc ] && ! grep -q 'eval "$(fzf --bash)"' ~/.bashrc 2>/dev/null; then
    echo 'eval "$(fzf --bash)"' >> ~/.bashrc
    # Source bashrc to apply fzf bindings in current session
    source ~/.bashrc 2>/dev/null || true
fi

# Correct way to get current directory of the script
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "--- Starting Core Packages and Configuration Installation ---"

PACKAGE_FILE="$CURRENT_DIR/pacman_necessary.txt"
PACKAGE_FILE2="$CURRENT_DIR/yay_necessary.txt"

# Check if package files exist
if [ ! -f "$PACKAGE_FILE" ]; then
	echo "Error: File '$PACKAGE_FILE' not found! Skipping pacman package installation."
	PACKAGE_FILE=""
fi

if [ ! -f "$PACKAGE_FILE2" ]; then
	echo "Error: File '$PACKAGE_FILE2' not found! Skipping AUR package installation."
	PACKAGE_FILE2=""
fi

# System update
echo "Updating system with pacman..."
sudo pacman -Syu --noconfirm || true

# Install packages via pacman
if [ -n "$PACKAGE_FILE" ]; then
	echo "Installing packages from '$PACKAGE_FILE' using pacman..."
	xargs -a "$PACKAGE_FILE" sudo pacman -S --noconfirm --needed || true
fi

# Select and install packages via yay using fzf
if [ -n "$PACKAGE_FILE2" ]; then
	echo "Loading AUR packages from $PACKAGE_FILE2..."
	selected=$(cat "$PACKAGE_FILE2" | fzf -m --prompt="Select AUR packages to install (Tab to select, Enter to confirm): ") || true

	if [ -z "$selected" ]; then
		echo "No AUR packages selected."
	else
		echo "Installing selected AUR packages..."
		echo "$selected" | xargs yay -S --noconfirm --needed || true
	fi
fi

echo "All core packages processed."

# Copy configuration files to ~/.config using rsync
CONFIG_DIR="$CURRENT_DIR/Config/.config"
if [ -d "$CONFIG_DIR" ] && [ "$(ls -A "$CONFIG_DIR")" ]; then
	echo "Copying configuration files from .config to ~/.config..."
	mkdir -p "$HOME/.config"
	rsync -avv --exclude='.*' "$CONFIG_DIR/" "$HOME/.config/" >/dev/null 2>&1 || true
	echo "Configuration files copied."
else
	echo "Warning: '$CONFIG_DIR' does not exist or is empty. Skipping configuration copy."
fi

# Copy scripts to ~/.local/share/bin using rsync
BIN_DIR="$CURRENT_DIR/bin2"
if [ -d "$BIN_DIR" ] && [ "$(ls -A "$BIN_DIR")" ]; then
	echo "Copying scripts to ~/.local/share/bin..."
	mkdir -p ~/.local/share/bin
	rsync -av --exclude='.*' "$BIN_DIR/" ~/.local/share/bin/ >/dev/null 2>&1 || true
	echo "Scripts copied to ~/.local/share/bin."
else
	echo "Warning: '$BIN_DIR' does not exist or is empty. Skipping script copy."
fi

# Make all .sh scripts executable in ~/.local/share/bin
echo "Making scripts executable in ~/.local/share/bin..."
chmod +x ~/.local/share/bin/*.sh || true # Use true to prevent script from exiting if no .sh files are found
echo "Scripts made executable."

# Install zoxide using the official install script
echo "Installing zoxide..."
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || true
echo "zoxide installation complete."

echo "--- Core Packages and Configuration Installation Complete ---"
