#!/bin/bash
STATE_FILE="$HOME/.config/hypr/hidden_windows.state"
HIDDEN_WS=999

mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

echo "DEBUG: Begin toggle script" >> "$HOME/toggle_debug.log"
WIN_ID=$(hyprctl activewindow | grep "window" | awk '{print $2}')
WIN_WS=$(hyprctl activewindow | grep "workspace" | awk '{print $2}')
echo "DEBUG: WIN_ID='$WIN_ID'  WIN_WS='$WIN_WS'" >> "$HOME/toggle_debug.log"

if [ -n "$WIN_ID" ]; then
  echo "DEBUG: Focused window exists" >> "$HOME/toggle_debug.log"
  if grep -q "^$WIN_ID " "$STATE_FILE"; then
    ORIG_WS=$(grep "^$WIN_ID " "$STATE_FILE" | awk '{print $2}')
    echo "DEBUG: Window is hidden, ORIG_WS='$ORIG_WS'" >> "$HOME/toggle_debug.log"

    # Focus and move back
    hyprctl dispatch focuswindow "$WIN_ID"
    hyprctl dispatch movetoworkspacesilent "$ORIG_WS"
    echo "DEBUG: Restored window $WIN_ID to workspace $ORIG_WS" >> "$HOME/toggle_debug.log"

    grep -v "^$WIN_ID " "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    echo "DEBUG: Removed from state file" >> "$HOME/toggle_debug.log"
  else
    echo "DEBUG: Window is not hidden yet, hiding it now" >> "$HOME/toggle_debug.log"
    echo "$WIN_ID $WIN_WS" >> "$STATE_FILE"
    hyprctl dispatch movetoworkspacesilent "$HIDDEN_WS"
    echo "DEBUG: Moved window $WIN_ID to hidden workspace $HIDDEN_WS" >> "$HOME/toggle_debug.log"
  fi
else
  echo "DEBUG: No focused window to hide" >> "$HOME/toggle_debug.log"
  echo "No focused window to hide."
fi

