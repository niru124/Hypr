#!/bin/bash

THEME="$HOME/.config/rofi/timer.rasi"
ICON="$HOME/.config/dunst/icons/timer.svg"
STOPWATCH_PID="/tmp/rofi_stopwatch.pid"
STOPWATCH_START="/tmp/rofi_stopwatch.start"
STOPWATCH_LABEL="/tmp/rofi_stopwatch.label"
HISTORY_FILE="$HOME/.timer_history.csv"

CHOICE=$(printf "Timer\nAlarm\nStopwatch\nResume Recent\nDelete Recent" | rofi -dmenu -p "Set:" -theme "$THEME")
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
        START=$(cat "$STOPWATCH_START")
        NOW=$(date +%s)
        ELAPSED=$((NOW - START))
        LABEL=$(cat "$STOPWATCH_LABEL")
        DATE=$(date '+%Y-%m-%d %H:%M:%S')
        echo "Stopwatch,$LABEL,${ELAPSED}s,$DATE" >> "$HISTORY_FILE"
        rm -f "$STOPWATCH_PID" "$STOPWATCH_START" "$STOPWATCH_LABEL"

        notify-send \
            -a "Stopwatch" \
            -r "$notify_id" \
            -t 3000 \
            -i "$ICON" \
            "Stopwatch '$LABEL' Stopped: ${ELAPSED}s"
    fi
}

if [ "$CHOICE" == "Resume Recent" ]; then
    if [ ! -f "$HISTORY_FILE" ]; then
        notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "No recent timers found"
        exit
    fi
    RECENTS=$(tail -10 "$HISTORY_FILE" | awk -F',' '{print $2 ": " $3 " (" $1 ")"}' | tac)
    SELECTED=$(printf "$RECENTS" | rofi -dmenu -p "Resume:" -theme "$THEME")
    [ -z "$SELECTED" ] && exit
    LABEL=$(echo "$SELECTED" | cut -d':' -f1)
    REST=$(echo "$SELECTED" | cut -d':' -f2- | sed 's/^ //')
    VALUE=$(echo "$REST" | cut -d'(' -f1 | sed 's/ $//')
    TYPE=$(echo "$REST" | cut -d'(' -f2 | cut -d')' -f1)
    if [ "$TYPE" == "Timer" ]; then
        timeout --foreground "$VALUE" sleep "$VALUE" 3>/dev/null
        DATE=$(date '+%Y-%m-%d %H:%M:%S')
        echo "Timer,$LABEL,$VALUE,$DATE" >> "$HISTORY_FILE"
        MESSAGE="Your resumed $VALUE timer '$LABEL' has ended!"
    elif [ "$TYPE" == "Alarm" ]; then
        NOW=$(date +%s)
        TARGET=$(date -d "$VALUE" +%s 2>/dev/null)
        if [ "$TARGET" -le "$NOW" ]; then
            TARGET=$(date -d "tomorrow $VALUE" +%s)
        fi
        sleep $((TARGET - NOW))
        DATE=$(date '+%Y-%m-%d %H:%M:%S')
        echo "Alarm,$LABEL,$VALUE,$DATE" >> "$HISTORY_FILE"
        MESSAGE="Resumed alarm for $VALUE '$LABEL' triggered!"
    elif [ "$TYPE" == "Stopwatch" ]; then
        echo "$LABEL" > "$STOPWATCH_LABEL"
        start_stopwatch
        exit
    fi
elif [ "$CHOICE" == "Delete Recent" ]; then
    if [ ! -f "$HISTORY_FILE" ]; then
        notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "No recent timers found"
        exit
    fi
    RECENTS=$(tail -10 "$HISTORY_FILE" | awk -F',' '{print $2 ": " $3 " (" $1 ")"}' | tac)
    if [ -z "$RECENTS" ]; then
        notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "No recent timers found"
        exit
    fi
    SELECTED=$(printf "$RECENTS" | rofi -dmenu -p "Delete:" -theme "$THEME")
    [ -z "$SELECTED" ] && exit
    CONFIRM=$(printf "Yes\nNo" | rofi -dmenu -p "Delete '$SELECTED'?" -theme "$THEME")
    [ "$CONFIRM" != "Yes" ] && exit
    # Parse
    LABEL=$(echo "$SELECTED" | cut -d':' -f1)
    REST=$(echo "$SELECTED" | cut -d':' -f2- | sed 's/^ //')
    VALUE=$(echo "$REST" | cut -d'(' -f1 | sed 's/ $//')
    TYPE=$(echo "$REST" | cut -d'(' -f2 | cut -d')' -f1)
    # Find the line number to delete
    TOTAL=$(wc -l < "$HISTORY_FILE")
    RECENTS_ARRAY=()
    while IFS= read -r line; do
        RECENTS_ARRAY+=("$line")
    done <<< "$RECENTS"
    for i in "${!RECENTS_ARRAY[@]}"; do
        if [ "${RECENTS_ARRAY[i]}" == "$SELECTED" ]; then
            N=$((i + 1))
            break
        fi
    done
    LINE_TO_DELETE=$((TOTAL - (N - 1)))
    sed -i "${LINE_TO_DELETE}d" "$HISTORY_FILE"
    notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Deleted: $SELECTED"
    exit
elif [ "$CHOICE" == "Timer" ]; then
    LABEL=$(rofi -dmenu -p "Label for timer:" -theme "$THEME")
    [ -z "$LABEL" ] && exit
    TIME=$(rofi -dmenu -p "Set timer (e.g. 10m, 30s, 1h):" -theme "$THEME")
    [ -z "$TIME" ] && exit

    timeout --foreground "$TIME" sleep "$TIME" 3>/dev/null
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Timer,$LABEL,$TIME,$DATE" >> "$HISTORY_FILE"
    MESSAGE="Your $TIME timer '$LABEL' has ended!"

elif [ "$CHOICE" == "Alarm" ]; then
    LABEL=$(rofi -dmenu -p "Label for alarm:" -theme "$THEME")
    [ -z "$LABEL" ] && exit
    ALARM_TIME=$(rofi -dmenu -p "Set alarm time (e.g. 19:45):" -theme "$THEME")
    [ -z "$ALARM_TIME" ] && exit

    NOW=$(date +%s)
    TARGET=$(date -d "$ALARM_TIME" +%s 2>/dev/null)

    if [ "$TARGET" -le "$NOW" ]; then
        TARGET=$(date -d "tomorrow $ALARM_TIME" +%s)
    fi

    sleep $((TARGET - NOW))
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Alarm,$LABEL,$ALARM_TIME,$DATE" >> "$HISTORY_FILE"
    MESSAGE="Alarm for $ALARM_TIME '$LABEL' triggered!"

elif [ "$CHOICE" == "Stopwatch" ]; then
    if [ -f "$STOPWATCH_PID" ] && kill -0 "$(cat "$STOPWATCH_PID")" 2>/dev/null; then
        ACTION=$(printf "Stop Stopwatch\nCancel" | rofi -dmenu -p "Stopwatch already running:" -theme "$THEME")
        [ "$ACTION" == "Stop Stopwatch" ] && stop_stopwatch
        exit
    else
        LABEL=$(rofi -dmenu -p "Label for stopwatch:" -theme "$THEME")
        [ -z "$LABEL" ] && exit
        echo "$LABEL" > "$STOPWATCH_LABEL"
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

