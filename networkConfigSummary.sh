#!/bin/bash


#Shows Interface name and ip address associated with it
ip address show |  grep -E 'inet |mtu' | awk ' /inet/ {print $1, $2} /mtu/ {print $2,  $4, $5}' 

#Shows default gateway ip

echo -n 'Default Gateway: ' ; ip route show default | awk '{print $3}'
