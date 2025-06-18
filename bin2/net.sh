#!/bin/bash

# Replace with your actual network interface
IFACE="wlan0"

# Extract the human-readable RX bytes (value inside parentheses)
RX_HUMAN=$(ifconfig $IFACE | grep "RX packets" | grep -oP '\(\K[^\)]+' )

echo "{\"text\": \"󰈀 $RX_HUMAN\", \"tooltip\": \"RX on $IFACE\"}"

