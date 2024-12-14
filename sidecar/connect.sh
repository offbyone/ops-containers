#!/bin/ash
echo "Starting TS daemon"
tailscaled &
sleep 3
echo "Connecting to network"
tailscale up --authkey=${TS_AUTH_KEY}

if [ "${TS_SERVE_PORT:-xxx}" = "xxx" ]; then
    echo "Skipping serve status; using raw networking"
else
    if [ "${TS_SERVE_HTTPS:-yes}" = "yes" ]; then
        tailscale serve --yes --bg localhost:${TS_SERVE_PORT}
    fi

    if [ "${TS_SERVE_HTTP:-yes}" = "yes" ]; then
        # this is over the tailnet, so I'm fine with HTTP here too
        tailscale serve --yes --bg --http 80 localhost:${TS_SERVE_PORT}
    fi

    if [ "${TS_FUNNEL:-no}" = "yes" ]; then
        echo "Starting funnel"
        tailscale funnel --bg ${TS_SERVE_PORT}
    fi
fi

tailscale status
sleep infinity
