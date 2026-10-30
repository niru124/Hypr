#!/usr/bin/env bash

set -eo pipefail

# --- Dependency Check ---
for cmd in rofi sqlite3 jq hyprctl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# --- Rofi Settings ---
ROFI_THEME="${HOME}/.config/rofi/clipboard.rasi"
ROFI_SCALE=14
HYPR_BORDER=0

# --- Database ---
DB="${HOME}/.config/rofi/tasks.db"

# --- Get settings from globalcontrol.sh ---
scrDir=$(dirname "$(realpath "$0")")
confDir="${HOME}/.config"
ROFI_THEME="${confDir}/rofi/clipboard.rasi"

# Set rofi scaling, ensure it's a number
rofiScale=${ROFI_SCALE:-10}
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
hypr_border=${HYPR_BORDER:-0}
wind_border=$((hypr_border * 3 / 2))
elem_border=$([ $hypr_border -eq 0 ] && echo "5" || echo $hypr_border)

# --- Evaluate spawn position ---
readarray -t curPos < <(hyprctl cursorpos -j | jq -r '.x,.y')
readarray -t monRes < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale,.x,.y')
readarray -t offRes < <(hyprctl -j monitors | jq -r '.[] | select(.focused==true).reserved | map(tostring) | join("\n")')
monRes[0]="$(awk -v w="${monRes[0]}" -v s="${monRes[2]}" 'BEGIN{printf "%d", w/s}')"
monRes[1]="$(awk -v h="${monRes[1]}" -v s="${monRes[2]}" 'BEGIN{printf "%d", h/s}')"
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

menu_width=$(( monRes[0] / 2 ))
r_override="window{location:${x_pos} ${y_pos};anchor:${x_pos} ${y_pos};x-offset:${x_off}px;y-offset:${y_off}px;border:${hypr_border}px;border-radius:${wind_border}px;width: ${menu_width}px;} wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
r_msg="message{background-color:@main-bg;text-color:@main-fg;padding:1em;} mainbox{children:[ \"wallbox\",\"message\",\"listbox\" ];}"

# --- End Styling ---

mkdir -p "$(dirname "$DB")"
sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, description TEXT, due_date TEXT, completed INTEGER DEFAULT 0);"


pick_date() {
    local prompt="${1:-Select due date}"

    local today=$(date +%Y-%m-%d)
    local tomorrow=$(date -d "+1 day" +%Y-%m-%d)
    local day2=$(date -d "+2 days" +%Y-%m-%d)
    local day3=$(date -d "+3 days" +%Y-%m-%d)
    local week=$(date -d "+1 week" +%Y-%m-%d)
    local month=$(date -d "+1 month" +%Y-%m-%d)

    local choice=$(printf "Today (%s)\nTomorrow (%s)\nIn 2 days (%s)\nIn 3 days (%s)\nNext week (%s)\nNext month (%s)\nManual entry..." \
        "$today" "$tomorrow" "$day2" "$day3" "$week" "$month" \
        | rofi -dmenu -i -p "$prompt" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    case "$choice" in
        "Today ("*) echo "$today" ;;
        "Tomorrow ("*) echo "$tomorrow" ;;
        "In 2 days ("*) echo "$day2" ;;
        "In 3 days ("*) echo "$day3" ;;
        "Next week ("*) echo "$week" ;;
        "Next month ("*) echo "$month" ;;
        "Manual entry..." | "")
            local input=$(rofi -dmenu -p "Date (YYYY-MM-DD or day number):" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")
            [[ -z "$input" ]] && return 1
            echo "$input" | validate_date
            return $?
            ;;
        *) return 1 ;;
    esac
}

validate_date() {
    local input="$1"
    local due_date

    if [[ "$input" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        if date -d "$input" "+%Y-%m-%d" >/dev/null 2>&1; then
            due_date="$input"
        else
            return 1
        fi

    elif [[ "$input" =~ ^[1-9][0-9]?$ ]]; then
        local year month day
        year=$(date +%Y)
        month=$(date +%m)
        day=$(printf "%02d" "$input")
        due_date="$year-$month-$day"

        if ! date -d "$due_date" "+%Y-%m-%d" >/dev/null 2>&1; then
            return 1
        fi

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
    local task_desc=$(sqlite3 "$DB" "SELECT description FROM tasks WHERE id=$task_id;")

    local action_choice=$(printf "↻ Transfer to Today\n✓ Mark as Done\n✗ Delete Task" \
        | rofi -dmenu -i -p "Overdue" -mesg "$task_desc" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override" -theme-str "$r_msg")

    case "$action_choice" in
        "↻ Transfer to Today")
            transfer_overdue_task "$task_id"
            ;;
        "✓ Mark as Done")
            sqlite3 "$DB" "UPDATE tasks SET completed=1 WHERE id=$task_id;"
            main_menu
            ;;
        "✗ Delete Task")
            sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
            main_menu
            ;;
        *)
            main_menu
            ;;
    esac
}

task_actions_menu() {
    local task_id="$1"
    local task_desc=$(sqlite3 "$DB" "SELECT description FROM tasks WHERE id=$task_id;")
    local current_status=$(sqlite3 "$DB" "SELECT completed FROM tasks WHERE id=$task_id;")
    local toggle_text="$( [ "$current_status" -eq 1 ] && echo "☐ Mark Incomplete" || echo "✓ Mark Complete" )"

    local action_choice=$(printf "%s\n✏️ Edit Task\n✗ Delete Task" "$toggle_text" \
        | rofi -dmenu -i -p "Actions" -mesg "$task_desc" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override" -theme-str "$r_msg")

    case "$action_choice" in
        "✓ Mark Complete" | "☐ Mark Incomplete")
            toggle_completion "$task_id"
            ;;
        "✏️ Edit Task")
            edit_task "$task_id" "$task_desc"
            ;;
        "✗ Delete Task")
            sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
            main_menu
            ;;
        *)
            main_menu
            ;;
    esac
}

get_today_date() {
    date +%Y-%m-%d
}

fmt_date() {
    local d="$1"
    local today=$(get_today_date)
    if [[ "$d" == "$today" ]]; then
        echo "Today"
    elif [[ "$d" == $(date -d "+1 day" "+%Y-%m-%d") ]]; then
        echo "Tomorrow"
    elif [[ "$d" < "$today" ]]; then
        local days=$(( ( $(date -d "$today" +%s) - $(date -d "$d" +%s) ) / 86400 ))
        echo "${days}d ago"
    else
        local days=$(( ( $(date -d "$d" +%s) - $(date -d "$today" +%s) ) / 86400 ))
        echo "in ${days}d"
    fi
}

trunc() {
    local s="$1" max="$2"
    if [[ ${#s} -gt $max ]]; then
        echo "${s:0:$((max-1))}…"
    else
        echo "$s"
    fi
}

get_overdue_tasks() {
    local today=$(get_today_date)
    sqlite3 "$DB" "SELECT id, description, due_date, completed FROM tasks WHERE due_date < '$today' AND completed = 0 ORDER BY due_date, id;" \
        | while IFS='|' read -r id desc date; do
            desc=$(trunc "$desc" 55)
            printf "%s: ⚠ %s (Overdue from %s)\n" "$id" "$desc" "$date"
        done
}

get_today_tasks() {
    local today=$(get_today_date)
    sqlite3 "$DB" "SELECT id, description, due_date, completed FROM tasks WHERE due_date = '$today' ORDER BY id;" \
        | while IFS='|' read -r id desc date completed; do
            desc=$(trunc "$desc" 65)
            local icon="☐"
            [[ "$completed" -eq 1 ]] && icon="✓"
            printf "%s: %s %s\n" "$id" "$icon" "$desc"
        done
}

get_upcoming_tasks() {
    local today=$(get_today_date)
    sqlite3 "$DB" "SELECT id, description, due_date, completed FROM tasks WHERE due_date > '$today' ORDER BY due_date, id;" \
        | while IFS='|' read -r id desc date completed; do
            desc=$(trunc "$desc" 50)
            local icon="☐"
            [[ "$completed" -eq 1 ]] && icon="✓"
            printf "%s: %s %s (%s)\n" "$id" "$icon" "$desc" "$date"
        done
}

count_tasks() {
    local today=$(get_today_date)
    local overdue=$(sqlite3 "$DB" "SELECT COUNT(*) FROM tasks WHERE due_date < '$today' AND completed = 0;" 2>/dev/null || echo 0)
    local due=$(sqlite3 "$DB" "SELECT COUNT(*) FROM tasks WHERE due_date = '$today' AND completed = 0;" 2>/dev/null || echo 0)
    local upcoming=$(sqlite3 "$DB" "SELECT COUNT(*) FROM tasks WHERE due_date > '$today' AND completed = 0;" 2>/dev/null || echo 0)
    echo "${overdue}|${due}|${upcoming}"
}

build_menu() {
    local overdue_tasks="$1"
    local today_tasks="$2"
    local other_tasks="$3"
    local counts="$4"
    local o_cnt d_cnt u_cnt
    IFS='|' read -r o_cnt d_cnt u_cnt <<< "$counts"

    local menu_options="+ Add Task"

    if [[ -n "$overdue_tasks" ]]; then
        menu_options+="\n── Overdue (${o_cnt}) ──\n$overdue_tasks"
    fi

    if [[ -n "$today_tasks" ]]; then
        menu_options+="\n── Today (${d_cnt}) ──\n$today_tasks"
    fi

    if [[ -n "$other_tasks" ]]; then
        menu_options+="\n── Upcoming (${u_cnt}) ──\n$other_tasks"
    fi

    echo -e "$menu_options"
}

main_menu() {
    local today=$(get_today_date)

    local overdue_tasks=$(get_overdue_tasks)
    local today_tasks=$(get_today_tasks)
    local other_tasks=$(get_upcoming_tasks)
    local counts=$(count_tasks)
    local menu_options=$(build_menu "$overdue_tasks" "$today_tasks" "$other_tasks" "$counts")

    choice=$(printf "%s" "$menu_options" \
        | rofi -dmenu -i -p "TODO" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")

    handle_choice "$choice"
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        "+ Add Task")
            add_task
            ;;
        "")
            exit 0
            ;;
        *" (Overdue from "*)
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
            local selected_desc=$(echo "$choice" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' | sed 's/ ([^)]*)$//')
            if [[ -n "$selected_id" ]]; then
                task_actions_menu "$selected_id" "$selected_desc"
            else
                main_menu
            fi
            ;;
    esac
}

add_task() {
    local desc due_date

    desc=$(rofi -dmenu -p "Task Description:" -theme "$ROFI_THEME" -theme-str "$r_scale" -theme-str "$r_override")
    [[ -z "$desc" ]] && main_menu

    due_date=$(pick_date "Due date for: $desc")
    if [[ -z "$due_date" ]]; then
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

    local new_due_date=$(pick_date "Due date (current: $old_due_date)")
    if [[ -z "$new_due_date" ]]; then
        new_due_date="$old_due_date"
    fi

    sqlite3 "$DB" "UPDATE tasks SET description='$(echo "$new_desc" | sed "s/'/''/g")', due_date='$new_due_date' WHERE id=$task_id;"
    main_menu
}

main() {
    mkdir -p "$(dirname "$DB")"
    sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, description TEXT, due_date TEXT, completed INTEGER DEFAULT 0);"
    main_menu
}

main
