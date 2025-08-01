# Docker Compose to Nomad Migration Plan

## Overview

This document outlines the plan for migrating the current Docker Compose-based container services to HashiCorp Nomad. The current architecture uses paired containers (service + sidecar) for each application, with the sidecar providing networking via Tailscale.

## Migration Checklist

- [x] Install Nomad cluster
- [ ] Set up CSI plugins for CIFS/network volumes
- [ ] Configure Vault integration for secrets
- [ ] Establish network strategy
- [ ] Migrate first service (Jackett)
- [ ] Create templates for common service patterns
- [ ] Migrate remaining services in batches

## Infrastructure Setup

### Nomad Cluster

Nomad cluster has been installed and is operational.

### CSI Plugin Setup for CIFS Volumes

To enable CIFS/SMB volume support in Nomad:

1. **Install required packages on all Nomad clients**:
   ```bash
   # For Ubuntu/Debian
   apt-get install -y cifs-utils
   
   # For CentOS/RHEL
   yum install -y cifs-utils
   ```

2. **Enable privileged containers** in Nomad client config:
   ```hcl
   plugin "docker" {
     config {
       allow_privileged = true
     }
   }
   ```

3. **Deploy the SMB CSI Controller plugin**:
   ```hcl
   job "csi-smb-controller" {
     datacenters = ["dc1"]
     
     group "controller" {
       count = 2  // For high availability
       
       task "plugin" {
         driver = "docker"
         
         config {
           image = "mcr.microsoft.com/k8s/csi/smb-csi:v1.7.0"
           args = [
             "--v=5",
             "--nodeid=${attr.unique.hostname}",
             "--endpoint=unix:///csi/csi.sock",
             "--drivername=smb.csi.k8s.io"
           ]
           privileged = true
         }
         
         csi_plugin {
           id        = "smb"
           type      = "controller"
           mount_dir = "/csi"
         }
         
         resources {
           cpu    = 500
           memory = 256
         }
       }
     }
   }
   ```

4. **Deploy the SMB CSI Node plugin** on all clients:
   ```hcl
   job "csi-smb-node" {
     datacenters = ["dc1"]
     type = "system"  // Ensures it runs on all clients
     
     group "nodes" {
       task "plugin" {
         driver = "docker"
         
         config {
           image = "mcr.microsoft.com/k8s/csi/smb-csi:v1.7.0"
           args = [
             "--v=5",
             "--nodeid=${attr.unique.hostname}",
             "--endpoint=unix:///csi/csi.sock",
             "--drivername=smb.csi.k8s.io"
           ]
           privileged = true
         }
         
         csi_plugin {
           id        = "smb"
           type      = "node"
           mount_dir = "/csi"
         }
         
         resources {
           cpu    = 500
           memory = 256
         }
       }
     }
   }
   ```

5. **Create volume configurations** for each required CIFS share:
   ```hcl
   id        = "blob-media"
   name      = "blob-media"
   type      = "csi"
   plugin_id = "smb"

   capability {
     access_mode = "multi-node-multi-writer"
     attachment_mode = "file-system"
   }

   secrets {
     username = "${BLOB_USERNAME}"
     password = "${BLOB_PASSWORD}"
   }

   parameters {
     source = "//blob.lan.offby1.net/Media"
   }

   mount_options {
     mount_flags = [
       "file_mode=0777",
       "dir_mode=0777",
       "addr=192.168.5.184"
     ]
   }
   ```

## Network Strategy

The current architecture uses Tailscale sidecar containers for networking. In Nomad, we'll:

1. Continue using Tailscale sidecars for external connectivity
2. Use Nomad's bridge network mode to enable communication between containers
3. Configure DNS for service discovery

## First Service Migration: Jackett

Below is the Nomad job specification for migrating the Jackett service:

```hcl
job "jackett" {
  datacenters = ["dc1"]
  type = "service"

  group "jackett-group" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        static = 9117
        to = 9117
      }
    }

    task "sidecar" {
      driver = "docker"
      
      config {
        image = "ghcr.io/offbyone/sidecar:main"
        volumes = [
          "sidecar-data:/var/lib/tailscale"
        ]
        devices = [
          {
            host_path = "/dev/net/tun"
            container_path = "/dev/net/tun"
          }
        ]
        cap_add = [
          "NET_ADMIN",
          "SYS_MODULE"
        ]
      }
      
      resources {
        cpu = 100
        memory = 128
      }

      env {
        TS_SERVE_PORT = "9117"
        TS_HOSTNAME = "jackett"
      }

      template {
        data = <<EOF
TS_AUTH_KEY = "{{with secret "secrets/data/tailscale"}}{{.Data.data.auth_key}}{{end}}"
EOF
        destination = "${NOMAD_SECRETS_DIR}/tailscale_env"
        env = true
      }
    }

    task "jackett" {
      driver = "docker"
      
      config {
        image = "lscr.io/linuxserver/jackett:latest"
        network_mode = "task:sidecar"
      }
      
      resources {
        cpu = 200
        memory = 256
      }

      env {
        PGID = "1000"
        PUID = "1000"
      }
      
      volume_mount {
        volume = "jackett-config"
        destination = "/config"
        read_only = false
      }
      
      volume_mount {
        volume = "blob-media"
        destination = "/media"
        read_only = false
      }
    }
    
    volume "jackett-config" {
      type = "host"
      source = "jackett-config"
      read_only = false
    }
    
    volume "blob-media" {
      type = "csi"
      source = "blob-media"
      read_only = false
    }
    
    volume "sidecar-data" {
      type = "host"
      source = "tailscale-jackett"
      read_only = false
    }
  }
}
```

## Service Template Pattern

For most services, we'll follow this template:

1. Group with bridge network mode
2. Sidecar task using Tailscale for external access
3. Main service task connected to the sidecar network
4. CSI volumes for shared storage
5. Host volumes for persistent configuration

## Migration Batches

1. **Simple services** (jackett, cobalt, etc.)
2. **Media services** (radarr, sonarr, lidarr, etc.)
3. **Monitoring services** (prometheus, metrics exporters)
4. **Complex services** with multiple containers

## Testing and Validation

For each service migration:
1. Deploy with Nomad
2. Verify service accessibility via Tailscale
3. Confirm functionality
4. Validate volume mounts and data persistence

## Rollback Plan

If issues occur:
1. Keep Docker Compose deployments running until migration is validated
2. Document any configuration changes made during migration
3. Have ability to revert to Docker Compose quickly