#!/bin/bash

LINK=$(iw dev wlan0 link 2>/dev/null)

if [[ "$LINK" == "Not connected" ]]; then
    echo "{\"text\": \"<span foreground='#6c7086' font_size='120%'>󰤭</span>\", \"class\": \"off\"}"
    exit 0
fi

SIGNAL_DBM=$(echo "$LINK" | grep "signal:" | awk '{print $2}' | tr -d 'dBm')
SIGNAL=$((100 + SIGNAL_DBM))

if [[ "$SIGNAL" -le 20 ]]; then
    echo "{\"text\": \"<span foreground='#f38ba8' font_size='120%'>󰤯 </span>\", \"class\": \"poor\"}"
elif [[ "$SIGNAL" -le 40 ]]; then
    echo "{\"text\": \"<span foreground='#fab387' font_size='120%'>󰤟 </span>\", \"class\": \"weak\"}"
elif [[ "$SIGNAL" -le 60 ]]; then
    echo "{\"text\": \"<span foreground='#f9e2af' font_size='120%'>󰤢 </span>\", \"class\": \"fair\"}"
elif [[ "$SIGNAL" -le 80 ]]; then
    echo "{\"text\": \"<span foreground='#a6e3a1' font_size='120%'>󰤥 </span>\", \"class\": \"good\"}"
else
    echo "{\"text\": \"<span foreground='#a6e3a1' font_size='120%'>󰤨 </span>\", \"class\": \"excellent\"}"
fi
