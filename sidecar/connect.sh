#!/bin/ash
echo "Starting TS daemon"
tailscaled &
sleep 3
echo "Connecting to network"
tailscale up --authkey=${TS_AUTH_KEY}

tailscale status
sleep infinity
