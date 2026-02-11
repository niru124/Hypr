#!/bin/bash

DB_FILE="$HOME/.local/share/bin/take/net_usage.db"

# awk does all the heavy lifting:
# 1. Filters for the current month.
# 2. Sums up usage for each day.
# 3. Calculates the total for the month.
# 4. At the end, it prints the formatted, JSON-escaped tooltip on the first line,
#    and the total usage in MB on the second line.
output=$(sqlite3 "$DB_FILE" "SELECT date, rx_bytes, tx_bytes FROM net_usage WHERE date LIKE '$(date +%Y-%m)%';" | awk -F'|' -v current_month="$(date +%Y-%m)" \
     -v current_date="$(date +%Y-%m-%d)" \
'\
      BEGIN {
          monthly_total_bytes = 0
          daily_total_bytes = 0
      }
     {
         day = $1 # Date is the first field
         rx_bytes = $2
         tx_bytes = $3

         total_day_bytes = rx_bytes + tx_bytes

         daily_rx[day] += rx_bytes
         daily_tx[day] += tx_bytes
         daily_breakdown[day] += total_day_bytes # Aggregate for tooltip
         monthly_total_bytes += total_day_bytes

         if (day == current_date) {
             daily_total_bytes += total_day_bytes
         }
     }
     END {
         if (monthly_total_bytes == 0) {
             print "No data for this month."
             printf "0.00"
             exit
         }

         # Sort the day keys to ensure chronological order
         n = asorti(daily_breakdown, sorted_indices)
         tooltip = ""
         for (i = 1; i <= n; i++) {
             day_key = sorted_indices[i]
             # Add escaped newline before each line except the first
             if (i > 1) {
                 tooltip = tooltip "\\n"
             }

             rx_mb = daily_rx[day_key] / 1048576
             tx_mb = daily_tx[day_key] / 1048576
             total_mb = daily_breakdown[day_key] / 1048576

             if (rx_mb >= 1024) {
                 rx_display = sprintf("%.2f GB", rx_mb / 1024)
             } else {
                 rx_display = sprintf("%.2f MB", rx_mb)
             }

             if (tx_mb >= 1024) {
                 tx_display = sprintf("%.2f GB", tx_mb / 1024)
             } else {
                 tx_display = sprintf("%.2f MB", tx_mb)
             }

             if (total_mb >= 1024) {
                 total_display = sprintf("%.2f GB", total_mb / 1024)
             } else {
                 total_display = sprintf("%.2f MB", total_mb)
             }

             tooltip = tooltip sprintf("%s: %s (RX: %s, TX: %s)", day_key, total_display, rx_display, tx_display)
         }

         monthly_total_mb = monthly_total_bytes / 1048576
         daily_total_mb = daily_total_bytes / 1048576

         # Add current day and monthly total to the tooltip
         tooltip = tooltip sprintf("\\n\\nToday: %.2f MB", daily_total_mb)

         if (monthly_total_mb >= 1024) {
             monthly_total_gb = monthly_total_mb / 1024
             tooltip = tooltip sprintf("\\nMonthly Total: %.2f GB", monthly_total_gb)
         } else {
             tooltip = tooltip sprintf("\\nMonthly Total: %.2f MB", monthly_total_mb)
         }

          print tooltip
          printf "%.2f\n", monthly_total_mb
          printf "%.2f", daily_total_mb
     }
')


# Read the three lines of output from awk into variables
tooltip_escaped=$(echo "$output" | sed -n '1p')
monthly_total_mb=$(echo "$output" | sed -n '2p')
daily_total_mb=$(echo "$output" | sed -n '3p')

# Convert daily_total_mb to GiB for the main text, if it's large enough
if (( $(echo "$daily_total_mb >= 1024" | bc -l) )); then
    daily_total_gb=$(echo "scale=1; $daily_total_mb / 1024" | bc -l)
    display_text="󰈀 ${daily_total_gb} GB"
else
    display_text="󰈀 ${daily_total_mb} MB"
fi


# Output the final JSON for Waybar
echo "{\"text\":\"$display_text\", \"alt\":\"$tooltip_escaped\"}"
