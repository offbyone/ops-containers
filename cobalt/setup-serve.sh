# /bin/bash
docker compose up -d sidecar
docker compose exec sidecar tailscale serve --yes --bg --set-path /web localhost:9001
docker compose exec sidecar tailscale serve --yes --bg localhost:9000
