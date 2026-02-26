#!/usr/bin/env sh

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

use_swayosd=false
if command -v swayosd-client >/dev/null 2>&1 && pgrep -x swayosd-server >/dev/null; then
    use_swayosd=true
fi

print_usage() {
    cat <<EOF
Usage: $(basename "$0") -[device] <action> [step]

Devices/Actions:
    -i    Input device
    -o    Output device
    -p    Player application
    -s    Select output device
    -t    Toggle to next output device

Actions:
    i     Increase volume
    d     Decrease volume
    m     Toggle mute

Optional:
    step  Volume change step (default: 5)

Examples:
    $(basename "$0") -o i 5     # Increase output volume by 5
    $(basename "$0") -i m       # Toggle input mute
    $(basename "$0") -p spotify d 10  # Decrease Spotify volume by 10 
    $(basename "$0") -p '' d 10  # Decrease volume by 10 for all players 

EOF
    exit 1
}

get_default_sink() {
    pactl get-default-sink
}

get_default_source() {
    pactl get-default-source
}

get_sink_name() {
    local sink=$1
    pactl list sinks | grep -A10 "^Sink #${sink}" | grep "Description:" | sed 's/.*Description: //'
}

get_source_name() {
    local source=$1
    pactl list sources | grep -A10 "^Source #${source}" | grep "Description:" | sed 's/.*Description: //'
}

list_sinks() {
    pactl list sinks short | awk '{print $2}' | while read -r sink; do
        echo "$sink" | sed 's/.*://' | sed 's/_/ /g'
    done
}

get_sink_id_by_name() {
    local name="$1"
    pactl list sinks short | grep -i "$name" | awk '{print $1}'
}

get_source_id_by_name() {
    local name="$1"
    pactl list sources short | grep -i "$name" | awk '{print $1}'
}

notify_vol() {
    vol=$(pactl get-${target_type}-volume "$target" | head -1 | awk -F'/' '{print $2}' | tr -d ' %')
    angle=$(( (($vol + 2) / 5) * 5 ))
    [ $angle -gt 100 ] && angle=100

    ico="${icodir}/vol-${angle}.svg"
    bar=$(seq -s $(($vol / 15)) | sed 's/[0-9]//g')
    notify -normal --app-name "t2" -r 91190 --notify-opts "-t 800 -i ${ico}" "${vol}${bar} Volume" -audio-volume-change
}

notify_mute() {
    [ "${target_type}" = "source" ] && dvce="mic" || dvce="speaker"
    muted=$(pactl get-${target_type}-mute "$target" | awk '{print $2}')
    if [ "$muted" = "yes" ]; then
        notify-send -a "t2" -r 91190 -t 800 -i "${icodir}/muted-${dvce}.svg" "muted" "${nsink}"
    else
        notify-send -a "t2" -r 91190 -t 800 -i "${icodir}/unmuted-${dvce}.svg" "unmuted" "${nsink}"
    fi
}

change_volume() {
    local action=$1
    local step=$2
    local device=$3
    local delta=""

    [ "${action}" = "i" ] && delta="+"
    [ "${action}" = "d" ] && delta="-"

    case $device in
        "pactl")            
            $use_swayosd && swayosd-client --${target_type}-volume "${delta}${step}%" 2>/dev/null && exit 0
            pactl set-${target_type}-volume "$target" "${delta}${step}%"
            ;;
        "playerctl")
            playerctl --player="$srce" volume "$(awk -v step="$step" 'BEGIN {print step/200}')${delta}"
            ;;
    esac
    
    notify_vol
}

toggle_mute() {
    local device=$1
    case $device in
        "pactl") 
            $use_swayosd && swayosd-client --${target_type}-volume mute-toggle 2>/dev/null && exit 0
            pactl set-${target_type}-mute "$target" toggle
            notify_mute
            ;;
        "playerctl")
            local volume_file="/tmp/$(basename "$0")_last_volume_${srce:-all}"
            if [ "$(playerctl --player="$srce" volume | awk '{ printf "%.2f", $0 }')" != "0.00" ]; then
                playerctl --player="$srce" volume | awk '{ printf "%.2f", $0 }' > "$volume_file"
                playerctl --player="$srce" volume 0
            else
                if [ -f "$volume_file" ]; then
                    last_volume=$(cat "$volume_file")
                    playerctl --player="$srce" volume "$last_volume"
                else
                    playerctl --player="$srce" volume 0.5
                fi
            fi
            notify_mute
            ;;
    esac
}

select_output() {
    local selection=$1
    if [ -n "$selection" ]; then
        sink=$(get_sink_id_by_name "$selection")
        if pactl set-default-sink "$sink"; then
            notify-send -t 2000 -r 2 -u low "Activated: $selection"
        else
            notify-send -t 2000 -r 2 -u critical "Error activating $selection"
        fi
    else
        pactl list sinks | grep -E "^Sink #|^[[:space:]]*Description:" | paste - - | sed 's/.*Description: //' | cut -d$'\t' -f1
    fi
}

toggle_output() {
    local default_sink=$(get_sink_name "$(get_default_sink)")
    mapfile -t sink_array < <(select_output)
    local current_index=$(printf '%s\n' "${sink_array[@]}" | grep -n "$default_sink" | cut -d: -f1)
    local next_index=$(( (current_index % ${#sink_array[@]}) + 1 ))
    local next_sink="${sink_array[next_index-1]}"
    select_output "$next_sink"
}

icodir="${confDir}/dunst/icons/vol"
step=5

while getopts "iop:st" opt; do
    case $opt in
        i) device="pactl"; target_type="source"; target=$(get_default_source); nsink=$(get_source_name "$target") ;;
        o) device="pactl"; target_type="sink"; target=$(get_default_sink); nsink=$(get_sink_name "$target") ;;
        p) device="playerctl"; srce="${OPTARG}"; nsink=$(playerctl --list-all | grep -w "$srce") ;;
        s) select_output "$(select_output | rofi -dmenu -config "${confDir}/rofi/notification.rasi")"; exit ;;
        t) toggle_output; exit ;;
        *) print_usage ;;
    esac
done

shift $((OPTIND-1))

[ -z "$device" ] && print_usage

case $1 in
    i|d) change_volume "$1" "${2:-$step}" "$device" ;;
    m) toggle_mute "$device" ;;
    *) print_usage ;;
esac
