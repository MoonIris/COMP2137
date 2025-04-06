#!/bin/bash
# This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file
﻿
#Verbose variable and asking if they want verbose mode 

verbose=false

read -p "Would you like to use verbose mode? (y/n): " VERBOSE_RESPONSE

if [[ "$VERBOSE_RESPONSE" = "Yes" || "$VERBOSE_RESPONSE" = "yes" || "$VERBOSE_RESPONSE" = "Y" || "$VERBOSE_RESPONSE" = "y" ]]; then
        verbose=true
elif [[ "$VERBOSE_RESPONSE" = "No" || "$VERBOSE_RESPONSE" = "no" || "$VERBOSE_RESPONSE" = "N" || "$VERBOSE_RESPONSE" = "n" ]]; then
	verbose=false
else
	echo "Invalid input"
fi

#confirming their decision

if [ "$verbose" == true ]; then
        echo "Verbose mode enabled"
else
        echo "Verbose mode not enabled"
fi


#This is to transfer configure-hosts to server1
if [ "$verbose" == true ]; then
	echo "Transfering configure-host.sh to server1-mgmt"
	scp configure-host.sh remoteadmin@server1-mgmt:/root
else
	scp configure-host.sh remoteadmin@server1-mgmt:/root
fi

#error checking
if [ $? -ne 0 ]; then
    echo "Error: Failed to transfer configure-host.sh to server1-mgmt"
    exit 1
fi


#This runs configure-hosts.sh on server1
if [ "$verbose" == true  ]; then
	echo "Running configure-hosts.sh on server1-mgmt"
	ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4
else
	ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4
fi

#error checking
if [ $? -ne 0 ]; then
    echo "Error: Failed to transfer configure-host.sh to server1-mgmt"
    exit 1
fi

#This is to transfer configure-hosts to server2
if [ "$verbose" == true ]; then
        echo "Transfering configure-host.sh to server2-mgmt"
        scp configure-host.sh remoteadmin@server2-mgmt:/root
else
        scp configure-host.sh remoteadmin@server2-mgmt:/root
fi

#error checking
if [ $? -ne 0 ]; then
    echo "Error: Failed to transfer configure-host.sh to server2-mgmt"
    exit 1
fi

#This runs configure-hosts.sh on server2

if [ "$verbose" == true  ]; then
	echo "Running configure-hosts.sh on server2-mgmt"
	ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3
else
	ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3
fi

#Stores the loghost on the desktop linux vm
if [ "$verbose" == true  ]; then
	echo "Updating /etc/hosts with loghost entry"
	./configure-host.sh -hostentry loghost 192.168.16.3
else
	./configure-host.sh -hostentry loghost 192.168.16.3
fi

#error checking
if [ $? -ne 0 ]; then
    echo "Error: Failed to update loghost entry on desktop linux vm"
    exit 1
fi

#Stores the webhost on the desktop linux vm
if [ "$verbose" == true  ]; then
        echo "Updating /etc/hosts with webhost entry"
	./configure-host.sh -hostentry webhost 192.168.16.4
else
	./configure-host.sh -hostentry webhost 192.168.16.4
fi

#error checking
if [ $? -ne 0 ]; then
    echo "Error: Failed to update webhost entry on desktop linux vm"
    exit 1
fi

