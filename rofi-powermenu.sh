#!/bin/bash
# ~/.config/rofi/powermenu.sh
# Bind to Super+Shift+E in i3 config:
#   bindsym $mod+shift+e exec --no-startup-id ~/.config/rofi/powermenu.sh

LOCK="󰌾  Lock"
SUSPEND="󰤄  Suspend"
REBOOT="󰑓  Reboot"
SHUTDOWN="󰐥  Shutdown"
LOGOUT="󰍃  Logout"

CHOSEN=$(printf "%s\n%s\n%s\n%s\n%s" \
    "$LOCK" "$SUSPEND" "$LOGOUT" "$REBOOT" "$SHUTDOWN" | \
    rofi -dmenu \
         -theme ~/.config/rofi/powermenu.rasi \
         -p "  Power" \
         -no-custom \
         -selected-row 0)

case "$CHOSEN" in
    "$LOCK")     loginctl lock-session ;;
    "$SUSPEND")  systemctl suspend ;;
    "$REBOOT")   systemctl reboot ;;
    "$SHUTDOWN")  systemctl poweroff ;;
    "$LOGOUT")   i3-msg exit ;;
esac
