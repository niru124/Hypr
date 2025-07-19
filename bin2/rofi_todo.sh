#!/usr/bin/env bash

DB="${HOME}/.config/rofi/tasks.db"
ROFI_THEME="${HOME}/.config/rofi/styles/style_2.rasi"

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
            rofi -e "❌ Invalid full date: $input" -theme "$ROFI_THEME"
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
            rofi -e "❌ Invalid constructed date: $due_date" -theme "$ROFI_THEME"
            return 1
        fi

    # Invalid format
    else
        rofi -e "❌ Invalid date format: $input" -theme "$ROFI_THEME"
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
        | rofi -dmenu -i -p "TODO:" -theme "$ROFI_THEME")

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

    desc=$(rofi -dmenu -p "Task Description:" -theme "$ROFI_THEME")
    [[ -z "$desc" ]] && main_menu

    due_input=$(rofi -dmenu -p "Due Date (YYYY-MM-DD or day number):" -theme "$ROFI_THEME")
    due_date=$(validate_date "$due_input") || main_menu

    sqlite3 "$DB" "INSERT INTO tasks (description, due_date) VALUES ('$desc', '$due_date');"
    main_menu
}

delete_task() {
    entries=$(sqlite3 "$DB" "SELECT id, description FROM tasks;" | awk -F'|' '{ printf "%s: %s\n", $1, $2 }')
    choice=$(printf "%s" "$entries" | rofi -dmenu -p "Delete Task (select):" -theme "$ROFI_THEME")

    task_id=$(echo "$choice" | cut -d':' -f1)
    [[ -n "$task_id" ]] && sqlite3 "$DB" "DELETE FROM tasks WHERE id=$task_id;"
    main_menu
}

main_menu

