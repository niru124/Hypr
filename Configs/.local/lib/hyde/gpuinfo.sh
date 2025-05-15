#!/usr/bin/env bash

# Use sudo to run nvidia-smi
gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

# Check if the output is valid
if [[ -n "$gpu_usage" ]]; then
  # Output the usage in a Waybar-friendly JSON format
  echo "{\"text\": \"GPU: ${gpu_usage}%\", \"tooltip\": \"GPU Utilization\"}"
else
  # Handle errors or no output
  echo "{\"text\": \"Error\", \"tooltip\": \"Failed to fetch GPU info\"}"
fi

