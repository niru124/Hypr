#!/bin/bash

# Show all partitions and disks with their label and mountpoint in Waybar JSON format
full_tooltip=""
first_tooltip_line=true

while read -r name type label mountpoint fstype; do
	# Skip loop devices
	if [[ "$name" == "/dev/loop"* ]]; then
		continue
	fi

	# Default values for label and mountpoint
	[[ -z "$label" ]] && label="NoLabel"
	[[ -z "$mountpoint" ]] && mountpoint="Not mounted"

	# Determine status for tooltip
	if [[ -z "$mountpoint" || "$mountpoint" == "Not mounted" ]]; then
		status="Not mounted"
	else
		status="Mounted"
	fi

	# Construct individual tooltip line
	current_tooltip_line="🖴 $name [$label] [$mountpoint] ($type)\nFilesystem: $fstype\nStatus: $status"

	# Append to full tooltip
	if ! $first_tooltip_line; then
		full_tooltip+="\n---\n"
	fi
	full_tooltip+="$current_tooltip_line"
	first_tooltip_line=false
done < <(lsblk -nrpo NAME,TYPE,LABEL,MOUNTPOINT,FSTYPE)

# Final JSON output for Waybar
printf '{"text":"", "tooltip":"%s", "class":"disk-status"}\n' "$full_tooltip"
