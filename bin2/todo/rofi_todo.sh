#!/usr/bin/env bash

set -euo pipefail


# --- Dependency Check ---
for cmd in rofi sqlite3 jq hyprctl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# --- Rofi Settings ---
ROFI_THEME="${HOME}/.config/rofi/clipboard.rasi"
ROFI_SCALE=10
HYPR_BORDER=0

# --- Database ---
DB="${HOME}/.config/rofi/tasks.db"

# --- Get settings from globalcontrol.sh ---
scrDir=$(dirname "$(realpath "$0")")
# source "$scrDir/globalcontrol.sh"
confDir="${HOME}/.config" # Default value if globalcontrol.sh is not sourced
ROFI_THEME="${confDir}/rofi/clipboard.rasi"  # Or your preferred theme file

# Set rofi scaling, ensure it's a number
rofiScale=${ROFI_SCALE:-10} # Default value if not set by globalcontrol.sh
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
hypr_border=${HYPR_BORDER:-0} # Default value if not set by globalcontrol.sh
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
r_override="window{location:${x_pos} ${y_pos};anchor:${x_pos} ${y_pos};x-offset:${x_off}px;y-offset:${y_off}px;border:${hypr_border}px;border-radius:${wind_border}px;width: ${menu_width}px;} wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"

# --- End Styling ---

mkdir -p "$(dirname "$DB")"
sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, description TEXT, due_date TEXT, completed INTEGER DEFAULT 0);"


validate_date() {
    local input="$1"
    local due_date

    # Case 1: Full date format - YYYY-MM-DD
    if [[ "$input" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        if date -d "$input" "+%Y-%m-%d" >/dev/null 2>&1; then
            due_date="$input"
        else
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
            return 1
        fi

    # Invalid format
    else
        return 1
    fi

    echo "$due_date"
    return 0
}



toggle_completion() {
    local task_id="$1"
    local current_status
    current_status=$(sqlite3 "$DB" "SELECT completed FROM tasks WHERE id=$task_id;")
    local new_status=$((1 - current_status))
    sqlite3 "$DB" "UPDATE tasks SET completed=$new_status WHERE id=$task_id;"
    main_menu
}

overdue_task_actions_menu() {
    local task_id="$1"
    local task_desc="$2"

    local action_choice=$(printf "[➡️] Transfer to Today\n[✅] Mark as Done\n[-] Delete Task" \
        | rofi -dmenu -i -p "Overdue: $task_desc" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    case "$action_choice" in
        "[➡️] Transfer to Today")
            transfer_overdue_task "$task_id"
            ;;
        "[✅] Mark as Done")
            sqlite3 "$DB" "UPDATE tasks SET completed=1 WHERE id=$task_id;"
            main_menu
            ;;
        "[-] Delete Task")
            sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
            main_menu
            ;;
        "")
            main_menu
            ;;
    esac
}

task_actions_menu() {
    local task_id="$1"
    local task_desc="$2"
    local current_status=$(sqlite3 "$DB" "SELECT completed FROM tasks WHERE id=$task_id;")
    local toggle_text="$( [ "$current_status" -eq 1 ] && echo "[ ] Mark Incomplete" || echo "[✅] Mark Complete" )"

    local action_choice=$(printf "%s\n[✏️] Edit Task\n[-] Delete Task" "$toggle_text" \
        | rofi -dmenu -i -p "Actions for: $task_desc" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    case "$action_choice" in
        "[✅] Mark Complete" | "[ ] Mark Incomplete")
            toggle_completion "$task_id"
            ;;
        "[✏️] Edit Task")
            edit_task "$task_id" "$task_desc"
            ;;
        "[-] Delete Task")
            sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
            main_menu
            ;;
        "")
            main_menu
            ;;
    esac
}

get_today_date() {
    date +%Y-%m-%d
}

get_overdue_tasks() {
    local today=$(get_today_date)
    sqlite3 "$DB" "SELECT id, description, due_date, completed FROM tasks WHERE due_date < '$today' AND completed = 0 ORDER BY due_date, id;" \
        | awk -F'|' '{ printf "%s: %s %s (Overdue from %s)\n", $1, ($4 == 1 ? "✅" : "[ ]"), $2, $3 }'
}

get_today_tasks() {
    local today=$(get_today_date)
    sqlite3 "$DB" "SELECT id, description, due_date, completed FROM tasks WHERE due_date = '$today' ORDER BY id;" \
        | awk -F'|' '{ printf "%s: %s %s [%s]\n", $1, ($4 == 1 ? "✅" : "[ ]"), $2, $3 }'
}

get_upcoming_tasks() {
    local today=$(get_today_date)
    sqlite3 "$DB" "SELECT id, description, due_date, completed FROM tasks WHERE due_date > '$today' ORDER BY due_date, id;" \
        | awk -F'|' '{ printf "%s: %s %s [%s]\n", $1, ($4 == 1 ? "✅" : "[ ]"), $2, $3 }'
}

build_menu() {
    local overdue_tasks="$1"
    local today_tasks="$2"
    local other_tasks="$3"
    local menu_options="[+] Add Task\n[-] Delete Task"

    if [[ -n "$overdue_tasks" ]]; then
        menu_options+="\n--- Overdue Tasks ---\n$overdue_tasks"
    fi

    if [[ -n "$today_tasks" ]]; then
        menu_options+="\n--- Today's Tasks ---\n$today_tasks"
    fi

    if [[ -n "$other_tasks" ]]; then
        menu_options+="\n--- Upcoming Tasks ---\n$other_tasks"
    fi

    echo -e "$menu_options"
}

main_menu() {
    local menu
    local today=$(get_today_date)

    # Fetch overdue tasks
    local overdue_tasks=$(get_overdue_tasks)

    # Fetch today's tasks
    local today_tasks=$(get_today_tasks)

    local other_tasks=$(get_upcoming_tasks)

    local menu_options=$(build_menu "$overdue_tasks" "$today_tasks" "$other_tasks")

    choice=$(printf "%s" "$menu_options" \
        | rofi -dmenu -i -p "TODO:" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    handle_choice "$choice"
}

handle_choice() {
    local choice="$1"
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
        "*Overdue from*") # Handle overdue tasks
            local selected_id=$(echo "$choice" | awk -F':' '{print $1}')
            local selected_desc=$(echo "$choice" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' | sed 's/ (Overdue from.*)//')
            if [[ -n "$selected_id" ]]; then
                overdue_task_actions_menu "$selected_id" "$selected_desc"
            else
                main_menu
            fi
            ;;
        *)
            local selected_id=$(echo "$choice" | awk -F':' '{print $1}')
            local selected_desc=$(echo "$choice" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' | sed 's/ \[.*\]$//')
            if [[ -n "$selected_id" ]]; then
                task_actions_menu "$selected_id" "$selected_desc"
            else
                main_menu
            fi
            ;;
    esac
}

main_menu() {
    local menu
    local today=$(get_today_date)

    # Fetch overdue tasks
    local overdue_tasks=$(get_overdue_tasks)

    # Fetch today's tasks
    local today_tasks=$(get_today_tasks)

    local other_tasks=$(get_upcoming_tasks)

    local menu_options=$(build_menu "$overdue_tasks" "$today_tasks" "$other_tasks")

    choice=$(printf "%s" "$menu_options" \
        | rofi -dmenu -i -p "TODO:" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    handle_choice "$choice"
}

add_task() {
    local desc due_input due_date

    desc=$(rofi -dmenu -p "Task Description:" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")
    [[ -z "$desc" ]] && main_menu

    due_input=$(rofi -dmenu -p "Due Date (YYYY-MM-DD or day number):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")
    if ! due_date=$(validate_date "$due_input"); then
        rofi -e "❌ Invalid date format: $due_input" -theme "$ROFI_THEME" -theme-str "$r_override"
        main_menu
    fi

    sqlite3 "$DB" "INSERT INTO tasks (description, due_date) VALUES ('$(echo "$desc" | sed "s/'/''/g")', '$due_date');"
    main_menu
}

transfer_overdue_task() {
    local task_id="$1"
    local today=$(get_today_date)
    sqlite3 "$DB" "UPDATE tasks SET due_date='$today' WHERE id=$task_id;"
    main_menu
}

edit_task() {
    local task_id="$1"
    local old_desc="$2"
    local old_due_date=$(sqlite3 "$DB" "SELECT due_date FROM tasks WHERE id=$task_id;")

    local new_desc=$(rofi -dmenu -p "Edit Description (current: $old_desc):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override" -mesg "$old_desc")
    [[ -z "$new_desc" ]] && new_desc="$old_desc"

    local new_due_input=$(rofi -dmenu -p "Edit Due Date (current: $old_due_date):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override" -mesg "$old_due_date")
    local new_due_date
    if [[ -n "$new_due_input" ]]; then
        if ! new_due_date=$(validate_date "$new_due_input"); then
            rofi -e "❌ Invalid date format: $new_due_input" -theme "$ROFI_THEME" -theme-str "$r_override"
            main_menu
        fi
    else
        new_due_date="$old_due_date"
    fi

    sqlite3 "$DB" "UPDATE tasks SET description='$(echo "$new_desc" | sed "s/'/''/g")', due_date='$new_due_date' WHERE id=$task_id;"
    main_menu
}

delete_task() {
    entries=$(sqlite3 "$DB" "SELECT id, description FROM tasks;" | awk -F'|' '{ printf "%s: %s\n", $1, $2 }')
    choice=$(printf "%s" "$entries" | rofi -dmenu -p "Delete Task (select):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    task_id=$(echo "$choice" | cut -d':' -f1)
    [[ -n "$task_id" ]] && sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
    main_menu
}

main() {
    mkdir -p "$(dirname "$DB")"
    sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, description TEXT, due_date TEXT, completed INTEGER DEFAULT 0);"
    main_menu
}

main

