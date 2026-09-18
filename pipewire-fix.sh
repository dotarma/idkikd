#!/bin/bash
# pipewire-fix.sh
# fixes stale locks and restarts the pipewire stack
# place at: ~/scripts/pipewire-fix.sh
# usage: bash ~/scripts/pipewire-fix.sh

set -e

uid=$(id -u)
runtime="/run/user/$uid"

log() { echo "  $1"; }
die() { echo "  error: $1" >&2; exit 1; }

echo ""
echo "  pipewire fix"
echo "  ------------"
echo ""

# check runtime dir
if [ ! -d "$runtime" ]; then
  die "runtime dir $runtime not found"
fi

# stop services
log "stopping services..."
systemctl --user stop pipewire-pulse pipewire wireplumber 2>/dev/null || true
systemctl --user stop pipewire-pulse.socket pipewire.socket 2>/dev/null || true
sleep 1

# kill any stray processes
log "killing stray processes..."
pkill -x pipewire       2>/dev/null || true
pkill -x pipewire-pulse 2>/dev/null || true
pkill -x wireplumber    2>/dev/null || true
pkill -x pulseaudio     2>/dev/null || true
sleep 1

# remove stale locks and sockets
log "removing stale locks..."
rm -f "$runtime/pipewire-0.lock"
rm -f "$runtime/pipewire-0-manager.lock"
rm -f "$runtime/pipewire-0"
rm -f "$runtime/pipewire-0-manager"
rm -rf "$runtime/pulse"

# start in correct order
log "starting pipewire.socket..."
systemctl --user start pipewire.socket
sleep 0.5

log "starting pipewire..."
systemctl --user start pipewire.service
sleep 1

# verify socket exists
if [ ! -S "$runtime/pipewire-0" ]; then
  die "pipewire socket not created — check: journalctl --user -xeu pipewire"
fi

log "starting wireplumber..."
systemctl --user start wireplumber
sleep 1

log "starting pipewire-pulse..."
systemctl --user start pipewire-pulse.socket
systemctl --user start pipewire-pulse
sleep 1

# verify with pactl
log "verifying..."
if pactl info &>/dev/null; then
  echo ""
  echo "  done. pipewire is running."
  echo "  server: $(pactl info | grep 'server name' | awk -F': ' '{print $2}')"
  echo "  sink:   $(pactl info | grep 'default sink' | awk -F': ' '{print $2}')"
  echo ""
else
  die "pactl could not connect — check: journalctl --user -xeu pipewire-pulse"
fi
