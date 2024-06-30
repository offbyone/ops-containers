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


up: (svc-up sickchill)

down: (svc-down sickchill)

svc-up name:
    cd {{ name }} && docker compose up -d

svc-down name:
    cd {{ name }} && docker compose down
