#!/bin/bash
# Timer / Alarm / Stopwatch via rofi + notify-send. History in CSV.

THEME="$HOME/.config/rofi/timer.rasi"
ICON="$HOME/.config/dunst/icons/timer.svg"
STOPWATCH_PID="/tmp/rofi_stopwatch.pid"
STOPWATCH_START="/tmp/rofi_stopwatch.start"
STOPWATCH_LABEL="/tmp/rofi_stopwatch.label"
HISTORY_FILE="$HOME/.timer_history.csv"
MAX_HISTORY=200
notify_id=9999

# --- helpers ---------------------------------------------------------------

# Valid durations for sleep/timeout: number + optional s/m/h/d suffix.
valid_duration() { [[ "$1" =~ ^[0-9]+[smhd]?$ ]]; }

# Parse "HH:MM" (or anything date understands) to epoch. Echoes epoch or nothing.
to_epoch() { date -d "$1" +%s 2>/dev/null; }

# Append a history row and cap file size.
log_history() {
    printf '%s,%s,%s,%s\n' "$1" "$2" "$3" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$HISTORY_FILE"
    tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

# Last up-to-10 CSV rows are read inside pick_recent (it must run in the
# caller's shell for globals... instead everything crosses via stdout).
# Usage: pick=$(pick_recent "Resume:") || exit
#   -> prints "absline<US>type<US>label<US>value" (US = \x1f)
pick_recent() {
    local rows=() line
    [ -f "$HISTORY_FILE" ] || return 1
    while IFS= read -r line; do
        [ -n "$line" ] && rows+=("$line")
    done < <(tail -10 "$HISTORY_FILE")
    [ "${#rows[@]}" -eq 0 ] && return 1
    local total menu i type label value
    total=$(wc -l < "$HISTORY_FILE")
    local start=$((total - ${#rows[@]} + 1))
    menu=""
    for (( i=${#rows[@]}-1; i>=0; i-- )); do
        IFS=',' read -r type label value _ <<< "${rows[i]}"
        menu+="$(( ${#rows[@]}-i )). ${label} — ${value} (${type})"$'\n'
    done
    local sel n
    sel=$(printf '%s' "$menu" | rofi -dmenu -p "$1" -theme "$THEME") || return 1
    [ -z "$sel" ] && return 1
    [[ "$sel" =~ ^([0-9]+)\. ]] || return 1
    n="${BASH_REMATCH[1]}"
    local ridx=$(( ${#rows[@]} - n ))
    [ "$ridx" -ge 0 ] && [ "$ridx" -lt "${#rows[@]}" ] || return 1
    IFS=',' read -r type label value _ <<< "${rows[ridx]}"
    printf '%s\x1f%s\x1f%s\x1f%s' "$((start + ridx))" "$type" "$label" "$value"
}

FRAMES_DIR="$HOME/.config/dunst/icons/timer-frames"
ALARM_SOUND="/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
SPIN_SECONDS=30

# Spin the hourglass on the finished-notification (same replace-id, so it
# updates in place) with the alarm sound repeating alongside, for SPIN_SECONDS.
play_done_animation() {
    local msg="$1" end=$(( $(date +%s) + SPIN_SECONDS )) i f sndpid
    [ -d "$FRAMES_DIR" ] || return 0
    (
        while [ "$(date +%s)" -lt "$end" ]; do
            if command -v mpv >/dev/null 2>&1; then
                mpv --really-quiet "$ALARM_SOUND" 2>/dev/null
            else
                paplay "$ALARM_SOUND" 2>/dev/null
            fi
            sleep 3
        done
    ) &
    sndpid=$!
    i=0
    while [ "$(date +%s)" -lt "$end" ]; do
        f=$(printf "%s/frame-%02d.png" "$FRAMES_DIR" "$((i % 12))")
        [ -f "$f" ] && notify-send -a "Timer" -r "$notify_id" -t 600 -i "$f" "$msg" 2>/dev/null
        sleep 0.15
        i=$((i + 1))
    done
    kill "$sndpid" 2>/dev/null
    wait "$sndpid" 2>/dev/null
}

stopwatch_running() {
    [ -f "$STOPWATCH_PID" ] && kill -0 "$(cat "$STOPWATCH_PID")" 2>/dev/null
}

# --- stopwatch --------------------------------------------------------------

start_stopwatch() {
    # Optional $1 = already-elapsed seconds (resume keeps counting from there).
    local offset=${1:-0}
    echo $(($(date +%s) - offset)) > "$STOPWATCH_START"
    (
        while true; do
            ELAPSED=$(($(date +%s) - $(cat "$STOPWATCH_START")))
            TIME_FMT=$(printf "%02d:%02d:%02d" $((ELAPSED/3600)) $(((ELAPSED%3600)/60)) $((ELAPSED%60)))
            notify-send -a "Stopwatch" -r "$notify_id" -t 1100 \
                "Stopwatch Running" "$TIME_FMT"
            sleep 1
        done
    ) &
    echo $! > "$STOPWATCH_PID"
}

stop_stopwatch() {
    stopwatch_running || return
    kill "$(cat "$STOPWATCH_PID")" 2>/dev/null
    local start now elapsed label
    start=$(cat "$STOPWATCH_START" 2>/dev/null); start=${start:-$(date +%s)}
    now=$(date +%s)
    elapsed=$((now - start))
    label=$(cat "$STOPWATCH_LABEL" 2>/dev/null); label=${label:-untitled}
    rm -f "$STOPWATCH_PID" "$STOPWATCH_START" "$STOPWATCH_LABEL"
    log_history "Stopwatch" "$label" "${elapsed}s"
    notify-send -a "Stopwatch" -r "$notify_id" -t 3000 \
        "Stopwatch '$label' Stopped: ${elapsed}s"
}

# --- main menu ---------------------------------------------------------------

CHOICE=$(printf "Timer\nAlarm\nStopwatch\nResume Recent\nDelete Recent" | rofi -dmenu -p "Set:" -theme "$THEME")
[ -z "$CHOICE" ] && exit

if [ "$CHOICE" == "Resume Recent" ]; then
    pick=$(pick_recent "Resume:") || exit
    IFS=$'\x1f' read -r _ TYPE LABEL VALUE <<< "$pick"
    if [ "$TYPE" == "Timer" ]; then
        valid_duration "$VALUE" || { notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Bad saved duration: $VALUE"; exit 1; }
        notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Timer resumed" "'$LABEL' — $VALUE remaining"
        timeout --foreground "$VALUE" sleep "$VALUE"
        log_history "Timer" "$LABEL" "$VALUE"
        MESSAGE="Your resumed $VALUE timer '$LABEL' has ended!"
    elif [ "$TYPE" == "Alarm" ]; then
        NOW=$(date +%s)
        TARGET=$(to_epoch "$VALUE")
        [ -z "$TARGET" ] && { notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Bad saved alarm time: $VALUE"; exit 1; }
        [ "$TARGET" -le "$NOW" ] && TARGET=$(to_epoch "tomorrow $VALUE")
        sleep $((TARGET - NOW))
        log_history "Alarm" "$LABEL" "$VALUE"
        MESSAGE="Resumed alarm for $VALUE '$LABEL' triggered!"
    elif [ "$TYPE" == "Stopwatch" ]; then
        # Resume from the stopped value (history stores e.g. "83s").
        offset=0
        [[ "$VALUE" =~ ^([0-9]+)s$ ]] && offset="${BASH_REMATCH[1]}"
        echo "$LABEL" > "$STOPWATCH_LABEL"
        start_stopwatch "$offset"
        exit
    fi

elif [ "$CHOICE" == "Delete Recent" ]; then
    pick=$(pick_recent "Delete:") || exit
    IFS=$'\x1f' read -r absline TYPE LABEL VALUE <<< "$pick"
    CONFIRM=$(printf "Yes\nNo" | rofi -dmenu -p "Delete '$LABEL' ($TYPE $VALUE)?" -theme "$THEME")
    [ "$CONFIRM" != "Yes" ] && exit
    sed -i "${absline}d" "$HISTORY_FILE"
    notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Deleted: $LABEL ($TYPE $VALUE)"
    exit

elif [ "$CHOICE" == "Timer" ]; then
    LABEL=$(rofi -dmenu -p "Label for timer:" -theme "$THEME")
    [ -z "$LABEL" ] && exit
    TIME=$(rofi -dmenu -p "Set timer (e.g. 10m, 30s, 1h):" -theme "$THEME")
    [ -z "$TIME" ] && exit
    if ! valid_duration "$TIME"; then
        notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Invalid duration: '$TIME' (use e.g. 10m, 30s, 1h)"
        exit 1
    fi
    timeout --foreground "$TIME" sleep "$TIME"
    log_history "Timer" "$LABEL" "$TIME"
    MESSAGE="Your $TIME timer '$LABEL' has ended!"

elif [ "$CHOICE" == "Alarm" ]; then
    LABEL=$(rofi -dmenu -p "Label for alarm:" -theme "$THEME")
    [ -z "$LABEL" ] && exit
    ALARM_TIME=$(rofi -dmenu -p "Set alarm time (e.g. 19:45):" -theme "$THEME")
    [ -z "$ALARM_TIME" ] && exit
    NOW=$(date +%s)
    TARGET=$(to_epoch "$ALARM_TIME")
    if [ -z "$TARGET" ]; then
        notify-send -a "Timer" -r "$notify_id" -t 3000 -i "$ICON" "Cannot parse alarm time: '$ALARM_TIME'"
        exit 1
    fi
    [ "$TARGET" -le "$NOW" ] && TARGET=$(to_epoch "tomorrow $ALARM_TIME")
    sleep $((TARGET - NOW))
    log_history "Alarm" "$LABEL" "$ALARM_TIME"
    MESSAGE="Alarm for $ALARM_TIME '$LABEL' triggered!"

elif [ "$CHOICE" == "Stopwatch" ]; then
    if stopwatch_running; then
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

play_done_animation "$MESSAGE"

notify -normal \
       --app-name "Timer" \
       --replace-id "$notify_id" \
       --notify-opts "-t 5000 -i \"$ICON\"" \
       "$MESSAGE" \
       -alarm-clock-elapsed
