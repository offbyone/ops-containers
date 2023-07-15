#!/bin/ash
echo "Starting TS daemon"
tailscaled &
sleep 3
echo "Connecting to network"
tailscale up --authkey=${TS_AUTH_KEY}

if [ "${TS_SERVE_PORT:-xxx}" = "xxx" ]; then
    echo "Skipping serve status; using raw networking"
else
    tailscale serve https / localhost:${TS_SERVE_PORT}
fi

tailscale status
sleep infinity
