#!/bin/bash

# Ask user whether they want to set a timer or an alarm
CHOICE=$(printf "Timer\nAlarm" | rofi -dmenu -p "Set:" -theme ~/.config/rofi/timer.rasi)

# Exit if no choice
[ -z "$CHOICE" ] && exit

ICON="$HOME/.config/dunst/icons/timer.svg"

if [ "$CHOICE" == "Timer" ]; then
    # Prompt user for timer duration
    TIME=$(rofi -dmenu -p "Set timer (e.g. 10m, 30s, 1h):" -theme ~/.config/rofi/timer.rasi)
    [ -z "$TIME" ] && exit

    # Wait for the specified duration
    timeout --foreground "$TIME" sleep "$TIME" 3>/dev/null

    # Notification
    MESSAGE="Your $TIME timer has ended!"

elif [ "$CHOICE" == "Alarm" ]; then
    # Prompt user for alarm time (24h format)
    ALARM_TIME=$(rofi -dmenu -p "Set alarm time (e.g. 19:45):" -theme ~/.config/rofi/timer.rasi)
    [ -z "$ALARM_TIME" ] && exit

    # Convert to seconds until alarm
    NOW=$(date +%s)
    TARGET=$(date -d "$ALARM_TIME" +%s 2>/dev/null)

    # If target time is before now (i.e., already passed today), add 1 day
    if [ "$TARGET" -le "$NOW" ]; then
        TARGET=$(date -d "tomorrow $ALARM_TIME" +%s)
    fi

    # Seconds to wait
    DELAY=$((TARGET - NOW))

    # Sleep until the alarm time
    sleep "$DELAY"

    # Notification
    MESSAGE="Alarm for $ALARM_TIME triggered!"
else
    exit
fi

# Send notification using custom notify script
notify -normal \
       --app-name "Timer" \
       --replace-id 9999 \
       --notify-opts "-t 5000 -i \"$ICON\"" \
       "$MESSAGE" \
       -alarm-clock-elapsed

