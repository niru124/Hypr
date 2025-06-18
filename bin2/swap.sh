#!/bin/bash

mem_info=$(free -m)

mem_total=$(echo "$mem_info" | awk '/Mem:/ {print $2}')
mem_used=$(echo "$mem_info" | awk '/Mem:/ {print $3}')
mem_percent=$((mem_used * 100 / mem_total))

swap_total=$(echo "$mem_info" | awk '/Swap:/ {print $2}')
swap_used=$(echo "$mem_info" | awk '/Swap:/ {print $3}')

if [ "$swap_total" -eq 0 ]; then
  swap_percent=0
else
  swap_percent=$((swap_used * 100 / swap_total))
fi

printf '{
  "text": "󰾆 %dMB",
  "tooltip": "RAM: %dMB / %dMB (%d%%)\\nSwap: %dMB / %dMB (%d%%)"
}\n' \
"$mem_used" "$mem_used" "$mem_total" "$mem_percent" "$swap_used" "$swap_total" "$swap_percent"

