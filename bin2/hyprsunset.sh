#!/usr/bin/env sh

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

use_swayosd=false
if command -v swayosd-client >/dev/null 2>&1 && pgrep -x swayosd-server >/dev/null; then
    use_swayosd=true
fi

icodir="${confDir}/dunst/icons/vol" # Make sure this path is correct

# Define the temperature range for your icons and clamping
min_kelvin_script=2500
max_kelvin_script=7500

# Default step for increase/decrease if not specified by user
default_step_kelvin=200 # You can set your preferred default here

state_file="/tmp/hyprsunset_script_temp_state"

# --- Functions ---

get_current_actual_temp() {
    local temp_json
    local current_val

    temp_json=$(hyprctl hyprsunset status 2>/dev/null)
    if [ -n "$temp_json" ] && [ "$temp_json" != "invalid command" ] && [ "$temp_json" != "unknown request" ]; then
        current_val=$(echo "$temp_json" | jq -r .temperature 2>/dev/null)
        if [ "$current_val" != "null" ] && [[ "$current_val" =~ ^[0-9]+$ ]]; then
            echo "$current_val"
            echo "$current_val" > "$state_file"
            return
        fi
    fi

    if [ -f "$state_file" ]; then
        cat "$state_file"
        return
    fi
    echo "6500"
}

clamp_temp() {
    local val=$1
    if [ "$val" -lt "$min_kelvin_script" ]; then
        val=$min_kelvin_script
    elif [ "$val" -gt "$max_kelvin_script" ]; then
        val=$max_kelvin_script
    fi
    echo "$val"
}

temp_to_icon_percent() {
    local temp_k=$1
    local percentage

    if [ "$temp_k" -le "$min_kelvin_script" ]; then
        percentage=0
    elif [ "$temp_k" -ge "$max_kelvin_script" ]; then
        percentage=100
    else
        local range=$((max_kelvin_script - min_kelvin_script))
        if [ "$range" -le 0 ]; then 
             percentage=50 
        else
            percentage_float=$(awk -v temp="$temp_k" -v min="$min_kelvin_script" -v max="$max_kelvin_script" \
                'BEGIN { pc = ( (temp - min) * 100 ) / (max - min); printf "%.0f", pc }')
            percentage=${percentage_float%.*}
        fi
    fi

    [ $percentage -lt 0 ] && percentage=0
    [ $percentage -gt 100 ] && percentage=100
    local angle=$(( ((percentage + 2) / 5) * 5 ))
    echo "${icodir}/vol-${angle}.svg"
}

# Set temperature using hyprctl and notify
set_and_notify_temp() {
    local target_temp_kelvin=$1
    local effective_temp_kelvin

    effective_temp_kelvin=$(clamp_temp "$target_temp_kelvin")

    if ! hyprctl hyprsunset temperature "$effective_temp_kelvin" >/dev/null 2>&1; then
        notify-send -u critical -t 2000 "Hyprsunset" "Error setting temperature via hyprctl."
    fi

    echo "$effective_temp_kelvin" > "$state_file"
    local notified_temp="$effective_temp_kelvin"
    local icon_path=$(temp_to_icon_percent "$notified_temp")

    local bar_percentage
    local range_for_bar=$((max_kelvin_script - min_kelvin_script))
    if [ "$range_for_bar" -le 0 ]; then bar_percentage=50; else
      bar_percentage=$(( ( (notified_temp - min_kelvin_script) * 100 ) / range_for_bar ))
    fi
    [ $bar_percentage -lt 0 ] && bar_percentage=0; [ $bar_percentage -gt 100 ] && bar_percentage=100
    
    local bar_segments=$(( bar_percentage / 15 )) 
    local bar_text=""
    if [ "$bar_segments" -gt 0 ]; then
        bar_text=$(seq -s "." "$bar_segments" | sed 's/[0-9]//g')
    fi

    notify-send -a "Hyprsunset" -r 91192 -t 1000 -i "$icon_path" \
        "${notified_temp}K${bar_text}" "Color Temperature"
}

for cmd in hyprctl jq awk notify-send seq sed; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' not found." >&2
        exit 1
    fi
done

ACTION="$1"
REQUESTED_STEP="$2" # This will be the custom step value, or empty

# Determine the step value to use
step_to_use=${default_step_kelvin} # Start with default
if [ -n "$REQUESTED_STEP" ] && [[ "$REQUESTED_STEP" =~ ^[0-9]+$ ]]; then # If provided and is a number
    step_to_use="$REQUESTED_STEP"
fi

current_temp_for_calc=$(get_current_actual_temp)

case "$ACTION" in
    i) set_and_notify_temp $(( current_temp_for_calc + step_to_use )) ;;
    d) set_and_notify_temp $(( current_temp_for_calc - step_to_use )) ;;
    *)
      echo "Usage: $(basename "$0") <action> [step]"
      echo "Actions:"
      echo "  i     Increase temperature (cooler/bluer)"
      echo "  d     Decrease temperature (warmer/redder)"
      echo "Optional:"
      echo "  step  Amount to change temperature by (default: $default_step_kelvin K)"
      echo ""
      echo "Examples:"
      echo "  $(basename "$0") i         # Increase by $default_step_kelvin K"
      echo "  $(basename "$0") d 500     # Decrease by 500 K"
      exit 1
      ;;
esac

