#!/usr/bin/env bash

HIS=${HYPRLAND_INSTANCE_SIGNATURE:-$(ls $XDG_RUNTIME_DIR/hypr | head -1)}
SOCKET="$XDG_RUNTIME_DIR/hypr/$HIS/.socket2.sock"

get_layout() {
    hyprctl getoption general:layout 2>/dev/null | grep -oP "str: \K\w+" || echo ""
}

format_output() {
    local mode="$1"
    local overview="$2"
    if [[ "$overview" == "1" ]]; then
        echo "{\"text\": \"${mode} OV\", \"tooltip\": \"Mode: ${mode}, Overview: ON\"}"
    else
        echo "{\"text\": \"${mode}\", \"tooltip\": \"Mode: ${mode}\"}"
    fi
}

last_mode="row"
last_overview="0"

output_status() {
    current_layout=$(get_layout)
    if [[ "$current_layout" == "scroller" ]]; then
        format_output "$last_mode" "$last_overview"
    else
        echo "{\"text\": \"\", \"tooltip\": \"Not using scroller\"}"
    fi
}

trap 'output_status' RTMIN

tail -f "$SOCKET" 2>/dev/null | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)
    data=$(echo "$line" | cut -d'>' -f2)
    
    if [[ "$event" == "scroller" ]]; then
        if [[ "$data" == mode,* ]]; then
            last_mode=$(echo "$data" | cut -d',' -f2 | tr -d ' ')
        elif [[ "$data" == overview,* ]]; then
            last_overview=$(echo "$data" | cut -d',' -f2 | tr -d ' ')
        fi
    fi
    output_status
done &
SOCKET_PID=$!

output_status

while true; do
    sleep 5
    output_status
done
