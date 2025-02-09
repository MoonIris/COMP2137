#!/bin/bash

#Displays Hostname
echo -n 'Hostname: ' ; sudo hostname

#Displays IP address as well as enps33 address and IPV6
echo -n 'IP Address: ' ; ip addr show | grep 'inet' | sed 's|/.*||'

#Displays Gateway IP
echo -n 'Gateway IP: ' ; ip route show default 
