#!/usr/bin/env bash

set -euo pipefail

# Toggle behavior — if Rofi is open, close it
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

# Config builder
setup_rofi_config() {
    local font_scale="${ROFI_CALC_SCALE:-${ROFI_SCALE:-10}}"
    local font_name="${ROFI_CALC_FONT:-${ROFI_FONT:-JetBrainsMono Nerd Font}}"

    fnt_override="* {font: \"${font_name} ${font_scale}\";}"

    # Basic border values
    local hypr_border=10
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$((hypr_border == 0 ? 5 : hypr_border))
    local hypr_width=2

    local width="50em"
    local height="25em"
    local lines="9"

    r_override="window{width:${width};height:${height};border:${hypr_width}px;border-radius:${wind_border}px;}
                entry{border-radius:${elem_border}px;}
                element{border-radius:${elem_border}px;}
                listview{lines:${lines};columns:2;}
                element-text{background-color:transparent;text-color:#ffffff;}
                mainbox{children:[\"inputbar\",\"message\",\"listview\"]}"
}

main() {
    setup_rofi_config

    if [[ -v customRoFile ]]; then
        rofi -show calc -modi calc -no-show-match -no-sort -config "${customRoFile}"
    else
        rofi -show calc -modi calc -no-show-match -no-sort \
             -theme-str "${fnt_override}" \
             -theme-str "${r_override}"
    fi
}

usage() {
    cat <<EOF
Usage: $0 [--rasi <PATH>]

--rasi <PATH>     Use a custom .rasi file instead of internal override
EOF
    exit 1
}

# Handle args
while (($# > 0)); do
    case $1 in
        --rasi)
            [[ -z ${2:-} ]] && echo "[error] --rasi requires a file.rasi config file" && exit 1
            customRoFile=${2}
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

main

