#!/bin/bash

# Get the absolute path of the current directory
current_directory="$(pwd)"

# Path to vim source and destination
vim_source="$current_directory/.vimrc"
vim_dest="$HOME/.vimrc"

# Copy the vim config to $HOME/.vimrc 
if [ -f "$vim_source" ]; then
    # Check if vim is installed
    if ! command -v vim &>/dev/null; then
        echo "Error: 'vim' is not installed. Please install vim first."
    else
        sudo cp "$vim_source" "$vim_dest"
        echo "Copied vim config to $vim_dest"
    fi
else
    echo "vim config not found at $vim_source"
fi

