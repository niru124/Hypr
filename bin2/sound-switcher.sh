#!/usr/bin/env sh
LANG="en_US.utf8"
IFS=$'\n'

notify() {
    if command -v notify-send > /dev/null 2>&1; then
        notify-send "$@"
    elif command -v dunstify > /dev/null 2>&1; then
        dunstify "$@"
    fi
}

list_card_profiles() {
    pactl list cards | awk -v RS='Card #' -v name="$1" '
        index($0, name) {
            n = split($0, lines, "\n")
            for (i = 1; i <= n; i++) {
                line = lines[i]
                sub(/^[ \t]+/, "", line)
                if (line ~ /\(sinks:/ && line ~ /: / && line ~ /available: yes/) {
                    gsub(/^[^:]+: /, "", line)
                    gsub(/ \(sinks:.*/, "", line)
                    print name ": " line
                }
            }
        }'
}

if [ $# -gt 0 ]; then
    desc="$*"

    card_name=$(echo "$desc" | sed -n 's/^\(.*\): .*$/\1/p')
    profile_desc=$(echo "$desc" | sed -n 's/^.*: \(.*\)$/\1/p')

    if [ -n "$card_name" ] && [ -n "$profile_desc" ]; then
        info=$(pactl list cards | awk -v RS='Card #' -v pat="$card_name" 'index($0, pat)')
        card=$(echo "$info" | sed -n 's/^\s*Name: //p')
        profile=$(echo "$info" | awk -v desc="$profile_desc" '
            /\(sinks:/ && /: / && /available: yes/ {
                line = $0
                gsub(/^\s+/, "", line)
                idx = index(line, ": ")
                if (idx > 0) {
                    prof = substr(line, 1, idx - 1)
                    rest = substr(line, idx + 2)
                    gsub(/ \(sinks:.*/, "", rest)
                    if (rest == desc) {
                        print prof
                        exit
                    }
                }
            }')
        if [ -n "$card" ] && [ -n "$profile" ] && pactl set-card-profile "$card" "$profile"; then
            notify -t 2000 -r 2 -u low "Activated: $profile_desc"
            exit 0
        fi
        notify -t 2000 -r 2 -u critical "Error activating $desc"
        exit 1
    fi

    # Fall back to sink switch (Bluetooth etc.)
    device=$(pactl list sinks | grep -B1 "Description: $desc" | grep "Name:" | cut -d: -f2- | xargs)
    if [ -n "$device" ] && pactl set-default-sink "$device"; then
        notify -t 2000 -r 2 -u low "Activated: $desc"
        exit 0
    fi
    notify -t 2000 -r 2 -u critical "Error activating $desc"
    exit 1
else
    echo -en "\x00prompt\x1fSelect Output\n"

    for card in "Ryzen HD Audio Controller" "HDA NVidia"; do
        list_card_profiles "$card"
    done

    pactl list sinks | grep -ie "Description:" | cut -d: -f2- | sed 's/^ //' | sort -u
fi
