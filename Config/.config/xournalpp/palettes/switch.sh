#!/bin/bash

# Ensure this path is correct for your system
# Based on your 'yay' installation, it's likely '/usr/bin/otd'
OTD_EXECUTABLE="$(which otd)" # Dynamically find 'otd'

# If 'which otd' doesn't find it, you might need to hardcode:
# OTD_EXECUTABLE="/usr/bin/otd"

if [ -z "$OTD_EXECUTABLE" ]; then
	echo "Error: 'otd' executable not found in PATH." >&2
	exit 1
fi

CONFIG_DIR="/home/$USER/.config/xournalpp" # Using $USER for current user
CONFIG_NAME="$1"                           # The first argument to the script will be the config name

CONFIG_FILE=""
if [ -z "$CONFIG_NAME" ]; then
	echo "Warning: No configuration name provided. Using default." >&2
	CONFIG_FILE="${CONFIG_DIR}/opentabletdriver" # Fallback to a default config
else
	CONFIG_FILE="${CONFIG_DIR}/opentabletdriver_${CONFIG_NAME}" # Assuming configs are named like gaming.json, drawing.json
	# If your configs are named opentabletdriver_gaming.json, use:
	# CONFIG_FILE="${CONFIG_DIR}/opentabletdriver_${CONFIG_NAME}.json"
fi

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
	echo "Error: Configuration file not found: $CONFIG_FILE" >&2
	# Optionally, fall back to default or exit
	CONFIG_FILE="${CONFIG_DIR}/opentabletdriver"
	if [ ! -f "$CONFIG_FILE" ]; then
		echo "Error: Default config also not found. Exiting." >&2
		exit 1
	fi
	echo "Falling back to default config: $CONFIG_FILE" >&2
fi

echo "Starting OTD with config: $CONFIG_FILE" >&2

# Now, execute OpenTabletDriver using the 'loadsettings' command
# And then pipe to 'stdio' so it continues running in the foreground
exec "$OTD_EXECUTABLE" loadsettings "$CONFIG_FILE" && exec "$OTD_EXECUTABLE" stdio
