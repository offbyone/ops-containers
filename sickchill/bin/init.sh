#!/bin/bash
# shellcheck shell=bash
set -e -o pipefail

s_die() {
    echo "$@"
    kill -SIGQUIT 1
    exit
}

PATH=/app/supervisor/bin:$PATH
export PATH

# start tailscale first
supervisorctl start tailscaled

if [[ $(/usr/bin/tailscale status --self --json | jq -r .Self.Online) != "true" ]]; then
    if [ "${TS_AUTH_KEY}x" = "x" ]; then
        s_die "TS_AUTH_KEY not set, can't continue"
    fi

    if [ "${TS_HOSTNAME}x" = "x" ]; then
        s_die "TS_HOSTNAME not set, can't continue"
    fi

    /usr/bin/tailscale up --hostname="$TS_HOSTNAME" --auth-key="$TS_AUTH_KEY"
else
    echo "Tailscale is up and configured"
fi

shopt -s nullglob

for init_check in /etc/supervised/init.d/*; do
    if ! $init_check; then
        s_die "$init_check failed, can't continue"
    fi
done
