# Nomad Storage Setup for Three-Node Cluster

This guide provides specific steps to configure shared storage from the `blob` server for your Nomad cluster.

## Prerequisites

- Nomad cluster with three nodes: `blob`, `prime`, and `bitbucket`
- SMB/CIFS shares hosted on the `blob` server
- Network connectivity between all nodes

## Server-Specific Setup

### 1. Blob Server (Storage Provider)

The `blob` server already has `allow_privileged = true` in its Docker plugin configuration, which is good.

1. **Configure shared mounts for btrfs subvolumes:**
   ```bash
   # Make the root volume shared
   mount --make-shared /volume1

   # Make each subvolume shared
   mount --make-shared /volume1/@appdata/ContainerManager/all_shares/Media
   mount --make-shared /volume1/@appdata/ContainerManager/all_shares/config
   mount --make-shared /volume1/@appdata/ContainerManager/all_shares/Backups
   ```

2. **Make shared mounts persistent** by creating a startup script:
   ```bash
   # Create a startup script
   cat > /usr/local/etc/rc.d/S99shared_mounts.sh << 'EOF'
   #!/bin/sh
   mount --make-shared /volume1
   mount --make-shared /volume1/@appdata/ContainerManager/all_shares/Media
   mount --make-shared /volume1/@appdata/ContainerManager/all_shares/config
   mount --make-shared /volume1/@appdata/ContainerManager/all_shares/Backups
   EOF
   
   # Make it executable
   chmod +x /usr/local/etc/rc.d/S99shared_mounts.sh
   ```

3. **Create local directories for host volumes:**
   ```bash
   mkdir -p /opt/nomad/volumes
   ```

4. **Deploy the modified CSI controller plugin:**
   This should run on the blob server since it's hosting the shares.
   ```bash
   nomad job run csi-smb-controller.nomad
   ```

5. **Deploy the SMB CSI node plugin:**
   ```bash
   nomad job run csi-smb-node.nomad
   ```

6. **Create a volume registry directory:**
   ```bash
   mkdir -p /opt/nomad/volumes/registry
   chmod 700 /opt/nomad/volumes/registry
   ```

### 2. Prime Server (Nomad Server & Client)

1. **Update Nomad configuration** to allow privileged containers:
   ```bash
   # Edit /etc/nomad.d/nomad.hcl to add:
   plugin "docker" {
     config {
       allow_privileged = true
       volumes {
         enabled = true
       }
     }
   }
   ```

2. **Install required packages:**
   ```bash
   apt-get update && apt-get install -y cifs-utils
   ```

3. **Create local directories for host volumes:**
   ```bash
   mkdir -p /opt/nomad/volumes
   ```

4. **Deploy the SMB CSI node plugin:**
   ```bash
   nomad job run csi-smb-node.nomad
   ```

5. **Create a volume registry directory:**
   ```bash
   mkdir -p /opt/nomad/volumes/registry
   chmod 700 /opt/nomad/volumes/registry
   ```

### 3. Bitbucket Server (Nomad Client)

1. **Update Nomad configuration** to allow privileged containers:
   ```bash
   # Edit /etc/nomad.d/nomad.hcl to add:
   plugin "docker" {
     config {
       allow_privileged = true
       volumes {
         enabled = true
       }
     }
   }
   ```

2. **Install required packages:**
   ```bash
   apt-get update && apt-get install -y cifs-utils
   ```

3. **Create local directories for host volumes:**
   ```bash
   mkdir -p /opt/nomad/volumes
   ```

4. **Deploy the SMB CSI node plugin:**
   ```bash
   nomad job run csi-smb-node.nomad
   ```

5. **Create a volume registry directory:**
   ```bash
   mkdir -p /opt/nomad/volumes/registry
   chmod 700 /opt/nomad/volumes/registry
   ```

## Create the CSI Plugin Definitions

1. **Modified SMB CSI Controller Job** (save as `csi-smb-controller.nomad`):
   ```hcl
   job "csi-smb-controller" {
     datacenters = ["dc1"]
     
     # Force it to run on blob
     constraint {
       attribute = "${attr.unique.hostname}"
       value     = "blob"
     }
     
     group "controller" {
       count = 1
       
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
           
           # Mount host volumes directly
           volumes = [
             "/volume1/@appdata/ContainerManager/all_shares/Media:/host/Media",
             "/volume1/@appdata/ContainerManager/all_shares/config:/host/config",
             "/volume1/@appdata/ContainerManager/all_shares/Backups:/host/Backups"
           ]
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

2. **SMB CSI Node Job** (save as `csi-smb-node.nomad`):
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

## Create Volume Definitions

There are two approaches to handle volumes depending on where the job will run:

### Option 1: Direct Host Volumes (for jobs running on blob)

```hcl
# For Media volume on blob (save as blob-media-host-volume.hcl)
id        = "blob-media"
name      = "blob-media"
type      = "host"

capability {
  access_mode = "multi-node-reader-only"
  attachment_mode = "file-system"
}

mount_options {
  fs_type = "none"
  mount_flags = ["bind"]
}

host_path = "/volume1/@appdata/ContainerManager/all_shares/Media"
```

### Option 2: SMB CSI Volumes (for jobs on prime and bitbucket)

1. **Media Volume** (save as `blob-media-csi-volume.hcl`):
   ```hcl
   id        = "blob-media-csi"
   name      = "blob-media-csi"
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

2. **Jackett Config Volume** (save as `jackett-config-volume.hcl`):
   ```hcl
   id        = "jackett-config"
   name      = "jackett-config"
   type      = "host"
   
   capability {
     access_mode = "single-node-writer"
     attachment_mode = "file-system"
   }
   
   mount_options {
     fs_type = "none"
     mount_flags = ["bind"]
   }
   
   host_path = "/opt/nomad/volumes/jackett-config"
   ```

## Register the Volumes

Register the appropriate volumes depending on where your jobs will run:

```bash
# For jobs on blob (using direct host volumes)
nomad volume create blob-media-host-volume.hcl

# OR for jobs on prime/bitbucket (using CSI volumes)
export BLOB_USERNAME=your_username
export BLOB_PASSWORD=your_password
nomad volume create blob-media-csi-volume.hcl

# For local config storage on any node
nomad volume create jackett-config-volume.hcl
```

## Prepare Host Directories

On each node where you want to run the Jackett service, create the host volume directory:

```bash
mkdir -p /opt/nomad/volumes/jackett-config
chmod 777 /opt/nomad/volumes/jackett-config
```

If you need to migrate existing Jackett configuration, copy it to this directory on the node where you plan to schedule the job.

## Test the Setup

Verify that the CSI plugins are running:

```bash
nomad plugin status
```

Check that the volumes are registered and available:

```bash
nomad volume status
```

Deploy the Jackett service using the job specification from your migration plan, with a constraint to target the appropriate node:

```hcl
# To run on blob directly using host volumes
constraint {
  attribute = "${attr.unique.hostname}"
  value     = "blob"
}

# Use the host volume block
volume "blob-media" {
  type = "host"
  source = "blob-media"
  read_only = false
}
```

OR

```hcl
# To run on prime/bitbucket using CSI volumes
constraint {
  attribute = "${attr.unique.hostname}"
  operator  = "!="
  value     = "blob"
}

# Use the CSI volume block
volume "blob-media" {
  type = "csi"
  source = "blob-media-csi"
  read_only = false
}
```

## Troubleshooting

If you encounter issues with volume mounting:

1. **Check CSI plugin logs**:
   ```bash
   nomad alloc logs <allocation_id> plugin
   ```

2. **Verify volume status**:
   ```bash
   nomad volume status blob-media
   ```

3. **Check for client connectivity issues**:
   ```bash
   # On the client node:
   ping blob.lan.offby1.net
   # Test SMB connectivity:
   smbclient -U your_username //blob.lan.offby1.net/Media
   ```

4. **Review allocation status and logs**:
   ```bash
   nomad alloc status <allocation_id>
   nomad alloc logs <allocation_id> jackett
   nomad alloc logs <allocation_id> sidecar
   ```

5. **Check mount propagation**:
   If you continue to have mount propagation issues, try running these debug commands:
   ```bash
   # Check if mount is shared
   findmnt -o TARGET,PROPAGATION /volume1
   
   # If not shared, make it shared again
   mount --make-shared /volume1
   ```