#!/usr/bin/env sh

#// set variables
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
rofiConf="${confDir}/rofi/selector.rasi"

#// set rofi scaling
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 3 ))

#// scale for monitor
mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
mon_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed "s/\.//")
mon_x_res=$(( mon_x_res * 100 / mon_scale ))

#// generate config
elm_width=$(( (28 + 8 + 5) * rofiScale ))
max_avail=$(( mon_x_res - (4 * rofiScale) ))
col_count=$(( max_avail / elm_width ))
r_override="window{width:100%;} listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;}"

#// launch rofi menu
currentWall="$(basename "$(readlink "${hydeThemeDir}/wall.set")")"
wallPathArray=("${hydeConfDir}/themes")
wallPathArray+=("${wallAddCustomPath[@]}")

get_hashmap "${wallPathArray[@]}"

rofiSel=$(parallel --link echo -en "\$(basename "{1}")"'\\x00icon\\x1f'"${thmbDir}"'/'"{2}"'.sqre\\n' ::: "${wallList[@]}" ::: "${wallHash[@]}" | \
    rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${currentWall}")

#// apply wallpaper
if [ ! -z "${rofiSel}" ] ; then
    setWall=""
    # Find the full path corresponding to the selected basename
    for wall in "${wallList[@]}"; do
        if [ "$(basename "$wall")" = "${rofiSel}" ]; then
            setWall="$wall"
            break
        fi
    done

    if [ -n "${setWall}" ]; then
        "${scrDir}/swwwallpaper.sh" -s "${setWall}"
        notify --app-name "t1" --icon "${thmbDir}/$(set_hash "${setWall}").sqre" " ${rofiSel}"
    fi
fi