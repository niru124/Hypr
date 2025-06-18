#!/bin/bash

# Get nvidia-smi output
smi_output=$(nvidia-smi --query-gpu=utilization.gpu,power.draw,power.limit,memory.used,memory.total,temperature.gpu,name --format=csv,noheader,nounits)

# Parse values
IFS=',' read -r gpu_util power_draw power_limit mem_used mem_total temp name <<< "$smi_output"

# Format output
echo "{\"text\": \"${gpu_util}%\", \
\"tooltip\": \"Name: $name\\nTemp: ${temp}°C\\nPower: ${power_draw}W / 50W\\nMemory: ${mem_used}MiB / ${mem_total}MiB\", \
\"class\": \"gpu\"}"

