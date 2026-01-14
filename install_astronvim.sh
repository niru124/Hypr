#!/bin/bash

set -e

echo "--- Starting AstroNvim Installation ---"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove existing nvim configuration
if [ -d "$HOME/.config/nvim" ]; then
    echo "Removing existing ~/.config/nvim..."
    rm -rf ~/.config/nvim
fi

# Clone AstroNvim template
echo "Cloning AstroNvim template..."
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim

# Remove .git from cloned repo
echo "Removing .git from cloned repository..."
rm -rf ~/.config/nvim/.git

# Copy local nvim config on top
echo "Copying local nvim configuration..."
if [ -d "$CURRENT_DIR/Config/.config/nvim" ]; then
    cp -r "$CURRENT_DIR/Config/.config/nvim/"* ~/.config/nvim/
else
    echo "Warning: $CURRENT_DIR/Config/.config/nvim not found"
fi

# Run nvim to trigger Lazy sync
echo "Running nvim to sync plugins (this may take a while on first run)..."
if command -v nvim &> /dev/null; then
    nvim --headless -c 'quitall' 2>/dev/null || true
    echo "Plugin sync complete."
else
    echo "Warning: nvim not found. Skipping initial plugin sync."
fi

echo "--- AstroNvim Installation Complete ---"
