#!/bin/bash

if [ ! -f /var/lib/sickchill/config.ini ]; then
    echo "No config mounted for sickchill; mount a config directory in /var/lib/sickchill"
    exit 1
fi

supervisorctl start sickchill

# docker volume create --name blob-media \
# --driver local \
# --opt type=cifs \
# --opt device=//blob.lan.offby1.net/Media \
# --opt 'o=username=pi-torrent,password=PWD,file_mode=0777,dir_mode=0777,addr=192.168.1.10'
