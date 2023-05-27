#!/bin/sh

# Remote port forwarding by ssh command in bash script environment 
/mnt/sdcard/ld-linux.so.3 --library-path /mnt/sdcard /mnt/sdcard/ssh -N -f -tt -R 23:127.0.0.1:23 -R 21:127.0.0.1:21 -i /mnt/mtd/id_rsa -o UserKnownHostsFile=/mnt/mtd/known_hosts -o StrictHostKeyChecking=no root@REMOTE_HOST_ADDRESS -p 22
