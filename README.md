# Ops repo: Containers for torrent clients et al.

This set of compose collections are built to put my service containers on the tailnet without my needing to have an entire host for each one.

All of these require:

- a docker engine
- access to the CIFS file share on blob

## Which host?

Most of the containers are not running properly on 32-bit ARM, which my raspberry pi lab devices are still on. I need to upgrade those before I can put them back.

For now, a lot of these are running on the NUC (bitbucket) instead, but I'd like to move them back to torrents.

### SickChill

TV management. Connects to whatbox for transmission, and blob for media. Runs on torrent.

This one entails a custom image build, since I run on ARM and the source doesn't release one.

### Radarr

Movie management. Connects to whatbox for transmission, and blob for media. Runs on bitbucket.

The latest Radarr doesn't support the ARM userspace/kernel combo that my pi lab has.

### Jackett

Torrent site proxy. Runs on torrents.

### Lidarr

Music management. Connects to whatbox for transmission, and blob for media. Runs on bitbucket.

Same codebase as Radarr.
