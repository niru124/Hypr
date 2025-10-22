#!/bin/bash

current_layout=$(hyprctl getoption general:layout -j | jq -r .str)

if [ "$current_layout" = "dwindle" ]; then
    hyprctl keyword general:layout scroller
else
    hyprctl keyword general:layout dwindle
fi
