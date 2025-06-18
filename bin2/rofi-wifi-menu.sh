#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/wifi-theme.rasi"

notify-send "Wi-Fi" "Getting list of available networks..."

# List Wi-Fi networks with icons
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' \
  | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

# Check Wi-Fi state
connected=$(nmcli -fields WIFI g)
if [[ "$connected" == *"enabled"* ]]; then
    toggle="󰖪  Disable Wi-Fi"
else
    toggle="󰖩  Enable Wi-Fi"
fi

# Show selection menu via rofi with theme
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u \
    | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " -theme "$ROFI_THEME")

# Exit if nothing selected
[ -z "$chosen_network" ] && exit

# Get SSID (remove icon and trim spaces)
chosen_id=$(echo "$chosen_network" | sed -E 's/^[^ ]+ +//' | sed 's/ *$//')

if [[ "$chosen_network" == "$toggle" ]]; then
    if [[ "$toggle" == "󰖪  Disable Wi-Fi" ]]; then
        nmcli radio wifi off
        notify-send "Wi-Fi" "Wi-Fi disabled"
    else
        nmcli radio wifi on
        notify-send "Wi-Fi" "Wi-Fi enabled"
    fi
    exit
fi

# Success message
success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."

# Check if connection already exists
if nmcli -g NAME connection | grep -Fxq "$chosen_id"; then
    nmcli connection up id "$chosen_id" | grep -q "successfully" \
        && notify-send "Connection Established" "$success_message"
else
    # Prompt for password if secured network
    if [[ "$chosen_network" =~ "" ]]; then
        wifi_password=$(rofi -dmenu -p "Password for $chosen_id:" -theme "$ROFI_THEME")
        [ -z "$wifi_password" ] && notify-send "Wi-Fi" "No password entered." && exit
        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep -q "successfully" \
            && notify-send "Connection Established" "$success_message"
    else
        nmcli device wifi connect "$chosen_id" | grep -q "successfully" \
            && notify-send "Connection Established" "$success_message"
    fi
fi

