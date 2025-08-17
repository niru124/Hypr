#!/bin/bash

# Prompt user for timer duration
TIME=$(rofi -dmenu -p "Set timer (e.g. 10m, 30s, 1h):" -theme ~/.config/rofi/timer.rasi)

# Exit if input is empty
[ -z "$TIME" ] && exit

# Wait for the specified duration
timeout --foreground "$TIME" sleep "$TIME" 3>/dev/null

# Notification icon path
ICON="$HOME/.config/dunst/icons/timer.svg"

# Notification message
MESSAGE="Your $TIME timer has ended!"

# Send notification using custom 'notify' script with sound
notify -normal \
       --app-name "Timer" \
       --replace-id 9999 \
       --notify-opts "-t 5000 -i \"$ICON\"" \
       "$MESSAGE" \
       -alarm-clock-elapsed
