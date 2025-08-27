#!/bin/bash

if systemctl is-active --quiet tor; then
    # Get IP info through Tor
    INFO=$(torsocks curl -s https://ipwho.is)

    # Check if response is valid JSON (status = true)
    STATUS=$(echo "$INFO" | jq -r .success)

    if [ "$STATUS" = "true" ]; then
        IP=$(echo "$INFO" | jq -r .ip)
        COUNTRY=$(echo "$INFO" | jq -r .country)

        echo "{\"text\": \"$IP\", \"tooltip\": \"Tor Exit: $COUNTRY\", \"class\": \"running\"}"
    else
        echo "{\"text\": \"Tor IP\", \"tooltip\": \"Failed to fetch location\", \"class\": \"error\"}"
    fi
else
    echo "{\"text\": \"Tor Off\", \"tooltip\": \"Tor service is not active\", \"class\": \"stopped\"}"
fi

