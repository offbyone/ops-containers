# Ops Containers

A collection of Docker Compose services for my homelab infrastructure, designed to place service containers on a Tailscale network without requiring a dedicated host for each service.

## Requirements

- Docker Engine
- Access to CIFS file share on blob
- Tailscale network (for sidecar containers)

## Sidecar Containers

Many services in this repository use the "sidecar" pattern to expose them on the Tailscale network. Each service that needs to be accessible over Tailscale imports the common `sidecar-compose.yaml` configuration, which:

1. Adds a Tailscale container to the service stack
2. Connects the container to my tailnet using an auth key
3. Optionally exposes the service using Tailscale Serve
4. Optionally enables Tailscale Funnel for external access

To use a sidecar with your service:

```yaml
# Import the sidecar configuration
include:
  - ../sidecar-compose.yaml

services:
  # Your regular service definition
  myservice:
    image: example/service:latest
    network_mode: "service:sidecar"  # Share the network namespace
    # ...

  # Extend the sidecar to connect to your service
  sidecar:
    extends:
      service: .sidecar
    environment:
      - TS_AUTH_KEY=${TS_AUTH_KEY}
      - TS_SERVE_PORT=8080  # Port your service listens on
      # - TS_FUNNEL=yes     # Uncomment to enable public access
```

## Available Services

### Media Management

- **[Radarr](https://radarr.video/)**: Movie management, connects to transmission and media storage
- **[Sonarr](https://sonarr.tv/)**: TV show management
- **[Lidarr](https://lidarr.audio/)**: Music management, connects to transmission and media storage
- **[Readarr](https://readarr.com/)**: E-book and audiobook management
- **[Whisparr](https://whisparr.com/)**: Adult content management
- **[Jackett](https://github.com/Jackett/Jackett)**: Torrent site proxy/indexer
- **[Tautulli](https://tautulli.com/)**: Plex server statistics and monitoring
- **[FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)**: Proxy server to bypass Cloudflare protection

### Media Libraries

- **[Calibre](https://calibre-ebook.com/)**: E-book management system
- **[Calibre-Web](https://github.com/janeczku/calibre-web)**: Web interface for Calibre library
- **[YACReader](https://www.yacreader.com/)**: Comic/manga reader and library manager
- **[Immich](https://immich.app/)**: Self-hosted photo and video backup solution

### Web Services

- **[ArchiveBox](https://archivebox.io/)**: Self-hosted web archive solution
- **[ChangeDetection](https://github.com/dgtlmoon/changedetection.io)**: Monitor website changes
- **[Cobalt](https://github.com/wukko/cobalt)**: YouTube and media downloader
- **[Pocket-ID](https://pocket-id.org/)**: Self-hosted authentication server
- **[BreezeWiki](https://breezewiki.com/)**: Privacy-focused wiki proxy
- **[Miniflux](https://miniflux.app/)**: RSS feed reader
- **[Tandoor](https://tandoor.dev/)**: Recipe management system

### Storage & Infrastructure

- **[Minio](https://min.io/)**: S3-compatible object storage
- **[Radicale](https://radicale.org/)**: CalDAV and CardDAV server

### Monitoring & Metrics

- **[Prometheus](https://prometheus.io/)**: Metrics collection and storage
- **Metrics**: Collection of Prometheus exporters:
  - **[Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)**: Probes endpoints over HTTP, HTTPS, DNS, TCP and ICMP
  - **[Plex Exporter](https://github.com/jrudio/plex-exporter)**: Monitors Plex Media Server metrics
  - **[SNMP Exporter](https://github.com/prometheus/snmp_exporter)**: Collects metrics from SNMP-enabled devices
  - **[Synology Monitor](https://github.com/breadlysm/prometheus-synology-exporter)**: Monitors Synology NAS systems
  - **[UDM Poller](https://github.com/unpoller/unpoller)**: Collects metrics from Ubiquiti UniFi devices
- **[OpenObserve](https://openobserve.ai/)**: Log management and analytics
- **[Victoria-Logs](https://docs.victoriametrics.com/VictoriaLogs/)**: High-performance logs storage
- **[Loki](https://grafana.com/oss/loki/)**: Log aggregation system
- **[Shop-Prometheus](https://github.com/prometheus/prometheus)**: Separate Prometheus instance for shop monitoring

### Utility Services

- **[Atuin](https://atuin.sh/)**: Shell history sync server
- **[Hoarder](https://github.com/normal-computing/hoarder)**: Data collection service
- **[SickChill](https://sickchill.github.io/)**: TV show management (legacy)
- **[Maybe](https://maybe.co/)**: Personal finance management
- **[Watchtower](https://containrrr.dev/watchtower/)**: Automatic container updates

## Host Environment

Most containers require a 64-bit architecture. While some can run on 32-bit ARM, many modern containers require 64-bit ARM or x86_64. Services are typically deployed across multiple hosts:

- **NUC (bitbucket)**: Primary host for resource-intensive services
- **NUC (prime)**: Primary host for video and AI-using services
- **Synology NAS (blob)**: Storage-intensive services

## Management

This repository includes:

- **Ansible playbooks** for deployment automation
- **Justfile** with common tasks for service management
- **Pre-commit hooks** for code quality
- **GitHub Actions** for container builds

### Deploying services

Services are deployed per host with `playbook-ops-containers.yml`. The list of
services for each host lives in `host_vars/<host>.yml`; each entry supports:

- `name` — service directory name (required)
- `compose_file` — compose filename (default `compose.yml`)
- `path` — service directory, if different from `name`
- `up` — set to `false` to bring the service **down** instead of up (default `true`)

```bash
# Deploy all services for a host
ansible-playbook playbook-ops-containers.yml --limit blob

# Preview changes without touching the host
ansible-playbook playbook-ops-containers.yml --limit blob --check
```

#### Limiting to a single service

Use `-e service=NAME` to act on just one service (the run fails fast if the name
isn't defined for that host):

```bash
ansible-playbook playbook-ops-containers.yml --limit blob -e service=minio
```

#### Pulling images

Image pulls use each compose file's own policy by default. Pass `-e pull=true`
to pull images before bringing services up:

```bash
ansible-playbook playbook-ops-containers.yml --limit blob -e pull=true

# combine with a single service
ansible-playbook playbook-ops-containers.yml --limit blob -e service=prometheus -e pull=true
```
