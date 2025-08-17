#!/usr/bin/env bash

undock=false
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
batterynotify_conf="${hydeConfDir}/hyde.conf"

config_info() {
cat <<  EOF

Modify $batterynotify_conf to set options.

      STATUS      THRESHOLD    INTERVAL
      Full        $battery_full_threshold          $notify Minutes
      Critical    $battery_critical_threshold           $timer Seconds then '$execute_critical'
      Low         $battery_low_threshold           $interval Percent    then '$execute_low'
      Unplug      $unplug_charger_threshold          $interval Percent   then '$execute_unplug'

      Charging: $execute_charging
      Discharging: $execute_discharging
EOF
}

is_laptop() {
    if grep -q "Battery" /sys/class/power_supply/BAT*/type; then
        return 0
    else
        echo "No battery detected. If you think this is an error please post a report to the repo"
        exit 0
    fi
}
is_laptop

fn_verbose() {
    if $verbose; then
cat << VERBOSE
=============================================
        Battery Status: $battery_status
        Battery Percentage: $battery_percentage
=============================================
VERBOSE
    fi
}

fn_notify() {
    local notify_opts="$1" urgency="$2" title="$3" message="$4" sound_key="$5"
    notify -"$urgency" --app-name "Power" --replace-id 54321 --notify-opts "$notify_opts" "$title: $message" ${sound_key:+-"$sound_key"}
}

fn_percentage() {
    if [[ "$battery_percentage" -ge "$unplug_charger_threshold" ]] && [[ "$battery_status" != "Discharging" ]] && [[ "$battery_status" != "Full" ]] && (( (battery_percentage - last_notified_percentage) >= interval )); then
        fn_notify "-t 5000" "CRITICAL" "Battery Charged" "Battery is at $battery_percentage%. You can unplug the charger!" "message-new-instant"
        last_notified_percentage=$battery_percentage
    elif [[ "$battery_percentage" -le "$battery_critical_threshold" ]]; then
        count=$(( timer > mnt ? timer : mnt ))
        while [ $count -gt 0 ] && [[ $battery_status == "Discharging"* ]]; do
            for battery in /sys/class/power_supply/BAT*; do
                battery_status=$(< "$battery/status")
            done
            [[ $battery_status != "Discharging" ]] && break
            fn_notify "-t 5000 -r 69" "CRITICAL" "Battery Critically Low" "$battery_percentage% is critically low. Device will execute $execute_critical in $((count/60)):$((count%60))." "message-new-instant"
            count=$((count - 1))
            sleep 1
        done
        [ $count -eq 0 ] && fn_action
    elif [[ "$battery_percentage" -le "$battery_low_threshold" ]] && [[ "$battery_status" == "Discharging" ]] && (( (last_notified_percentage - battery_percentage) >= interval )); then
        fn_notify "-t 5000" "CRITICAL" "Battery Low" "Battery is at $battery_percentage%. Connect the charger." "message-new-instant"
        last_notified_percentage=$battery_percentage
    fi
}

fn_action() {
    count=$(( timer > mnt ? timer : mnt ))
    nohup $execute_critical &
}

fn_status() {
    [[ $battery_percentage -ge $battery_full_threshold && "$battery_status" != *"Discharging"* ]] && battery_status="Full"
    case "$battery_status" in
        "Discharging")
            [[ "$prev_status" != "Discharging" || "$prev_status" == "Full" ]] && {
                prev_status=$battery_status
                urgency=$([[ $battery_percentage -le "$battery_low_threshold" ]] && echo "CRITICAL" || echo "NORMAL")
                fn_notify "-t 5000 -r 54321" "$urgency" "Charger Plug OUT" "Battery is at $battery_percentage%." "message-new-instant"
                $execute_discharging
            }
            fn_percentage
            ;;
        "Not"*|"Charging")
            [[ "$prev_status" == "Discharging" || "$prev_status" == "Not"* ]] && {
                prev_status=$battery_status
                # Only play sound, no title/message
                fn_notify "-t 2000 -r 54321" "NORMAL" "" "" "network-connectivity-established"
                $execute_charging
            }
            fn_percentage
            ;;
        "Full")
            now=$(date +%s)
            if [[ "$prev_status" == *"harging"* || $((now - lt)) -ge $((notify * 60)) ]]; then
                fn_notify "-t 5000 -r 54321" "CRITICAL" "Battery Full" "Please unplug your Charger" "message-new-instant"
                prev_status=$battery_status
                lt=$now
                $execute_charging
            fi
            ;;
        *)
            if [[ ! -f "/tmp/hyprdots.batterynotify.status.fallback.$battery_status-$$" ]]; then
                echo "Status: '==>> $battery_status <<==' Script on Fallback mode. Unknown power supply status."
                touch "/tmp/hyprdots.batterynotify.status.fallback.$battery_status-$$"
            fi
            fn_percentage
            ;;
    esac
}

get_battery_info() {
    total_percentage=0
    battery_count=0
    for battery in /sys/class/power_supply/BAT*; do
        battery_status=$(<"$battery/status")
        battery_percentage=$(<"$battery/capacity")
        total_percentage=$((total_percentage + battery_percentage))
        battery_count=$((battery_count + 1))
    done
    battery_percentage=$((total_percentage / battery_count))
}

fn_status_change() {
    get_battery_info
    local executed_low=false executed_unplug=false
    if [[ "$battery_status" != "$last_battery_status" || "$battery_percentage" != "$last_battery_percentage" ]]; then
        last_battery_status=$battery_status
        last_battery_percentage=$battery_percentage
        fn_verbose
        fn_percentage
        [[ "$battery_percentage" -le "$battery_low_threshold" && $executed_low == false ]] && $execute_low && executed_low=true
        [[ "$battery_percentage" -ge "$unplug_charger_threshold" && $executed_unplug == false ]] && $execute_unplug && executed_unplug=true
        $undock && fn_status
    fi
}

main() {
    rm -fr /tmp/hyprdots.batterynotify*
    battery_full_threshold=${battery_full_threshold:-100}
    battery_critical_threshold=${battery_critical_threshold:-5}
    unplug_charger_threshold=${unplug_charger_threshold:-80}
    battery_low_threshold=${battery_low_threshold:-20}
    timer=${timer:-120}
    notify=${notify:-1140}
    interval=${interval:-5}
    execute_critical=${execute_critical:-"systemctl suspend"}
    execute_low=${execute_low:-}
    execute_unplug=${execute_unplug:-}

    config_info
    $verbose && echo -e "Verbose Mode is ON...\n"
    get_battery_info
    last_notified_percentage=$battery_percentage
    prev_status=$battery_status

    dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',path='$(upower -e | grep battery)'" 2>/dev/null | while read -r _; do
        fn_status_change
    done
}

verbose=false
case "$1" in
    -m|--modify)
        EDITOR="${EDITOR:-code}"
        echo -e "[Editor]: $EDITOR\n[Modifying]: $batterynotify_conf\nPress Any Key if done editing"
        kitty "$(which $EDITOR)" "$batterynotify_conf" > /dev/null 2>&1 &
        LAST_MD5SUM=$(md5sum "$batterynotify_conf")
        while true; do
            CURRENT_MD5SUM=$(md5sum "$batterynotify_conf")
            if [ "$CURRENT_MD5SUM" != "$LAST_MD5SUM" ]; then
                /usr/local/bin/notify -normal --app-name "Power" " " -message-new-instant
                LAST_MD5SUM="$CURRENT_MD5SUM"
            fi
            read -t 2 -n 1 > /dev/null && break
        done
        exit 0
        ;;
    -i|--info)
        config_info
        exit 0
        ;;
    -v|--verbose)
        verbose=true
        ;;
    -*)
        cat << HELP
Usage: $0 [options]

[-m|--modify]     Modify configuration file
[-i|--info]       Display configuration information
[-v|--verbose]    Debugging mode
[-h|--help]       This Message
HELP
        exit 0
        ;;
esac

main

