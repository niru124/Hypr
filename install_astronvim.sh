#!/bin/bash

echo "--- Starting AstroNvim Installation ---"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASTROVIM_SCRIPT="$CURRENT_DIR/astrovim_install(extra).sh"

if [ ! -f "$ASTROVIM_SCRIPT" ]; then
    echo "Error: AstroNvim installation script not found at '$ASTROVIM_SCRIPT'. Skipping AstroNvim installation."
    exit 1
fi

echo "Running AstroNvim installation script..."
chmod +x "$ASTROVIM_SCRIPT"
"$ASTROVIM_SCRIPT"

echo "--- AstroNvim Installation Complete ---"