#!/bin/bash

# List all partitions (excluding loop devices and system mounts like / and /boot)
# with label and mountpoint for rofi menu
options=$(lsblk -nrpo NAME,TYPE,LABEL,MOUNTPOINT | while read -r name type label mountpoint; do
  # Skip loop devices
  if [[ "$name" == "/dev/loop"* ]]; then
    continue
  fi

  # Skip system mounts like / and /boot to prevent accidental unmounting
  if [[ "$mountpoint" == "/" || "$mountpoint" == "/boot" ]]; then
    continue
  fi

  # Only consider partitions
  if [[ "$type" != "part" ]]; then
    continue
  fi

  [[ -z "$label" ]] && label="NoLabel"
  [[ -z "$mountpoint" ]] && mountpoint="Not mounted"
  echo "$name [$label] [$mountpoint] ($type)"
done)

# Select device from rofi
selected=$(echo "$options" | rofi -dmenu -p "Select disk for action")

[[ -z "$selected" ]] && exit

# Extract device name (first field)
device=$(echo "$selected" | awk '{print $1}')

# Check if mounted
mountpoint=$(lsblk -no MOUNTPOINT "$device")

if [[ -z "$mountpoint" ]]; then
  # Not mounted: ask to mount
  action=$(echo -e "Mount\nCancel" | rofi -dmenu -p "Mount $device?")
  if [[ "$action" == "Mount" ]]; then
    udisksctl mount -b "$device" && notify-send "Mounted $device"
  fi
else
  # Mounted: ask to unmount
  action=$(echo -e "Unmount\nCancel" | rofi -dmenu -p "Unmount $device?")
  if [[ "$action" == "Unmount" ]]; then
    udisksctl unmount -b "$device" && notify-send "Unmounted $device"
  fi
fi
