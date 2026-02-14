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

get_default_sink_id() {
    wpctl status | sed 's/├/ /g; s/─/ /g; s/└/ /g; s/│/ /g' | grep -E "^\s+\*\s+[0-9]+\." | grep -v "Camera" | head -1 | awk '{print $2}' | tr -d '.'
}

get_default_source_id() {
    wpctl status | sed 's/├/ /g; s/─/ /g; s/└/ /g; s/│/ /g' | grep -E "^\s+\*\s+[0-9]+\." | grep -v "Camera" | tail -1 | awk '{print $2}' | tr -d '.'
}

get_sink_name() {
    local id=$1
    wpctl inspect "$id" 2>/dev/null | grep "node.description" | head -1 | cut -d'"' -f2
}

get_source_name() {
    local id=$1
    wpctl inspect "$id" 2>/dev/null | grep "node.description" | head -1 | cut -d'"' -f2
}

list_sinks() {
    wpctl status | sed 's/├/ /g; s/─/ /g; s/└/ /g; s/│/ /g' | grep -E "^\s+[0-9]+\.\s+" | grep -v "Camera" | awk '{$1=""; print $0}' | sed 's/^\s*//' | cut -d'[' -f1 | sed 's/\s*$//'
}

get_sink_id_by_name() {
    local name="$1"
    wpctl status | sed 's/├/ /g; s/─/ /g; s/└/ /g; s/│/ /g' | grep -E "\s+[0-9]+\.\s+.*$name" | head -1 | awk '{print $2}' | tr -d '.'
}

notify_vol() {
    vol=$(wpctl get-volume "$target_id" | awk '{print int($2 * 100)}')
    angle=$(( (($vol + 2) / 5) * 5 ))
    [ $angle -gt 100 ] && angle=100

    ico="${icodir}/vol-${angle}.svg"
    bar=$(seq -s $(($vol / 15)) | sed 's/[0-9]//g')
    notify -normal --app-name "t2" -r 91190 --notify-opts "-t 800 -i ${ico}" "${vol}${bar} Volume" -audio-volume-change
}

notify_mute() {
    [ "${target_type}" = "source" ] && dvce="mic" || dvce="speaker"
    muted=$(wpctl get-volume "$target_id" 2>&1 | grep -i "muted")
    if [ -n "$muted" ]; then
        notify-send -a "t2" -r 91190 -t 800 -i "${icodir}/muted-${dvce}.svg" "muted" "${nsink}"
    else
        notify-send -a "t2" -r 91190 -t 800 -i "${icodir}/unmuted-${dvce}.svg" "unmuted" "${nsink}"
    fi
}

change_volume() {
    local action=$1
    local step=$2
    local device=$3
    local suffix=""

    [ "${action}" = "i" ] && suffix="+"
    [ "${action}" = "d" ] && suffix="-"

    case $device in
        "wpctl")            
            $use_swayosd && wpctl set-volume "$target_id" "${step}%${suffix}" 2>/dev/null && exit 0
            wpctl set-volume "$target_id" "${step}%${suffix}"
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
        "wpctl") 
            $use_swayosd && wpctl set-mute "$target_id" toggle 2>/dev/null && exit 0
            wpctl set-mute "$target_id" toggle
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
        sink_id=$(get_sink_id_by_name "$selection")
        if wpctl set-default "$sink_id" 2>/dev/null; then
            notify-send -t 2000 -r 2 -u low "Activated: $selection"
        else
            notify-send -t 2000 -r 2 -u critical "Error activating $selection"
        fi
    else
        list_sinks
    fi
}

toggle_output() {
    local default_sink=$(get_sink_name "$(get_default_sink_id)")
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
        i) device="wpctl"; target_type="source"; target_id=$(get_default_source_id); nsink=$(get_source_name "$target_id") ;;
        o) device="wpctl"; target_type="sink"; target_id=$(get_default_sink_id); nsink=$(get_sink_name "$target_id") ;;
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
