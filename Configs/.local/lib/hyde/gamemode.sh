#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | sed -n '1p' | awk '{print $2}')

# Waybar performance
FILE="$HOME/.config/waybar/style.css"

sed -i 's/\/\* \(.*animation:.*\) \*\//\1/g' $FILE
sed -i 's/\/\* \(.*transition:.*\) \*\//\1/g' $FILE
# if [ $HYPRGAMEMODE = 1 ]; then
# 	sed -i 's/^\(.*animation:.*\)$/\/\* \1 \*\//g' $FILE
# 	sed -i 's/^\(.*transition:.*\)$/\/\* \1 \*\//g' $FILE
# fi
killall waybar
waybar >/dev/null 2>&1 &

# Hyprland performance
if [ $HYPRGAMEMODE = 1 ]; then
	hyprctl --batch "\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 1;\
        keyword general:gaps_in 4;\
        keyword general:gaps_out 4;\
        keyword general:border_size 4;\
        keyword decoration:rounding 10"
	exit
else
	hyprctl reload
fi
