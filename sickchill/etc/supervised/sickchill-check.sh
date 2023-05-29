#!/bin/bash

if [ ! -f /etc/sickchill/config.ini ]; then
    echo "No config mounted for sickchill; mount a config directory in /etc/sickchill"
    exit 1
fi

/usr/bin/tailscale serve https / http://127.0.0.1:8080

supervisorctl start sickchill
