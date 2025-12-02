#!/bin/bash

     WORD=$(echo "" | rofi -dmenu -p "Search Dictionary:")

     if [ -n "$WORD" ]; then
        ~/.local/share/bin/dict/rofi_dict.py "$WORD" | rofi -dmenu -p "Definition:"
     fi

