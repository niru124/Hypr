 #!/usr/bin/env sh
LANG="en_US.utf8"
IFS=$'\n'

if command -v notify-send > /dev/null 2>&1; then
    SEND="notify-send"
elif command -v dunstify > /dev/null 2>&1; then
    SEND="dunstify"
else
    SEND="/bin/false"
fi

if [ "$@" ]; then
    desc="$*"
    device=$(pactl list sinks | grep -B1 "Description: $desc" | grep "Name:" | cut -d: -f2- | xargs)
    if pactl set-default-sink "$device"; then
        $SEND -t 2000 -r 2 -u low "Activated: $desc"
    else
        $SEND -t 2000 -r 2 -u critical "Error activating $desc"
    fi
else
    echo -en "\x00prompt\x1fSelect Output\n"
    for x in $(pactl list sinks | grep -ie "Description:" | cut -d: -f2 | sort); do
        echo "$x" | xargs
    done
fi
