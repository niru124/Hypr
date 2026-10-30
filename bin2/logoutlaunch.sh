#!/usr/bin/env sh


#// Check if wlogout is already running

if pgrep -x "wlogout" > /dev/null
then
    pkill -x "wlogout"
    exit 0
fi


#// set file variables

scrDir=`dirname "$(realpath "$0")"`
source $scrDir/globalcontrol.sh
wlogoutStyle="${1:-1}"
wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"

if [ ! -f "${wLayout}" ] || [ ! -f "${wlTmplt}" ] ; then
    echo "ERROR: Config ${wlogoutStyle} not found..."
    wlogoutStyle=1
    wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
    wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"
fi


#// detect monitor res

x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
mon_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale')


#// scale config layout and style

case "${wlogoutStyle}" in
    1)  wlColms=6
        export mgn="$(awk -v y="${y_mon}" -v s="${mon_scale}" 'BEGIN{printf "%d", y*28/100/s}')"
        export hvr="$(awk -v y="${y_mon}" -v s="${mon_scale}" 'BEGIN{printf "%d", y*23/100/s}')" ;;
    2)  wlColms=2
        export x_mgn="$(awk -v x="${x_mon}" -v s="${mon_scale}" 'BEGIN{printf "%d", x*35/100/s}')"
        export y_mgn="$(awk -v y="${y_mon}" -v s="${mon_scale}" 'BEGIN{printf "%d", y*25/100/s}')"
        export x_hvr="$(awk -v x="${x_mon}" -v s="${mon_scale}" 'BEGIN{printf "%d", x*32/100/s}')"
        export y_hvr="$(awk -v y="${y_mon}" -v s="${mon_scale}" 'BEGIN{printf "%d", y*20/100/s}')" ;;
esac


#// scale font size

export fntSize=$(( y_mon * 2 / 100 ))


#// detect wallpaper brightness

[ -f "${cacheDir}/wall.dcol" ] && source "${cacheDir}/wall.dcol"
#  Theme mode: detects the color-scheme set in hypr.theme and falls back if nothing is parsed.
if [ "${enableWallDcol}" -eq 0 ]; then
    colorScheme="$({ grep -q "^[[:space:]]*\$COLOR[-_]SCHEME\s*=" "${hydeThemeDir}/hypr.theme" && grep "^[[:space:]]*\$COLOR[-_]SCHEME\s*=" "${hydeThemeDir}/hypr.theme" | cut -d '=' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;} || 
                        grep 'gsettings set org.gnome.desktop.interface color-scheme' "${hydeThemeDir}/hypr.theme" | awk -F "'" '{print $((NF - 1))}')"
    colorScheme=${colorScheme:-$(gsettings get org.gnome.desktop.interface color-scheme)} 
    # should be declared explicitly so we can easily debug
    grep -q "dark" <<< "${colorScheme}" && dcol_mode="dark"
    grep -q "light" <<< "${colorScheme}" && dcol_mode="light"
[ -f "${hydeThemeDir}/theme.dcol" ] && source "${hydeThemeDir}/theme.dcol"
fi
[ "${dcol_mode}" == "dark" ] && export BtnCol="white" || export BtnCol="black"


#// eval hypr border radius

export active_rad=$(( hypr_border * 5 ))
export button_rad=$(( hypr_border * 8 ))


#// eval config files

wlStyle="$(envsubst < $wlTmplt)"


#// launch wlogout

wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell

