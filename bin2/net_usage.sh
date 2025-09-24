#!/bin/bash

# CONFIGURATION
DB_PATH="$HOME/.local/share/bin/net_usage.db"  
IFACE="wlan0"

# Ensure database and table exist
init_db() {
    sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS usage (
    date TEXT PRIMARY KEY,
    rx_bytes INTEGER,
    tx_bytes INTEGER
);
EOF
}

# Get RX and TX bytes from /sys (more reliable than ifconfig)
get_bytes() {
    RX_BYTES=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    TX_BYTES=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
}

# Store today's usage (total bytes, calculate delta in sqlite later)
store_usage() {
    TODAY=$(date +%F)
    get_bytes
    sqlite3 "$DB_PATH" <<EOF
REPLACE INTO usage (date, rx_bytes, tx_bytes)
VALUES ('$TODAY', $RX_BYTES, $TX_BYTES);
EOF
}

# Get monthly or yearly usage
query_usage() {
    case $1 in
        month)
            PERIOD=$(date +%Y-%m)
            ;;
        year)
            PERIOD=$(date +%Y)
            ;;
        *)
            echo "Usage: $0 [month|year]"
            exit 1
            ;;
    esac

    sqlite3 "$DB_PATH" <<EOF
.headers on
.mode column
SELECT 
    substr(date, 1, ${#PERIOD}) AS period,
    (max(rx_bytes) - min(rx_bytes)) / 1048576.0 AS RX_MB,
    (max(tx_bytes) - min(tx_bytes)) / 1048576.0 AS TX_MB,
    ((max(rx_bytes) - min(rx_bytes)) + (max(tx_bytes) - min(tx_bytes))) / 1048576.0 AS TOTAL_MB
FROM usage
WHERE date LIKE '$PERIOD%'
GROUP BY period;
EOF
}

# Main logic
init_db

if [[ "$1" == "month" || "$1" == "year" ]]; then
    query_usage "$1"
else
    store_usage
fi
