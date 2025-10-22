#!/bin/bash

# SQLite database path (still in config for persistence)
DB_PATH="/home/nirantar/.config/zathura/notes.db"
# Base directory for Markdown notes
MD_NOTES_BASE_DIR="/home/nirantar/.config/zathura/md_notes"
# Debug log file
LOG_FILE="/tmp/zathura_notes_debug.log"

# Log function
log_debug() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ADD_NOTE] $1" >> "$LOG_FILE"
}

log_debug "Script started."

# Ensure zenity is installed
if ! command -v zenity &> /dev/null
then
    log_debug "Error: zenity is not installed."
    echo "Error: zenity is not installed. Please install it to use this script."
    exit 1
fi

# Get the current file path and page number from Zathura
FILE_PATH="$1"
PAGE_NUMBER="$2"

log_debug "Received FILE_PATH: '$FILE_PATH'"
log_debug "Received PAGE_NUMBER: '$PAGE_NUMBER'"

if [ -z "$FILE_PATH" ] || [ -z "$PAGE_NUMBER" ]; then
    log_debug "Error: Failed to get PDF file path or page number from Zathura."
    zenity --error --text="Failed to get PDF file path or page number from Zathura."
    exit 1
fi

# Create database and table if they don't exist
sqlite3 "$DB_PATH" <<EOF
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pdf_path TEXT NOT NULL,
    page_number INTEGER NOT NULL,
    note_title TEXT NOT NULL,
    md_file_path TEXT NOT NULL UNIQUE,
    timestamp TEXT NOT NULL
);
EOF
log_debug "Ensured database and table exist. Set journal_mode to WAL."

# Prompt user for note title
NOTE_TITLE=$(zenity --entry --title="Add Note to Zathura" --text="Enter a title for your note (e.g., 'Chapter 1 Summary'):" --width=400)

if [ -z "$NOTE_TITLE" ]; then
    log_debug "Note creation cancelled by user."
    zenity --info --text="Note creation cancelled."
    exit 0
fi
log_debug "Note title entered: '$NOTE_TITLE'"

# Sanitize note title for filename
SANITIZED_TITLE=$(echo "$NOTE_TITLE" | sed 's/[^a-zA-Z0-9_-]/_/g')
if [ -z "$SANITIZED_TITLE" ]; then
    SANITIZED_TITLE="untitled_note_$(date +%s)"
    log_debug "Sanitized title was empty, using generated: '$SANITIZED_TITLE'"
fi
log_debug "Sanitized title: '$SANITIZED_TITLE'"

# Determine the directory of the PDF file
PDF_DIR=$(dirname "$FILE_PATH")
PDF_BASENAME=$(basename "$FILE_PATH" .pdf)

# Create a new notes directory alongside the PDF
NOTES_SUBDIR="_zathura_notes"
PDF_NOTES_DIR="$PDF_DIR/$NOTES_SUBDIR/${PDF_BASENAME}"
mkdir -p "$PDF_NOTES_DIR"
log_debug "Created PDF notes directory: '$PDF_NOTES_DIR'"

# Construct Markdown file path
MD_FILE_PATH="$PDF_NOTES_DIR/${SANITIZED_TITLE}.md"
log_debug "Markdown file path: '$MD_FILE_PATH'"

# Check if a note with this title already exists for this PDF
if sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM notes WHERE pdf_path = '$FILE_PATH' AND note_title = '$NOTE_TITLE';" | grep -q "1"; then
    log_debug "Warning: Note with title '$NOTE_TITLE' already exists for '$FILE_PATH'. Opening existing note."
    zenity --warning --text="A note with the title \"$NOTE_TITLE\" already exists for this PDF. Opening existing note."
    xdg-open "$MD_FILE_PATH" &
    exit 0
fi

# Write initial metadata to Markdown file
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "---" > "$MD_FILE_PATH"
echo "pdf_path: $FILE_PATH" >> "$MD_FILE_PATH"
echo "page_number: $PAGE_NUMBER" >> "$MD_FILE_PATH"
echo "note_title: $NOTE_TITLE" >> "$MD_FILE_PATH"
echo "timestamp: $TIMESTAMP" >> "$MD_FILE_PATH"
echo "---" >> "$MD_FILE_PATH"
echo "\n# $NOTE_TITLE\n\n" >> "$MD_FILE_PATH"
echo "Add your note content here..." >> "$MD_FILE_PATH"
log_debug "Wrote initial metadata to Markdown file."

# Insert note metadata into database with explicit transaction
INSERT_SQL="BEGIN TRANSACTION; INSERT INTO notes (pdf_path, page_number, note_title, md_file_path, timestamp) VALUES ('$FILE_PATH', $PAGE_NUMBER, '$NOTE_TITLE', '$MD_FILE_PATH', '$TIMESTAMP'); COMMIT;"
log_debug "Executing INSERT with transaction: '$INSERT_SQL'"
sqlite3 "$DB_PATH" "$INSERT_SQL"
INSERT_STATUS=$?
log_debug "sqlite3 INSERT exit status: $INSERT_STATUS"

if [ "$INSERT_STATUS" -ne 0 ]; then
    log_debug "Error: SQLite INSERT failed with status $INSERT_STATUS."
    zenity --error --text="Failed to save note to database. Check permissions or log file for details."
    exit 1
fi
log_debug "Note metadata inserted into DB with transaction."

# Dump entire notes table content immediately after insert for debugging
log_debug "Dumping entire notes table content immediately after INSERT:"
sqlite3 "$DB_PATH" "SELECT id, pdf_path, page_number, note_title, md_file_path, timestamp FROM notes;" >> "$LOG_FILE"

zenity --info --text="Note \"$NOTE_TITLE\" created at 
$MD_FILE_PATH
Opening Markdown file for editing."

# Open the Markdown file for editing
alacritty -e nvim "$MD_FILE_PATH" &
log_debug "Script finished."
