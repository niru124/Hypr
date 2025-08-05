#!/bin/bash

# Set this to the path of your config if not in current dir
CONF_FILE="./hyprland.conf"
BACKUP_FILE="./hyprland.conf.bak"

# Check config exists
if [[ ! -f "$CONF_FILE" ]]; then
    echo "[ERROR] hyprland.conf not found in current directory."
    exit 1
fi

# Make a backup
cp "$CONF_FILE" "$BACKUP_FILE"
echo "[INFO] Backup of config saved to $BACKUP_FILE"

# Store initial monitor names
prev_monitors=$(hyprctl monitors | grep 'Monitor' | awk '{print $2}' | sort)

# Start monitoring loop
while true; do
    sleep 2

    curr_monitors=$(hyprctl monitors | grep 'Monitor' | awk '{print $2}' | sort)

    if [[ "$curr_monitors" != "$prev_monitors" ]]; then
        echo "[INFO] Monitor configuration changed."

        # Find unplugged monitors
        unplugged=$(comm -23 <(echo "$prev_monitors") <(echo "$curr_monitors"))

        for monitor in $unplugged; do
            echo "[INFO] Detected unplugged monitor: $monitor"

            # Notify user
            notify-send "Monitor unplugged" "Monitor \"$monitor\" has been disconnected"

            # Comment lines related to the unplugged monitor in config
            sed -i "/$monitor/s/^/# [auto-commented] /" "$CONF_FILE"
            echo "[INFO] Commented lines containing: $monitor"
        done

        # Reload Hyprland config
        echo "[INFO] Reloading Hyprland..."
        hyprctl reload

        # Update monitor snapshot
        prev_monitors=$curr_monitors
    fi
done
