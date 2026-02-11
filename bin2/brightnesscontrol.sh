#!/usr/bin/env sh

# Check if the script is already running
pgrep -cf "${0##*/}" | grep -qv 1 && echo "An instance of the script is already running..." && exit 1

scrDir=`dirname "$(realpath "$0")"`
source $scrDir/globalcontrol.sh

# File to store selected monitor
selected_monitor_file="${XDG_RUNTIME_DIR:-/tmp}/brightness_monitor"

# Check if SwayOSD is installed
use_swayosd=false
if command -v swayosd-client >/dev/null 2>&1 && pgrep -x swayosd-server >/dev/null; then
    use_swayosd=true
fi

print_error()
{
cat << EOF
    $(basename ${0}) <action> [step] [mode]
    ...valid actions are...
        i -- <i>ncrease brightness [+5%]
        d -- <d>ecrease brightness [-5%]
        s -- <s>elect monitor via rofi

    Example:
        $(basename ${0}) i 10    # Increase brightness by 10%
        $(basename ${0}) d       # Decrease brightness by default step (5%)
        $(basename ${0}) i 5 -q  # Increase brightness by 5% quietly
        $(basename ${0}) i -s    # Increase brightness with monitor selection
EOF
}
notify="${waybar_brightness_notification:-true}"  # Default: notifications are enabled
action=""     # Will store 'increase' or 'decrease'
step=5        # Default step value
select_monitor=false

# Parse all arguments
for arg in "$@"; do
    case $arg in
        i|-i)
            [ -n "$action" ] &&
                {
                    echo -e "\033[38;2;255;0;0mOne or more actions are provided\033[0m";
                    print_error;
                    exit 1;
                }
            action="increase" ;;
        d|-d)
            [ -n "$action" ] &&
                {
                    echo -e "\033[38;2;255;0;0mOne or more actions are provided\033[0m";
                    print_error;
                    exit 1;
                }
            action="decrease" ;;
        q|-q)
            notify=false ;;
        s|-s)
            select_monitor=true ;;
        [0-9]*)
            if ! echo "$arg" | grep -Eq '^[0-9]+$'; then
                print_error
                exit 1
            fi
            step=$arg ;;
        *)
            print_error && exit 1 ;;
    esac
done

if [ -z "$action" ]; then
    echo -e "\033[38;2;255;0;0mActions are not provided\033[0m"
    print_error
    exit 1
fi

# Get list of monitors using hyprctl
monitor_selection() {
    if ! command -v hyprctl >/dev/null 2>&1; then
        return ""
    fi

    monitor_count=$(hyprctl monitors | grep -c "Monitor")

    if [ "$monitor_count" -le 1 ]; then
        return ""
    fi

    monitors=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

    selected_monitor=$(echo "$monitors" | rofi -dmenu -p "Select monitor to adjust brightness" --theme "$(~/.config/rofi/wifi-theme.rasi)"2>/dev/null)

    if [ -z "$selected_monitor" ]; then
        echo "No monitor selected..."
        exit 1
    fi

    echo "$selected_monitor"
}

is_external_monitor() {
    local monitor_name="$1"
    case "$monitor_name" in
        HDMI-*|DP-*|DVI-*|*HDMI*|*DP*|*DVI*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

has_internal_monitor() {
    if ! command -v hyprctl >/dev/null 2>&1; then
        return 1
    fi

    monitors=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')
    for monitor in $monitors; do
        if ! is_external_monitor "$monitor"; then
            return 0
        fi
    done
    return 1
}

# Determine target device for brightness control
if [ "$select_monitor" = true ]; then
    selected_monitor=$(monitor_selection)
    if [ -n "$selected_monitor" ]; then
        echo "$selected_monitor" > "$selected_monitor_file"
    fi
else
    if [ -f "$selected_monitor_file" ]; then
        selected_monitor=$(cat "$selected_monitor_file")
        if command -v hyprctl >/dev/null 2>&1; then
            if ! hyprctl monitors | grep -q "$selected_monitor"; then
                selected_monitor=""
            fi
        fi
    fi

    if [ -z "$selected_monitor" ]; then
        if command -v hyprctl >/dev/null 2>&1; then
            monitor_count=$(hyprctl monitors | grep -c "Monitor")
            if [ "$monitor_count" -eq 1 ]; then
                selected_monitor=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')
                echo "$selected_monitor" > "$selected_monitor_file" 2>/dev/null
            else
                selected_monitor=$(monitor_selection)
                if [ -n "$selected_monitor" ]; then
                    echo "$selected_monitor" > "$selected_monitor_file"
                fi
            fi
        else
            selected_monitor=$(monitor_selection)
            if [ -n "$selected_monitor" ]; then
                echo "$selected_monitor" > "$selected_monitor_file"
            fi
        fi
    fi
fi

if [ -n "$selected_monitor" ]; then
    if is_external_monitor "$selected_monitor"; then
        control_method="ddcutil"
    else
        control_method="brightnessctl"
        device_flag="-m $selected_monitor"
    fi
else
    control_method="brightnessctl"
    device_flag=""
fi

send_notification() {
    if [ "$control_method" = "ddcutil" ]; then
        brightness=$(ddcutil getvcp 0x10 2>/dev/null | grep -oP "current value =\s*\K\d+")
        brightinfo="$selected_monitor"
    else
        brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)")
        brightinfo=$(brightnessctl info | awk -F "'" '/Device/ {print $2}')
    fi
    angle=$(( (((brightness + 2) / 5) * 5) ))
    ico="$HOME/.config/dunst/icons/vol/vol-${angle}.svg"
    bar=$(printf '#%.0s' $(seq 1 $((brightness / 15))) 2>/dev/null || echo "")

    notify -normal --app-name "t2" -r 91190 --notify-opts "-t 800 -i ${ico}" "${brightness}% Bright" -audio-volume-change
}

get_brightness() {
    if [ "$control_method" = "ddcutil" ]; then
        ddcutil getvcp 0x10 2>/dev/null | grep -oP "current value =\s*\K\d+"
    else
        brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
    fi
}

case $action in
increase)
    if [[ $(get_brightness) -lt 10 ]] ; then
        step=1
    fi

    $use_swayosd && swayosd-client --brightness raise "$step" && exit 0

    if [ "$control_method" = "ddcutil" ]; then
        ddcutil setvcp 0x10 + $step 2>/dev/null
    else
        brightnessctl $device_flag set +${step}%
    fi

    [ "$notify" = true ] && send_notification ;;
decrease)

    if [[ $(get_brightness) -le 10 ]] ; then
        step=1
    fi

    if [[ $(get_brightness) -le 1 ]]; then
        if [ "$control_method" = "ddcutil" ]; then
            ddcutil setvcp 0x10 - $step 2>/dev/null
        else
            brightnessctl $device_flag set ${step}%
        fi
        $use_swayosd && exit 0
    else
        $use_swayosd && swayosd-client --brightness lower "$step" && exit 0
        if [ "$control_method" = "ddcutil" ]; then
            ddcutil setvcp 0x10 - $step 2>/dev/null
        else
            brightnessctl $device_flag set ${step}%-
        fi
    fi

    [ "$notify" = true ] && send_notification ;;
esac
