#!/bin/bash

BLUE_BLOCKED=$(rfkill list bluetooth | grep -E "blocked:" | awk '{print $3}' | head -1)

if [[ "$BLUE_BLOCKED" == "no" ]]; then
    echo "{\"text\": \"<span foreground='#99ffdd' font_size='120%' font_weight='bold'>󰂯</span>\", \"class\": \"on\"}"
else
    echo "{\"text\": \"<span foreground='#9399b2' font_size='120%'>󰂯</span>\", \"class\": \"off\"}"
fi
