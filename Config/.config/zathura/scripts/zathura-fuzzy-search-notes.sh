#!/bin/bash

# Debug log file
LOG_FILE="/tmp/zathura_notes_debug.log"

# Log function
log_debug() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [FUZZY_SEARCH] $1" >> "$LOG_FILE"
}

log_debug "Script started (Fuzzy Search)."

# Ensure fzf is installed
if ! command -v fzf &> /dev/null
then
    log_debug "Error: fzf is not installed."
    zenity --error --text="Error: fzf is not installed. Please install it to use fuzzy search (e.g., sudo apt install fzf)."
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

# Determine the directory of the PDF file
PDF_DIR=$(dirname "$FILE_PATH")
PDF_BASENAME=$(basename "$FILE_PATH" .pdf)

# Construct the path to the PDF's specific notes directory
NOTES_SUBDIR="_zathura_notes"
PDF_NOTES_DIR="$PDF_DIR/$NOTES_SUBDIR/${PDF_BASENAME}"

log_debug "Looking for notes in directory: '$PDF_NOTES_DIR'"

# Check if the notes directory exists and contains markdown files
if [ ! -d "$PDF_NOTES_DIR" ] || [ -z "$(find "$PDF_NOTES_DIR" -maxdepth 1 -type f -name '*.md' -print -quit)" ]; then
    log_debug "No notes directory or no Markdown files found for '$FILE_PATH' at '$PDF_NOTES_DIR'."
    zenity --info --text="No notes found for $(basename "$FILE_PATH").\nExpected directory: $PDF_NOTES_DIR"
    exit 0
fi

# Get the list of Markdown files (full paths)
MD_FILES=$(find "$PDF_NOTES_DIR" -maxdepth 1 -type f -name '*.md' | sort)

if [ -z "$MD_FILES" ]; then
    log_debug "No Markdown files found in '$PDF_NOTES_DIR'."
    zenity --info --text="No notes found for $(basename "$FILE_PATH")."
    exit 0
fi

log_debug "Found $(echo "$MD_FILES" | wc -l) Markdown files. Launching fzf."

# Use fzf to select a note
SELECTED_NOTE_PATH=$(echo "$MD_FILES" | fzf --prompt="Fuzzy search notes for $(basename "$FILE_PATH"): " --preview="cat {}")

if [ -z "$SELECTED_NOTE_PATH" ]; then
    log_debug "No note selected by user via fzf."
    # zenity --info --text="No note selected."
    exit 0
fi

log_debug "Selected note path via fzf: '$SELECTED_NOTE_PATH'"

# Open the selected Markdown file
alacritty -e nvim "$SELECTED_NOTE_PATH" &
log_debug "Opened Markdown file: '$SELECTED_NOTE_PATH'"
log_debug "Script finished."
