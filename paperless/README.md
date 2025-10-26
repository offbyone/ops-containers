# Folder Storage

This configuration depends on dropbox being up and running already; it uses the dropbox service on prime, which is manually configured for now.

``` ini
[Unit]
Description=Dropbox Headless Service
After=network.target

[Service]
ExecStart=/home/offby1/.dropbox-dist/dropboxd
Restart=on-failure
User=offby1
Group=offby1
Environment=HOME=/home/offby1

[Install]
WantedBy=multi-user.target
```

That requires selective sync of Dropbox/Documents/paperless and Dropbox/Documents/incoming
