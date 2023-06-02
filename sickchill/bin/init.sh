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

shopt -s nullglob

for init_check in /etc/supervised/init.d/*; do
    if ! $init_check; then
        s_die "$init_check failed, can't continue"
    fi
done
