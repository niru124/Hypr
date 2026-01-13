#!/bin/bash

echo "--- Starting Cursor Theme Installation ---"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CURSOR_THEME_SCRIPT="$CURRENT_DIR/cursortheme.sh"

if [ ! -f "$CURSOR_THEME_SCRIPT" ]; then
    echo "Error: Cursor theme installation script not found at '$CURSOR_THEME_SCRIPT'. Skipping cursor theme installation."
    exit 1
fi

echo "Running cursor theme installation script..."
chmod +x "$CURSOR_THEME_SCRIPT"
"$CURSOR_THEME_SCRIPT"

echo "--- Cursor Theme Installation Complete ---"