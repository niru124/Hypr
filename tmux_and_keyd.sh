#!/bin/bash

# Get the absolute path of the current directory
current_directory="$(pwd)"

# Path to .tmux.conf source and destination
tmux_source="$current_directory/Config/.config/tmux/.tmux.conf"
tmux_dest="$HOME/.tmux.conf"

# Path to keyd source and destination
keyd_source="$current_directory/keyd"
keyd_dest="/etc/keyd/default.conf"

# Copy the .tmux.conf file to the user's home directory
if [ -f "$tmux_source" ]; then
    cp "$tmux_source" "$tmux_dest"
    echo "Copied .tmux.conf to $tmux_dest"
else
    echo ".tmux.conf not found at $tmux_source"
fi

# Copy the keyd config to /etc/keyd (requires sudo)
if [ -f "$keyd_source" ]; then
    sudo cp "$keyd_source" "$keyd_dest"
    echo "Copied keyd config to $keyd_dest"
else
    echo "keyd config not found at $keyd_source"
fi

