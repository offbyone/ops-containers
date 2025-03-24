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

- **Radarr**: Movie management, connects to transmission and media storage
- **Sonarr**: TV show management, replacement for SickChill
- **Lidarr**: Music management, connects to transmission and media storage
- **Readarr**: E-book and audiobook management
- **Jackett**: Torrent site proxy/indexer
- **Tautulli**: Plex server statistics and monitoring

### Media Libraries

- **Calibre**: E-book management system
- **Calibre-Web**: Web interface for Calibre library
- **YACReader**: Comic/manga reader and library manager
- **Immich**: Self-hosted photo and video backup solution

### Web Services

- **ArchiveBox**: Self-hosted web archive solution
- **ChangeDetection**: Monitor website changes
- **Cobalt**: YouTube and media downloader
- **Pocket-ID**: Self-hosted authentication server
- **Postmarks**: Bookmark manager
- **BreezeWiki**: Privacy-focused wiki proxy

### Monitoring & Metrics

- **Prometheus**: Metrics collection and storage
- **Metrics**: Various exporters (Plex, SNMP, UDM, etc.)
- **OpenObserve**: Log management and analytics
- **Victoria-Logs**: High-performance logs storage

### Utility Services

- **Atuin**: Shell history sync server
- **Hoarder**: Data collection service
- **OFSM**: Factorio server _not enabled_

## Host Environment

Most containers require a 64-bit architecture. While some can run on 32-bit ARM, many modern containers require 64-bit ARM or x86_64. Services are typically deployed across multiple hosts:

- **NUC (bitbucket)**: Primary host for resource-intensive services
- **NUC (prime)**: Primary host for video and AI-using services
