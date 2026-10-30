#!/usr/bin/env bash
# waybar-themelock.sh — freeze / unfreeze ONLY waybar colors on wallpaper change.
# Lock mechanism: adds the waybar wallbash template to `skip_wallbash` in
# ~/.config/hyde/hyde.conf, which swwwallbash.sh already respects:
#   [[ " ${skip_wallbash[@]} " =~ " ${tplt} " ]] && skip
# So wallpaper + all other apps keep re-theming, but waybar's theme.css stays put.
#
# Usage:
#   waybar-themelock.sh status   # JSON for waybar exec module
#   waybar-themelock.sh toggle   # flip lock (meant for on-click)
#   waybar-themelock.sh lock     # force lock
#   waybar-themelock.sh unlock   # force unlock + resync to current wallpaper

HYDE_CONF="$HOME/.config/hyde/hyde.conf"
WAYBAR_TPLT="$HOME/.config/hyde/wallbash/Wall-Dcol/waybar.dcol"
ICON_LOCKED=""
ICON_UNLOCKED=""

is_locked() {
    [ -f "$HYDE_CONF" ] && grep -q "waybar\.dcol" "$HYDE_CONF"
}

do_status() {
    if is_locked; then
        printf '{"text":"%s","tooltip":"Waybar colors FROZEN — click to follow wallpaper again","class":"locked"}\n' "$ICON_LOCKED"
    else
        printf '{"text":"%s","tooltip":"Waybar colors follow wallpaper — click to freeze","class":"unlocked"}\n' "$ICON_UNLOCKED"
    fi
}

do_lock() {
    touch "$HYDE_CONF"
    if ! grep -q "skip_wallbash" "$HYDE_CONF"; then
        printf '\nskip_wallbash=("%s")\n' "$WAYBAR_TPLT" >> "$HYDE_CONF"
    elif ! grep -q "waybar\.dcol" "$HYDE_CONF"; then
        # insert our template into the existing array (handles empty array too)
        sed -i "s|^skip_wallbash=(|skip_wallbash=(\"$WAYBAR_TPLT\" |" "$HYDE_CONF"
    fi
    notify-send -a "waybar-themelock" "󰌾 Waybar theme frozen" "Wallpaper can change — bar colors stay." 2>/dev/null
}

do_unlock() {
    if [ -f "$HYDE_CONF" ]; then
        # drop our entry; escape slashes for sed
        esc_tpl="$(printf '%s' "$WAYBAR_TPLT" | sed 's|/|\\/|g')"
        sed -i "s| *\"$esc_tpl\"||g" "$HYDE_CONF"
        # clean up leftover empty residue: skip_wallbash=( ) -> skip_wallbash=()
        sed -i 's|^skip_wallbash=( *)|skip_wallbash=()|' "$HYDE_CONF"
        # if array is now empty, remove the line so hyde.conf stays clean
        sed -i '/^skip_wallbash=()$/d' "$HYDE_CONF"
        # collapse leftover blank lines
        sed -i '/^[[:space:]]*$/d' "$HYDE_CONF"
    fi
    # immediately sync waybar to the CURRENT wallpaper
    curWall="$(readlink -f "$HOME/.cache/hyde/wall.set" 2>/dev/null)"
    if [ -n "$curWall" ] && [ -f "$curWall" ]; then
        scrDir="$(dirname "$(realpath "$0")")"
        if [ -x "$scrDir/swwwallbash.sh" ]; then
            "$scrDir/swwwallbash.sh" "$curWall" >/dev/null 2>&1 &
        fi
    fi
    notify-send -a "waybar-themelock" "󰌵 Waybar theme live" "Bar colors follow wallpaper again." 2>/dev/null
}

refresh_waybar() {
    # wake the status module quickly (it also polls every few seconds anyway)
    pkill -SIGUSR2 waybar 2>/dev/null
}

case "${1:-status}" in
    status) do_status ;;
    lock) do_lock; refresh_waybar ;;
    unlock) do_unlock; refresh_waybar ;;
    toggle)
        if is_locked; then do_unlock; else do_lock; fi
        refresh_waybar
        ;;
    *) echo "usage: $0 {status|toggle|lock|unlock}" >&2; exit 1 ;;
esac
