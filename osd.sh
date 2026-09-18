#!/bin/bash
# ~/scripts/osd.sh
# usage: osd.sh "volume" 65

label=$1
val=$2

dunstify \
  -h string:x-dunst-stack-tag:osd \
  -t 1500 \
  "$label" "$val%"
