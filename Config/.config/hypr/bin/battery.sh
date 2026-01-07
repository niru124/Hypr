#!/usr/bin/env bash

BAT="/sys/class/power_supply/BAT0"

[ ! -d "$BAT" ] && exit 0

battery_percentage=$(cat "$BAT/capacity")
battery_status=$(cat "$BAT/status")

battery_icons=(
	"󰂃" # 0–9
	"󰁺" # 10–19
	"󰁻" # 20–29
	"󰁼" # 30–39
	"󰁽" # 40–49
	"󰁾" # 50–59
	"󰁿" # 60–69
	"󰂀" # 70–79
	"󰂁" # 80–89
	"󰁹" # 90–100
)

charging_icon="󰂄"

icon_index=$((battery_percentage / 10))

# Clamp index to max 9 (fixes 100%)
[ "$icon_index" -gt 9 ] && icon_index=9

battery_icon="${battery_icons[$icon_index]}"

if [ "$battery_status" = "Charging" ]; then
	battery_icon="$charging_icon"
fi

echo "$battery_percentage% $battery_icon"
