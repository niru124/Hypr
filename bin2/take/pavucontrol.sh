#!/bin/bash

# Set window dimensions and position
WIDTH=800
HEIGHT=600
X_POS=200
Y_POS=100

# Launch pavucontrol with specific dimensions and open playback tab
pavucontrol &
sleep 0.5  # Wait for pavucontrol to launch (adjust if needed)

# Find the pavucontrol window ID
WINDOW_ID=$(hyprctl clients | jq -r '.[] | select(.class == "pavucontrol") | .address')

if [ -n "$WINDOW_ID" ]; then
  # Move and resize the window
  hyprctl dispatch movewindowpixel exact $X_POS $Y_POS,address:$WINDOW_ID
  hyprctl dispatch resizewindowpixel exact $WIDTH $HEIGHT,address:$WINDOW_ID

  # Switch to the Playback tab.  This requires xdotool. Install it if you don't have it.
  sleep 0.2 # Add a small delay before sending keystrokes (adjust if needed)
  xdotool search --class "pavucontrol" windowactivate key "ctrl+1" #opens playback tab.
else
  echo "Error: pavucontrol window not found."
fi
