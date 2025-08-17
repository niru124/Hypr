#!/usr/bin/env bash

# Path to your rofi theme
ROFI_THEME="$HOME/.config/rofi/styles/style_13.rasi"

# --- Get settings from globalcontrol.sh ---
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

# Set rofi scaling, ensure it's a number
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
wind_border=$((hypr_border * 3 / 2))
elem_border=$([ $hypr_border -eq 0 ] && echo "5" || echo $hypr_border)

# --- Evaluate spawn position ---
readarray -t curPos < <(hyprctl cursorpos -j | jq -r '.x,.y')
readarray -t monRes < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale,.x,.y')
readarray -t offRes < <(hyprctl -j monitors | jq -r '.[] | select(.focused==true).reserved | map(tostring) | join("\n")')
monRes[2]="$(echo "${monRes[2]}" | sed "s/\.//")"
monRes[0]="$(( ${monRes[0]} * 100 / ${monRes[2]} ))"
monRes[1]="$(( ${monRes[1]} * 100 / ${monRes[2]} ))"
curPos[0]="$(( ${curPos[0]} - ${monRes[3]} ))"
curPos[1]="$(( ${curPos[1]} - ${monRes[4]} ))"

if [ "${curPos[0]}" -ge "$((${monRes[0]} / 2))" ] ; then
    x_pos="east"
    x_off="-$(( ${monRes[0]} - ${curPos[0]} - ${offRes[2]} ))"
else
    x_pos="west"
    x_off="$(( ${curPos[0]} - ${offRes[0]} ))"
fi

if [ "${curPos[1]}" -ge "$((${monRes[1]} / 2))" ] ; then
    y_pos="south"
    y_off="-$(( ${monRes[1]} - ${curPos[1]} - ${offRes[3]} ))"
else
    y_pos="north"
    y_off="$(( ${curPos[1]} - ${offRes[1]} ))"
fi

# --- Change width and general theming ---
menu_width=$(( monRes[0] / 3 ))  # Adjust this value to change the width.  1/3 of monitor width now

# The r_override string will now also handle the rofi font configuration
r_override="window{location:${x_pos} ${y_pos};anchor:${x_pos} ${y_pos};x-offset:${x_off}px;y-offset:${y_off}px;border:${hypr_width}px;border-radius:${wind_border}px;width: ${menu_width}px;} wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"

# --- End Styling ---

# Run rofi emoji picker with custom keybindings
chosen=$(rofi \
  -modi emoji \
  -show emoji \
  -emoji-format '{emoji} {name}' \
  -kb-secondary-copy "" \
  -kb-custom-1 Ctrl+c \
  -theme "$ROFI_THEME" \
  -theme-str "$r_scale" \
  -theme-str "$r_override")

# Check for exit status (10 = custom key 1 pressed)
if [[ $? -eq 10 ]]; then
    if command -v wl-copy &>/dev/null; then
        echo -n "$chosen" | wl-copy
    else
        notify-send "Emoji Picker" "Clipboard utility not found."
        exit 1
    fi

    notify-send "Emoji Picker" "Copied: $chosen"
fi

