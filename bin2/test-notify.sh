#!/bin/bash
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
/usr/bin/notify-send -u critical -t 3000 "Layout: test" "hello"