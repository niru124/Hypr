#!/bin/bash

if [[ -f /tmp/hypr_prev_workspace ]]; then
    prev=$(cat /tmp/hypr_prev_workspace)
    curr=$(hyprctl activeworkspace -j | jq -r '.id')

    # Only toggle if not already on that workspace
    if [[ "$prev" != "$curr" ]]; then
        hyprctl dispatch workspace "$prev"
    fi
fi

