#!/usr/bin/env bash

# Config
JSON_FILE="$HOME/.config/hypr/quotes.json"
CHAR_LIMIT=40

# Function to wrap text at CHAR_LIMIT
wrap_text() {
    local text="$1"
    local wrapped=""
    local line=""

    for word in $text; do
        local line_length=${#line}
        local word_length=${#word}
        local total_length=$((line_length + word_length + 1))  # +1 for space

        if (( total_length > CHAR_LIMIT )); then
            wrapped+="$line\n"
            line="$word"
        else
            if [[ -z "$line" ]]; then
                line="$word"
            else
                line="$line $word"
            fi
        fi
    done

    wrapped+="$line"
    echo -e "$wrapped"
}

# Get total number of quotes
quote_count=$(jq length "$JSON_FILE")

# Get a random index from 0 to (length - 1)
random_index=$((RANDOM % quote_count))

# Extract quote and author using the random index
quote=$(jq -r ".[$random_index].quote" "$JSON_FILE")
author=$(jq -r ".[$random_index].author" "$JSON_FILE")

# Wrap the quote
wrapped_quote=$(wrap_text "$quote")

# Output for Waybar/Hyprlock
echo -e "$wrapped_quote\n- $author"

