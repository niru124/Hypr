#!/usr/bin/env bash

DB="${HOME}/.config/rofi/tasks.db"
icon=$'\ue003'

if [[ ! -f "$DB" ]]; then
    printf '{"text":"%s 0","tooltip":"No tasks yet"}\n' "$icon"
    exit 0
fi

overdue_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM tasks WHERE due_date < date('now') AND completed = 0;" 2>/dev/null || echo 0)

nl=$'\n'
tooltip=""

overdue=$(sqlite3 "$DB" "SELECT description, due_date FROM tasks WHERE due_date < date('now') AND completed = 0 ORDER BY due_date LIMIT 20;" 2>/dev/null)
if [[ -n "$overdue" ]]; then
    tooltip+="⚠ Overdue (${overdue_count}):${nl}"
    while IFS='|' read -r desc date; do
        [[ -z "$desc" ]] && continue
        tooltip+="  ${desc} [${date}]${nl}"
    done <<< "$overdue"
fi

today=$(sqlite3 "$DB" "SELECT description FROM tasks WHERE due_date = date('now') AND completed = 0 ORDER BY id LIMIT 10;" 2>/dev/null)
if [[ -n "$today" ]]; then
    tooltip+="☐ Today:${nl}"
    while IFS='|' read -r desc; do
        [[ -z "$desc" ]] && continue
        tooltip+="  ${desc}${nl}"
    done <<< "$today"
fi

done_today=$(sqlite3 "$DB" "SELECT description FROM tasks WHERE due_date = date('now') AND completed = 1 ORDER BY id LIMIT 10;" 2>/dev/null)
if [[ -n "$done_today" ]]; then
    tooltip+="✓ Done:${nl}"
    while IFS='|' read -r desc; do
        [[ -z "$desc" ]] && continue
        tooltip+="  ${desc}${nl}"
    done <<< "$done_today"
fi

[[ -z "$tooltip" ]] && tooltip="No tasks"

text="${icon} ${overdue_count}"
class="overdue"
[[ "$overdue_count" -eq 0 ]] && class=""

jq -c -n --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" '{text: $text, tooltip: $tooltip, class: $class}'
