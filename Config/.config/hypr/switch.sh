#!/bin/bash

# Get connected monitor names using hyprctl
connected_monitors=($(hyprctl monitors | grep 'Monitor' | awk '{print $2}'))

# Check if we have any connected monitors
if [ ${#connected_monitors[@]} -eq 0 ]; then
  echo "No monitors are connected."
  exit 1
fi

echo "Connected monitors:"
for i in "${!connected_monitors[@]}"; do
  echo "$i) ${connected_monitors[$i]}"
done

# Ask the user to select the main monitor
read -p "Select the number of the monitor to use as main: " choice

# Validate choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -ge "${#connected_monitors[@]}" ]; then
  echo "Invalid selection."
  exit 1
fi

main_monitor="${connected_monitors[$choice]}"
echo "Setting $main_monitor as the main monitor."

# Enable the selected monitor with default resolution and position
# You may want to customize resolution/refresh/position depending on your setup
hyprctl keyword monitor "$main_monitor,preferred,0x0,1"

# Disable all other monitors
for mon in "${connected_monitors[@]}"; do
  if [ "$mon" != "$main_monitor" ]; then
    echo "Disabling $mon"
    hyprctl keyword monitor "$mon,disable"
  fi
done

