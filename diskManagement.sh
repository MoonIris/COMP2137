#!/bin/bash

#Shows local disk files and mount points
echo -n 'Local Disk: ' ; lsblk

#Shows mounted network filesystem and mount points
echo -n 'Mounted Network Filesystem: ' ; df -hT

#Shows avaliable home free space
echo -n 'Home Free Space: ' ; df -h /home

#Shows how much space has been used in home
echo -n 'Home Free Space Used: ' ; sudo du -sh /home
