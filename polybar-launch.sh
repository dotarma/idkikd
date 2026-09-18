#!/bin/bash
# ~/.config/polybar/launch.sh
# Called from i3 config:
#   exec_always --no-startup-id ~/.config/polybar/launch.sh

# Kill any running polybar instances
killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 0.1; done

# Launch one bar per monitor
if type "xrandr" > /dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload main 2>&1 | tee -a /tmp/polybar-"$m".log &
    done
else
    polybar --reload main 2>&1 | tee -a /tmp/polybar.log &
fi

echo "Polybar launched"
