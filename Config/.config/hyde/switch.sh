#!/usr/bin/env zsh

# Check if HDMI-A-1 is connected
if hyprctl monitors | grep -q "HDMI-A-1"; then
  if [[ $1 == "open" ]]; then
    # Enable eDP-1 and position it to the right of HDMI-A-1
    hyprctl keyword monitor "eDP-1,1920x1080@60.06,1366x0,1"
  else
    # Disable eDP-1
    hyprctl keyword monitor "eDP-1,disable"
  fi
else
  echo "HDMI-A-1 not connected"
fi

