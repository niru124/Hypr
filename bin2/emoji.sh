#!/usr/bin/env bash

# Path to your rofi theme

ROFI_THEME="$HOME/.config/rofi/clipboard.rasi"

# Run rofi emoji picker with custom keybindings
chosen=$(rofi \
  -modi emoji \
  -show emoji \
  -emoji-format '{emoji} {name}' \
  -kb-secondary-copy "" \
  -kb-custom-1 Ctrl+c \
  -theme "$ROFI_THEME")

# Check for exit status (10 = custom key 1 pressed)
if [[ $? -eq 10 ]]; then
    if command -v wl-copy &>/dev/null; then
        echo -n "$chosen" | wl-copy
    else
        notify-send "Emoji Picker" "Clipboard utility not found."
        exit 1
    fi

    notify-send "Emoji Picker" "Copied: $chosen"
fi
