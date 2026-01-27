#!/bin/bash
# ~/.config/ranger/wormhole_wrapper.sh

temp_file=$(mktemp)

# Run wormhole-rs send and show output
# We use tee to capture output while showing it
wormhole-rs send "$@" 2>&1 | tee "$temp_file" &
WORMHOLE_PID=$!

# Background loop to find the code and copy it
(
    while sleep 0.1; do
        if [ -f "$temp_file" ]; then
            code=$(grep -oP "(?<=This wormhole's code is: )[0-9]+-[a-z]+-[a-z]+" "$temp_file" | head -n 1)
            if [ -n "$code" ]; then
                echo -n "$code" | wl-copy
                break
            fi
        fi
        if ! kill -0 $WORMHOLE_PID 2>/dev/null; then
            break
        fi
    done
) &

# Wait for the main process
wait $WORMHOLE_PID
rm -f "$temp_file"
