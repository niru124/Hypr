#!/bin/bash

# Revert to internal monitor only
hyprctl keyword monitor "HDMI-A-1,disable"
hyprctl keyword monitor "eDP-1,1920x1080@60.06,0x0,1"
