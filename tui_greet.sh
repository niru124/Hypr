#!/bin/bash

CONFIG_FILE="/etc/greetd/config.toml"
NEW_COMMAND='command = "tuigreet --cmd Hyprland --time --remember --asterisks --greeting '\'' Welcome to Hyprland '\'' --theme '\''border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red'\''"'

# Check if run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root (e.g., with sudo)."
  exit 1
fi

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

# Replace the line containing 'command = ' with the new command
sed -i "s|^command = .*|$NEW_COMMAND|" "$CONFIG_FILE"

echo "Updated 'command =' in $CONFIG_FILE"
