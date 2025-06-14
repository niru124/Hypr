#!/bin/bash

# Get connected monitors
monitors=$(hyprctl monitors -j | jq -r '.[].name')

# Disable internal display and enable external
for m in $monitors; do
    if [[ "$m" == "eDP-1" ]]; then
        hyprctl dispatch dpms off "$m"
        hyprctl dispatch keyword "monitor" "$m,disable"
    else
        hyprctl dispatch keyword "monitor" "$m,preferred,auto,1"
    fi
done
