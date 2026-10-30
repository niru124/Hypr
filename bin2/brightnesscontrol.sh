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

# Speed up ddcutil DDC/CI transactions. Default multiplier (1.0) is slow;
# 0.1 cuts per-call latency ~10x. Override with ddc_sleep_multiplier=0.25 etc.
ddc_args="--sleep-multiplier=${ddc_sleep_multiplier:-0.1}"
# Skip the read-back after setvcp (one less DDC round-trip). Disable with ddc_noverify=false.
[ "${ddc_noverify:-true}" = "true" ] && ddc_set_flags="--noverify"
ddc_prefix="ddcutil $ddc_args"

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

# Get list of monitors using hyprctl (sorted for stable comparison)
get_monitor_list() {
    command -v hyprctl >/dev/null 2>&1 || return 1
    hyprctl monitors | grep "Monitor" | awk '{print $2}' | sort
}

# Remember the chosen monitor along with the monitor set it belongs to
save_selection() {
    {
        echo "$1"
        echo "--"
        get_monitor_list
    } > "$selected_monitor_file" 2>/dev/null
}

# Let the user pick a monitor via rofi (auto-picks a single internal monitor)
monitor_selection() {
    monitors=$(get_monitor_list)
    [ -z "$monitors" ] && return

    monitor_count=$(echo "$monitors" | wc -l)

    has_hdmi=false
    for monitor in $monitors; do
        case "$monitor" in
            HD*)
                has_hdmi=true
                break
                ;;
        esac
    done

    if [ "$monitor_count" -le 1 ] && [ "$has_hdmi" = false ]; then
        echo "$monitors"
        return
    fi

    echo "$monitors" | rofi -dmenu -p "Select monitor to adjust brightness" -theme ~/.config/rofi/brightness.rasi 2>/dev/null
}

# Reuse the last selection unless the connected monitor set changed
resolve_monitor() {
    if [ "$select_monitor" = true ]; then
        selected=$(monitor_selection)
        [ -n "$selected" ] && save_selection "$selected"
        echo "$selected"
        return
    fi

    if [ -f "$selected_monitor_file" ]; then
        stored_mon=$(sed -n '1p' "$selected_monitor_file")
        stored_list=$(tail -n +3 "$selected_monitor_file")
        current_list=$(get_monitor_list)
        if [ -n "$stored_mon" ] && [ -n "$current_list" ] && [ "$stored_list" = "$current_list" ] \
            && printf '%s\n' "$current_list" | grep -qx "$stored_mon"; then
            echo "$stored_mon"
            return
        fi
    fi

    selected=$(monitor_selection)
    [ -n "$selected" ] && save_selection "$selected"
    echo "$selected"
}

is_external_monitor() {
    local monitor_name="$1"
    # Known internal ports first: these often contain "DP"/"HDMI" substring,
    # so they must be checked before the external patterns (e.g. "eDP-1").
    case "$monitor_name" in
        *EDP*|eDP*|*eDP*|EDP*|LVDS*|*LVDS*|DSI*|*DSI*|IDP*|*IDP*)
            return 1
            ;;
    esac
    case "$monitor_name" in
        HDMI-A-*|HDMI-*|HDMI*|*HDMI*|DP-*|DP*|DVI*|*DVI*|DisplayPort*|*DisplayPort*|VGA*|*VGA*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Determine target device for brightness control
selected_monitor=$(resolve_monitor)

if [ -n "$selected_monitor" ]; then
    if is_external_monitor "$selected_monitor"; then
        control_method="ddcutil"
    else
        # Internal panel: brightnessctl uses the default backlight device,
        # because the hyprctl monitor name (e.g. "eDP-1") is not a brightnessctl
        # device name and would make the command fail.
        control_method="brightnessctl"
    fi
else
    control_method="brightnessctl"
fi
device_flag=""

# Map the Hyprland monitor name (e.g. DP-1) to its i2c bus via sysfs, so
# ddcutil can skip its slow all-bus detection scan on every invocation.
if [ "$control_method" = "ddcutil" ]; then
    for i2c in /sys/class/i2c-dev/i2c-*; do
        [ -e "$i2c" ] || continue
        num=${i2c##*/i2c-}
        parent=$(basename "$(dirname "$(readlink -f "$i2c/device" 2>/dev/null)")" 2>/dev/null)
        case "$parent" in
            *"-$selected_monitor")
                ddc_prefix="ddcutil --bus=$num $ddc_args"
                break
                ;;
        esac
    done
fi

send_notification() {
    if [ "$control_method" = "ddcutil" ]; then
        # Reuse the value we already know; only read back if not provided.
        brightness=$1
        [ -z "$brightness" ] && brightness=$($ddc_prefix getvcp 0x10 2>/dev/null | grep -oP "current value =\s*\K\d+")
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
        $ddc_prefix getvcp 0x10 2>/dev/null | grep -oP "current value =\s*\K\d+"
    else
        brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
    fi
}

case $action in
increase)
    cur=$(get_brightness)

    if [[ $cur -lt 10 ]] ; then
        step=1
    fi

    $use_swayosd && swayosd-client --brightness raise "$step" && exit 0

    if [ "$control_method" = "ddcutil" ]; then
        $ddc_prefix setvcp 0x10 + $step $ddc_set_flags 2>/dev/null
        new_b=$(( cur + step ))
        [ "$new_b" -gt 100 ] && new_b=100
    else
        brightnessctl $device_flag set +${step}%
        new_b=""
    fi

    [ "$notify" = true ] && send_notification "$new_b" ;;
decrease)

    cur=$(get_brightness)

    if [[ $cur -le 10 ]] ; then
        step=1
    fi

    $use_swayosd && swayosd-client --brightness lower "$step" && exit 0

    new_b=$(( cur - step ))
    [ "$new_b" -lt 0 ] && new_b=0

    if [ "$control_method" = "ddcutil" ]; then
        $ddc_prefix setvcp 0x10 - $step $ddc_set_flags 2>/dev/null
    else
        brightnessctl $device_flag set ${step}%-
        new_b=""
    fi

    [ "$notify" = true ] && send_notification "$new_b" ;;
esac
