#!/usr/bin/env bash
set -euo pipefail

# Better debug logging
LOGFILE="/tmp/hypr-monitor-script.log"
exec > "$LOGFILE" 2>&1

echo "=== Hypr Monitor Script Debug ==="
echo "Timestamp: $(date)"

# Step 1: Find LID state file
LID_STATE_FILE=$(find /proc/acpi/button/lid* -name state | head -n1)

if [[ -z "${LID_STATE_FILE:-}" ]]; then
    echo "❌ Error: No lid state file found."
    exit 1
fi

echo "✅ Lid state file found: $LID_STATE_FILE"

# Step 2: Read lid state
LID_STATE_CONTENT=$(<"$LID_STATE_FILE")
echo "🔍 Lid state content: $LID_STATE_CONTENT"

# Step 3: Check if lid is open
if echo "$LID_STATE_CONTENT" | grep -iq "open"; then
    echo "🟢 Lid is open — enabling external monitor HDMI-A-1"
    hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x1080,1.0"
else
    echo "🔴 Lid is closed — checking monitor count"
    MONITOR_COUNT=$(hyprctl monitors | grep -c "Monitor")
    echo "🧮 Monitor count: $MONITOR_COUNT"
    
    if [[ "$MONITOR_COUNT" -ne 1 ]]; then
        echo "🟡 More than one monitor — disabling eDP-1"
        hyprctl keyword monitor "eDP-1, disable"
    else
        echo "⚠️ Only one monitor — skipping disable"
    fi
fi

echo "✅ Script finished."

