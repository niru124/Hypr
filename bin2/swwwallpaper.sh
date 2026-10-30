#!/usr/bin/env bash


#// lock instance

lockFile="/tmp/hyde$(id -u)$(basename ${0}).lock"
[ -e "${lockFile}" ] && echo "An instance of the script is already running..." && exit 1
touch "${lockFile}"
trap 'rm -f ${lockFile}' EXIT


#// define functions

Wall_Cache()
{
    ln -fs "${wallList[setIndex]}" "${wallSet}"
    ln -fs "${wallList[setIndex]}" "${wallCur}"
    "${scrDir}/swwwallcache.sh" -w "${wallList[setIndex]}" &> /dev/null
    # matugen handles all theming now (replaces swwwallbash.sh / wallbash)
    matugen image "${wallList[setIndex]}" -m dark &> /dev/null &
    ln -fs "${thmbDir}/${wallHash[setIndex]}.sqre" "${wallSqr}"
    ln -fs "${thmbDir}/${wallHash[setIndex]}.thmb" "${wallTmb}"
    ln -fs "${thmbDir}/${wallHash[setIndex]}.blur" "${wallBlr}"
    ln -fs "${thmbDir}/${wallHash[setIndex]}.quad" "${wallQad}"
    ln -fs "${dcolDir}/${wallHash[setIndex]}.dcol" "${wallDcl}"
}

Wall_Change()
{
    curWall="$(set_hash "${wallSet}")"
    for i in "${!wallHash[@]}" ; do
        if [ "${curWall}" == "${wallHash[i]}" ] ; then
            if [ "${1}" == "n" ] ; then
                setIndex=$(( (i + 1) % ${#wallList[@]} ))
            elif [ "${1}" == "p" ] ; then
                setIndex=$(( i - 1 ))
            fi
            break
        fi
    done
    Wall_Cache
}


#// set variables

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"

# // swww was renamed to awww upstream; prefer whichever is installed
SWWW_BIN="$(command -v swww || command -v awww || true)"
SWWWD_BIN="$(command -v swww-daemon || command -v awww-daemon || true)"
if [[ -z ${SWWW_BIN} || -z ${SWWWD_BIN} ]]; then
    echo ":: neither swww nor awww is installed" >&2
    exit 1
fi
wallSet="${hydeThemeDir}/wall.set"
wallCur="${cacheDir}/wall.set"
wallSqr="${cacheDir}/wall.sqre"
wallTmb="${cacheDir}/wall.thmb"
wallBlr="${cacheDir}/wall.blur"
wallQad="${cacheDir}/wall.quad"
wallDcl="${cacheDir}/wall.dcol"


#// check wall

setIndex=0
[ ! -d "${hydeThemeDir}" ] && echo "ERROR: \"${hydeThemeDir}\" does not exist" && exit 0
wallPathArray=("${hydeThemeDir}")
wallPathArray+=("${wallAddCustomPath[@]}")
get_hashmap "${wallPathArray[@]}"
[ ! -e "$(readlink -f "${wallSet}")" ] && echo "fixig link :: ${wallSet}" && ln -fs "${wallList[setIndex]}" "${wallSet}"


#// evaluate options

while getopts "nps:" option ; do
    case $option in
    n ) # set next wallpaper
        xtrans="grow"
        Wall_Change n
        ;;
    p ) # set previous wallpaper
        xtrans="outer"
        Wall_Change p
        ;;
    s ) # set input wallpaper
        if [ ! -z "${OPTARG}" ] && [ -f "${OPTARG}" ] ; then
            get_hashmap "${OPTARG}"
        fi
        Wall_Cache
        ;;
    * ) # invalid option
        echo "... invalid option ..."
        echo "$(basename "${0}") -[option]"
        echo "n : set next wall"
        echo "p : set previous wall"
        echo "s : set input wallpaper"
        exit 1 ;;
    esac
done


#// check swww daemon

"${SWWW_BIN}" query &> /dev/null
if [ $? -ne 0 ] ; then
    "${SWWWD_BIN}" --format xrgb &
    "${SWWW_BIN}" query && "${SWWW_BIN}" restore
fi


#// set defaults

[ -z "${xtrans}" ] && xtrans="random"
[ -z "${wallFramerate}" ] && wallFramerate=60
[ -z "${wallTransDuration}" ] && wallTransDuration=0.4



#// apply wallpaper

echo ":: applying wall :: \"$(readlink -f "${wallSet}")\""
"${SWWW_BIN}" img "$(readlink "${wallSet}")" --transition-bezier .43,1.19,1,.4 --transition-type "${xtrans}" --transition-duration "${wallTransDuration}" --transition-fps "${wallFramerate}" --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" &

notify -normal --app-name "ThemeSwitch" "" -message-new-instant
sleep 0.5

# matugen generates all colors (hypr, hyprlock, waybar, kitty, foot, dunst, rofi, alacritty, gtk)
# Wall_Cache already fired it async; ensure current wallpaper is themed even
# when invoked without option flags (e.g. plain startup call).
matugen image "$(readlink -f "${wallSet}")" -m dark &> /dev/null || true
hyprctl -q reload || true
echo "✅ matugen colors applied from wallpaper"
