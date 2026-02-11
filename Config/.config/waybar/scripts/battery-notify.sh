#!/bin/bash

prev_state=""

upower --monitor-detail /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep --line-buffered "state:" | while read -r line; do
    current_state=$(echo "$line" | grep -oP 'state:\s*\K\w+')
    if [[ "$current_state" != "$prev_state" ]]; then
        if [[ "$current_state" == "charging" ]]; then
            notify -device-added 'Charger Plugged' --icon ~/.config/dunst/icons/random/hippo.svg &
        elif [[ "$current_state" == "discharging" ]]; then
            notify -device-removed 'Charger Unplugged' --icon ~/.config/dunst/icons/random/hippo.svg &
        fi
        prev_state="$current_state"
    fi
done
