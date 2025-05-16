#!/bin/bash

# Launch Kitty and run the launcher script
kitty --hold --title "Launcher" -e bash -c "~/scripts/kitty_launcher.sh" &
sleep 0.5

# Move Kitty window using xdotool
WINDOW_ID=$(xdotool search --name "Launcher")
xdotool windowmove $WINDOW_ID 500 300
