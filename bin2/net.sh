#!/bin/bash

IFACE="wlan0"
DB_PATH="$HOME/.local/share/bin/net_usage.db"

# Get current RX bytes (human-readable) from ifconfig output
RX_HUMAN=$(ifconfig "$IFACE" | grep "RX packets" | grep -oP '\(\K[^\)]+' )

# Get current month (YYYY-MM)
CURRENT_MONTH=$(date +%Y-%m)

# Get usage lines from DB separated by real newlines
TOOLTIP_LINES=$(sqlite3 "$DB_PATH" "
SELECT 
    date || ': ' || printf('%.2f MB', (rx_bytes + tx_bytes) / 1048576.0)
FROM usage
WHERE date LIKE '$CURRENT_MONTH%'
ORDER BY date;" | sed '/^\s*$/d')

# Fallback if empty
[[ -z "$TOOLTIP_LINES" ]] && TOOLTIP_LINES="No data yet"

# Total usage this month
TOTAL_MB=$(sqlite3 "$DB_PATH" "
SELECT 
    printf('%.2f', (MAX(rx_bytes) - MIN(rx_bytes) + MAX(tx_bytes) - MIN(tx_bytes)) / 1048576.0)
FROM usage
WHERE date LIKE '$CURRENT_MONTH%';")

[[ -z "$TOTAL_MB" ]] && TOTAL_MB="0.00"

# Compose tooltip with real newlines
TOOLTIP="${TOOLTIP_LINES}"$'\n\n'"Total: ${TOTAL_MB} MB"

# Escape real newlines to literal \n for JSON string output
TOOLTIP_ESCAPED=$(echo -n "$TOOLTIP" | sed ':a;N;$!ba;s/\n/\\n/g')

# Output JSON with live RX bytes as main text and monthly usage as tooltip
echo "{\"text\":\"󰈀 $RX_HUMAN\", \"alt\":\"$TOOLTIP_ESCAPED\"}"

