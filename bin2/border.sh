#!/usr/bin/env bash

DCOL="$HOME/.cache/hyde/wall.dcol"
CONFIG="$HOME/.config/hypr/themes/colors.conf"

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

# Inactive border colors (dynamic from .dcol)
inactive_colors=(
	"$(fix_rgba "$dcol_pry1_rgba")"
	"$(fix_rgba "$dcol_pry2_rgba")"
	"$(fix_rgba "$dcol_1xa3_rgba")"
	"$(fix_rgba "$dcol_1xa4_rgba")"
)

# Construct lines for config
active_line="    col.active_border = ${active_colors[*]} ${active_colors[*]}"
inactive_line="    col.inactive_border = ${inactive_colors[*]} 45deg"

# Update colors.conf
mkdir -p "$(dirname "$CONFIG")"

cat > "$CONFIG" <<EOF
general {
    col.active_border = ${active_colors[*]} ${active_colors[*]}
    col.inactive_border = ${inactive_colors[*]} 45deg
}

group {
    col.border_active = ${active_colors[*]} ${active_colors[*]}
    col.border_inactive = ${inactive_colors[*]} 45deg
}
EOF

hyprctl reload

echo "✅ Updated border colors (dynamic from wallpaper) in $CONFIG"
