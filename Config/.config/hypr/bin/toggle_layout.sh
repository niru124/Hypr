#!/bin/bash

current_layout=$(hyprctl getoption general:layout -j | jq -r .str)

if [ "$current_layout" = "dwindle" ]; then
    hyprctl eval 'hl.config({ general = { layout = "scrolling" } })'
    notify-send "Layout" "Switched to Scrolling" -i preferences-desktop
else
    hyprctl eval 'hl.config({ general = { layout = "dwindle" } })'
    notify-send "Layout" "Switched to Dwindle" -i preferences-desktop
fi
