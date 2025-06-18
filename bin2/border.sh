#!/usr/bin/env bash

DCOL="$HOME/.cache/hyde/wall.dcol"
CONFIG="$HOME/.config/hypr/hyprland.conf"

if [[ ! -f "$DCOL" ]]; then
    echo "❌ Missing .dcol file at $DCOL"
    exit 1
fi

source "$DCOL"

fix_rgba() {
    echo "${1//\\1/1}"
}

# Active border colors (dynamic from .dcol)
active_colors=(
    "$(fix_rgba "$dcol_1xa6_rgba")"
    "$(fix_rgba "$dcol_1xa7_rgba")"
    "$(fix_rgba "$dcol_pry2_rgba")"
    "$(fix_rgba "$dcol_2xa8_rgba")"
)

# Inactive border colors (hardcoded in rgba)
inactive_colors=(
    "rgba(81,87,109,1)"
    "rgba(98,104,128,1)"
    "rgba(115,121,148,1)"
    "rgba(131,139,167,1)"
)

# Construct lines for config
active_line="    col.active_border = ${active_colors[*]} 180deg"
inactive_line="    col.inactive_border = ${inactive_colors[*]} 45deg"

# Update hyprland.conf
if grep -q '^[[:space:]]*general[[:space:]]*{' "$CONFIG"; then
    if grep -q '^[[:space:]]*col\.active_border' "$CONFIG"; then
        sed -i -E "s|^[[:space:]]*col\.active_border.*|$active_line|" "$CONFIG"
    else
        sed -i "/^[[:space:]]*general[[:space:]]*{/a\\$active_line" "$CONFIG"
    fi

    if grep -q '^[[:space:]]*col\.inactive_border' "$CONFIG"; then
        sed -i -E "s|^[[:space:]]*col\.inactive_border.*|$inactive_line|" "$CONFIG"
    else
        sed -i "/^[[:space:]]*general[[:space:]]*{/a\\$inactive_line" "$CONFIG"
    fi
else
    cat >> "$CONFIG" <<EOF

general {
    gaps_in = 4
    gaps_out = 4
    border_size = 3
$active_line
$inactive_line
}
EOF
fi

hyprctl reload

echo "✅ Updated col.active_border (dynamic) and col.inactive_border (hardcoded rgba) in general block from $DCOL"

