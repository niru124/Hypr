#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting AstroNvim Installation ---"

# Check if neovim is installed
if ! command -v nvim &>/dev/null; then
    echo "Error: 'nvim' (Neovim) is not installed. Please install Neovim v0.7+ first."
    exit 1
fi

echo "Prerequisites: Please ensure Nerd Fonts are installed and configured."

# Backup existing Neovim configuration (optional but recommended)
if [ -d "$HOME/.config/nvim" ]; then
    echo "Backing up existing Neovim configuration..."
    mv ~/.config/nvim ~/.config/nvim.bak || true
fi
if [ -d "$HOME/.local/share/nvim" ]; then
    mv ~/.local/share/nvim ~/.local/share/nvim.bak || true
fi
if [ -d "$HOME/.local/state/nvim" ]; then
    mv ~/.local/state/nvim ~/.local/state/nvim.bak || true
fi
if [ -d "$HOME/.cache/nvim" ]; then
    mv ~/.cache/nvim ~/.cache/nvim.bak || true
fi

# Clone the AstroNvim template repository
echo "Cloning AstroNvim template repository..."
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim

# Start Neovim to trigger plugin installation
echo "Launching Neovim to complete plugin installation. This may take some time."
nvim --headless +"Lazy! sync" +qa

echo "--- AstroNvim Installation Complete ---"
echo "You can now launch nvim to start using AstroNvim."
