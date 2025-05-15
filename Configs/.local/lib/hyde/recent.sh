#!/bin/bash

prev=""
curr=""

# Start by setting the current workspace
curr=$(hyprctl activeworkspace -j | jq -r '.id')

# Listen for workspace change events
hyprctl -j activeworkspace | jq -r '.id' > /tmp/hypr_curr_workspace

hyprctl --batch 'sub workspace' | while read -r _; do
    new=$(hyprctl activeworkspace -j | jq -r '.id')
    
    # If workspace actually changed
    if [[ "$new" != "$curr" ]]; then
        echo "$curr" > /tmp/hypr_prev_workspace
        echo "$new" > /tmp/hypr_curr_workspace
        curr="$new"
    fi
done
