#!/bin/bash

# Set the target directory
CONFIG_DIR="$HOME/.config/hypr"
VENV_DIR="$CONFIG_DIR/myenv"

# Create the config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Navigate to the config directory
cd "$CONFIG_DIR" || exit 1

# Create a Python virtual environment
python3 -m venv myenv

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Install pyprland
pip install pyprland

echo "✅ Pyprland installed in virtual environment at: $VENV_DIR"

