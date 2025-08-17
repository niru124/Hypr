#!/usr/bin/env bash

DB="${HOME}/.config/rofi/tasks.db"

# --- Get settings from globalcontrol.sh ---
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
ROFI_THEME="${confDir}/rofi/clipboard.rasi"  # Or your preferred theme file

# Set rofi scaling, ensure it's a number
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
wind_border=$((hypr_border * 3 / 2))
elem_border=$([ $hypr_border -eq 0 ] && echo "5" || echo $hypr_border)

# --- Evaluate spawn position ---
readarray -t curPos < <(hyprctl cursorpos -j | jq -r '.x,.y')
readarray -t monRes < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale,.x,.y')
readarray -t offRes < <(hyprctl -j monitors | jq -r '.[] | select(.focused==true).reserved | map(tostring) | join("\n")')
monRes[2]="$(echo "${monRes[2]}" | sed "s/\.//")"
monRes[0]="$(( ${monRes[0]} * 100 / ${monRes[2]} ))"
monRes[1]="$(( ${monRes[1]} * 100 / ${monRes[2]} ))"
curPos[0]="$(( ${curPos[0]} - ${monRes[3]} ))"
curPos[1]="$(( ${curPos[1]} - ${monRes[4]} ))"

if [ "${curPos[0]}" -ge "$((${monRes[0]} / 2))" ] ; then
    x_pos="east"
    x_off="-$(( ${monRes[0]} - ${curPos[0]} - ${offRes[2]} ))"
else
    x_pos="west"
    x_off="$(( ${curPos[0]} - ${offRes[0]} ))"
fi

if [ "${curPos[1]}" -ge "$((${monRes[1]} / 2))" ] ; then
    y_pos="south"
    y_off="-$(( ${monRes[1]} - ${curPos[1]} - ${offRes[3]} ))"
else
    y_pos="north"
    y_off="$(( ${curPos[1]} - ${offRes[1]} ))"
fi

# --- Change width and general theming ---
menu_width=$(( monRes[0] / 2 ))  # 1/3 of monitor width

# The r_override string will now also handle the rofi font configuration
r_override="window{location:${x_pos} ${y_pos};anchor:${x_pos} ${y_pos};x-offset:${x_off}px;y-offset:${y_off}px;border:${hypr_width}px;border-radius:${wind_border}px;width: ${menu_width}px;} wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"

# --- End Styling ---

mkdir -p "$(dirname "$DB")"
sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, description TEXT, due_date TEXT);"

validate_date() {
    local input="$1"
    local due_date

    # Case 1: Full date format - YYYY-MM-DD
    if [[ "$input" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        if date -d "$input" "+%Y-%m-%d" >/dev/null 2>&1; then
            due_date="$input"
        else
            rofi -e "❌ Invalid full date: $input" -theme "$ROFI_THEME" -theme-str "$r_override"
            return 1
        fi

    # Case 2: Just a day number (1–31)
    elif [[ "$input" =~ ^[1-9][0-9]?$ ]]; then
        local year month day
        year=$(date +%Y)
        month=$(date +%m)
        day=$(printf "%02d" "$input")
        due_date="$year-$month-$day"

        if ! date -d "$due_date" "+%Y-%m-%d" >/dev/null 2>&1; then
            rofi -e "❌ Invalid constructed date: $due_date" -theme "$ROFI_THEME" -theme-str "$r_override"
            return 1
        fi

    # Invalid format
    else
        rofi -e "❌ Invalid date format: $input" -theme "$ROFI_THEME" -theme-str "$r_override"
        return 1
    fi

    echo "$due_date"
    return 0
}

main_menu() {
    local menu

    menu=$(sqlite3 "$DB" "SELECT id, description, due_date FROM tasks ORDER BY id;" \
        | awk -F'|' '{ printf "%s: %s [%s]\n", $1, $2, $3 }')

    choice=$(printf "[+] Add Task\n[-] Delete Task\n%s" "$menu" \
        | rofi -dmenu -i -p "TODO:" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    case "$choice" in
        "[+] Add Task")
            add_task
            ;;
        "[-] Delete Task")
            delete_task
            ;;
        "")
            exit 0
            ;;
        *)
            main_menu
            ;;
    esac
}

add_task() {
    local desc due_input due_date

    desc=$(rofi -dmenu -p "Task Description:" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")
    [[ -z "$desc" ]] && main_menu

    due_input=$(rofi -dmenu -p "Due Date (YYYY-MM-DD or day number):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")
    due_date=$(validate_date "$due_input") || main_menu

    sqlite3 "$DB" "INSERT INTO tasks (description, due_date) VALUES ('$desc', '$due_date');"
    main_menu
}

delete_task() {
    entries=$(sqlite3 "$DB" "SELECT id, description FROM tasks;" | awk -F'|' '{ printf "%s: %s\n", $1, $2 }')
    choice=$(printf "%s" "$entries" | rofi -dmenu -p "Delete Task (select):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    task_id=$(echo "$choice" | cut -d':' -f1)
    [[ -n "$task_id" ]] && sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
    main_menu
}

main_menu

