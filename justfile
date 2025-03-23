set dotenv-load

build:
    docker build -t ghcr.io/offbyone/sickchill:latest -f sickchill/Dockerfile .

run: build
    docker run --env TS_AUTH_KEY=$TS_AUTH_KEY --rm -it \
        -v '/dev/net/tun:/dev/net/tun' --cap-add=NET_ADMIN --cap-add=NET_RAW \
        -v tailscale-sickchill:/var/lib/tailscale \
        -v blob-media:/mnt/media \
        -v /Users/offby1/projects/home/containers/sickchill/sickchill-20230530005247/:/var/lib/sickchill/ \
        --name=sickchill ghcr.io/offbyone/sickchill:latest

shell: build
    docker run --env TS_AUTH_KEY=$TS_AUTH_KEY --rm -it \
        -v '/dev/net/tun:/dev/net/tun' --cap-add=NET_ADMIN --cap-add=NET_RAW \
        -v tailscale-sickchill:/var/lib/tailscale \
        -v blob-media:/mnt/media \
        -v /Users/offby1/projects/home/containers/sickchill/sickchill-20230530005247/:/var/lib/sickchill/ \
        --name=sickchill ghcr.io/offbyone/sickchill:latest /bin/bash

bitbucket-up: \
     (svc-up "atuin") \
     (svc-up "changedetection") \
     (svc-up "cobalt") \
     (svc-up "jackett") \
     (svc-up "metrics") \
     (svc-up "metrics/blackbox-exporter") \
     (svc-up "metrics/plex-exporter") \
     (svc-up "metrics/snmp-exporter") \
     (svc-up "metrics/synology-monitor") \
     (svc-up "metrics/udm-poller") \
     (svc-up "radarr") \
     (svc-up "sickchill")

bitbucket-down: \
     (svc-down "atuin") \
     (svc-down "changedetection") \
     (svc-down "cobalt") \
     (svc-down "jackett") \
     (svc-down "metrics") \
     (svc-down "metrics/blackbox-exporter") \
     (svc-down "metrics/plex-exporter") \
     (svc-down "metrics/snmp-exporter") \
     (svc-down "metrics/synology-monitor") \
     (svc-down "metrics/udm-poller") \
     (svc-down "radarr") \
     (svc-down "sickchill")

svc-up name:
    cd {{ name }} && docker compose up --wait

svc-down name:
    cd {{ name }} && docker compose down

update: update-precommit update-gha

@update-precommit:
    uvx --with pre-commit-uv pre-commit autoupdate -j3

@update-gha:
    uvx --from git+https://github.com/offbyone/gha-update@gha-without-pyproject gha-update
