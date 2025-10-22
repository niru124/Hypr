#!/bin/bash

# SQLite database path
DB_PATH="/home/nirantar/.config/zathura/notes.db"
# Debug log file
LOG_FILE="/tmp/zathura_notes_debug.log"

# Log function
log_debug() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [VIEW_NOTES_INTERACTIVE] $1" >> "$LOG_FILE"
}

log_debug "Script started (Interactive List View with Page No.)."
log_debug "--- SCRIPT INVOKED ---"

# Ensure zenity is installed
if ! command -v zenity &> /dev/null
then
    log_debug "Error: zenity is not installed."
    echo "Error: zenity is not installed. Please install it to use this script."
    exit 1
fi

# Get the current file path from Zathura
FILE_PATH="$1"

log_debug "Received FILE_PATH: '$FILE_PATH'"

if [ -z "$FILE_PATH" ]; then
    log_debug "Error: Failed to get PDF file path from Zathura."
    zenity --error --text="Failed to get PDF file path from Zathura."
    exit 1
fi

# Check if the database exists
if [ ! -f "$DB_PATH" ]; then
    log_debug "Error: No notes database found at '$DB_PATH'."
    zenity --info --text="No notes database found. Add some notes first!"
    exit 0
fi
log_debug "Database exists: '$DB_PATH'"

# Retrieve note titles, page numbers, and paths for the current PDF
SELECT_SQL="SELECT note_title, page_number, md_file_path FROM notes WHERE pdf_path = '$FILE_PATH' ORDER BY page_number, timestamp ASC;"
log_debug "Executing SELECT: '$SELECT_SQL'"
NOTES_DATA=$(sqlite3 "$DB_PATH" "$SELECT_SQL")
log_debug "Raw notes data from DB for query: '$NOTES_DATA'"

if [ -z "$NOTES_DATA" ]; then
    log_debug "No notes found for '$FILE_PATH'."
    zenity --info --text="No notes found for $(basename "$FILE_PATH")."
    exit 0
fi

# Prepare data for zenity --list
LIST_ITEMS=()
while IFS= read -r line; do
    TITLE=$(echo "$line" | cut -d'|' -f1)
    PAGE=$(echo "$line" | cut -d'|' -f2)
    MD_PATH=$(echo "$line" | cut -d'|' -f3)
    DISPLAY_TEXT="$TITLE (Page $PAGE)"
    LIST_ITEMS+=("$DISPLAY_TEXT" "$MD_PATH")
done <<< "$NOTES_DATA"
log_debug "Prepared ${#LIST_ITEMS[@]} items for zenity list."

# Display list and get user selection
SELECTED_NOTE_PATH=$(zenity --list \
    --title="Zathura Notes for $(basename "$FILE_PATH")" \
    --text="Select a note to open:" \
    --column="Note" \
    --column="MD File Path" \
    --hide-column=2 \
    --print-column=2 \
    --width=500 --height=400 \
    "${LIST_ITEMS[@]}")

if [ -z "$SELECTED_NOTE_PATH" ]; then
    log_debug "No note selected by user."
    # zenity --info --text="No note selected."
    exit 0
fi
log_debug "Selected note path: '$SELECTED_NOTE_PATH'"

# Open the selected Markdown file
alacritty -e nvim "$SELECTED_NOTE_PATH" &
log_debug "Opened Markdown file: '$SELECTED_NOTE_PATH'"
log_debug "Script finished."
