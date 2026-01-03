#!/bin/bash

THEME="$HOME/.config/rofi/timer.rasi"
ICON="$HOME/.config/dunst/icons/timer.svg"
STOPWATCH_PID="/tmp/rofi_stopwatch.pid"
STOPWATCH_START="/tmp/rofi_stopwatch.start"

CHOICE=$(printf "Timer\nAlarm\nStopwatch" | rofi -dmenu -p "Set:" -theme "$THEME")
[ -z "$CHOICE" ] && exit

notify_id=9999

start_stopwatch() {
    date +%s > "$STOPWATCH_START"

    (
        while true; do
            START=$(cat "$STOPWATCH_START")
            NOW=$(date +%s)
            ELAPSED=$((NOW - START))

            H=$((ELAPSED / 3600))
            M=$(((ELAPSED % 3600) / 60))
            S=$((ELAPSED % 60))

            TIME_FMT=$(printf "%02d:%02d:%02d" "$H" "$M" "$S")

            notify-send \
                -a "Stopwatch" \
                -r "$notify_id" \
                -t 1100 \
                -i "$ICON" \
                "Stopwatch Running" \
                "$TIME_FMT"

            sleep 1
        done
    ) &

    echo $! > "$STOPWATCH_PID"
}

stop_stopwatch() {
    if [ -f "$STOPWATCH_PID" ]; then
        kill "$(cat "$STOPWATCH_PID")" 2>/dev/null
        rm -f "$STOPWATCH_PID" "$STOPWATCH_START"

        notify-send \
            -a "Stopwatch" \
            -r "$notify_id" \
            -t 3000 \
            -i "$ICON" \
            "Stopwatch Stopped"
    fi
}

if [ "$CHOICE" == "Timer" ]; then
    TIME=$(rofi -dmenu -p "Set timer (e.g. 10m, 30s, 1h):" -theme "$THEME")
    [ -z "$TIME" ] && exit

    timeout --foreground "$TIME" sleep "$TIME" 3>/dev/null
    MESSAGE="Your $TIME timer has ended!"

elif [ "$CHOICE" == "Alarm" ]; then
    ALARM_TIME=$(rofi -dmenu -p "Set alarm time (e.g. 19:45):" -theme "$THEME")
    [ -z "$ALARM_TIME" ] && exit

    NOW=$(date +%s)
    TARGET=$(date -d "$ALARM_TIME" +%s 2>/dev/null)

    if [ "$TARGET" -le "$NOW" ]; then
        TARGET=$(date -d "tomorrow $ALARM_TIME" +%s)
    fi

    sleep $((TARGET - NOW))
    MESSAGE="Alarm for $ALARM_TIME triggered!"

elif [ "$CHOICE" == "Stopwatch" ]; then
    if [ -f "$STOPWATCH_PID" ] && kill -0 "$(cat "$STOPWATCH_PID")" 2>/dev/null; then
        ACTION=$(printf "Stop Stopwatch\nCancel" | rofi -dmenu -p "Stopwatch already running:" -theme "$THEME")
        [ "$ACTION" == "Stop Stopwatch" ] && stop_stopwatch
        exit
    else
        start_stopwatch
        exit
    fi
else
    exit
fi

notify -normal \
       --app-name "Timer" \
       --replace-id "$notify_id" \
       --notify-opts "-t 5000 -i \"$ICON\"" \
       "$MESSAGE" \
       -alarm-clock-elapsed

