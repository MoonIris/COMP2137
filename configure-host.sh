#!/bin/bash


#Traps the signals TERM HUP INT
trap '' TERM HUP INT


#Verbose set to false. Asks user if they want verbose mode. If yes then enable it. Then tells the user if its enabled or not
verbose=false

read -p "Would you like to use verbose mode? (y/n): " VERBOSE_RESPONSE

if [[ "$VERBOSE_RESPONSE" = "Yes" || "$VERBOSE_RESPONSE" = "yes" || "$VERBOSE_RESPONSE" = "Y" || "$VERBOSE_RESPONSE" = "y" ]]; then
	verbose=true

elif [[ "$VERBOSE_RESPONSE" = "No" || "$VERBOSE_RESPONSE" = "no" || "$VERBOSE_RESPONSE" = "N" || "$VERBOSE_RESPONSE" = "n" ]]; then
        verbose=false

else
	echo "Invalid input"

if [ "$verbose" == true ]; then 
	echo "Verbose mode enabled"
else
	echo "Verbose mode not enabled"
fi


#This is the name desired name part of script

#Store Hostname variable
CURRENT_HOSTNAME=$(hostname)

#Use read to get command line desired name stroed as DESIRED_NAME
read -p "Please enter in desired name: " DESIRED_NAME


#If statement to change the current hostname to the desired if needed to. With if statements for if running in verbose mode
if [ "$DESIRED_NAME" != "$CURRENT_HOSTNAME"]; then

	if [ "$verbose" == true ]; then
		echo "Updating hostname from $CURRENT_HOSTNAME to $DESIRED_NAME"
	fi

#Updates the current hostname to desired in /etc/hostname. Exiting if error occurs
	sudo sed -i "s/^$CURRENT_NAME/$DESIRED_NAME/g" /etc/hosts
	if [ $? -ne 0 ]; then
        	echo "Error trying to update /etc/hostname" >&2
		exit 1
	fi

	if [ "$verbose" == true ]; then
		echo "/etc/hostname name updated to $DESIRED_NAME"
	fi

#Using sed to change the current hostname to the desired in /etc/hosts. Exiting if error occurs
	sudo sed -i "s/$CURRENT_HOSTNAME/$DESIRED_NAME/g" /etc/hosts
	if [ $? -ne 0 ]; then
                echo "Error trying to update /etc/hosts" >&2
                exit 1
        fi

	if [ "$verbose" == true ]; then
		echo "/etc/hosts name updated to $DESIRED_NAME"
	fi

#Sets the server hostname to desired name
	sudo hostnamectl set-hostname "$DESIRED_NAME"
	if [ $? -ne 0 ]; then
                echo "Error trying to update server hostname" >&2
                exit 1
        fi

	if [ "$verbose" == true ]; then
		echo "Hostname updated to $DESIRED_NAME"
	fi

logger "$CURRENT_HOSTNAME changed to $DESIRED_HOSTNAME in /etc/host /etc/hostname and server hostname changed to $DESIRED_NAME"

else
	if [ "$verbose" == true ]; then 
		echo "$CURRENT_HOSTNAME is already $DESIRED_NAME no change needed"
fi

#This is the ip desired ip address part of the script

#Grab the current laninterface ip address
CURRENT_IP=$(ip addr show | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | cut -d '/' -f1 | head -n 1)

#asks the user for their desired ip address
read -p "Please enter in your desired ip address" DESIRED_IP

if [ "$DESIRED_IP" != "$CURRENT_IP"]; then

        if [ "$verbose" == true ]; then
                echo "Updating IP address from $CURRENT_IP to DESIRED_IP"
        fi


#Updates the current ip address to the desired ip in /etc/hosts using sed to replace the old ip with the name one

	sudo sed -i "s/^$CURRENT_IP/$DESIRED_IP/g" /etc/hosts
	if [ $? -ne 0 ]; then
                echo "Error trying to update /etc/hosts" >&2
                exit 1
        fi

        if [ "$verbose" == true ]; then
                echo "/etc/host ip address updated to $DESIRED_IP"
        fi

#Updates the current ip address to the desired ip address in the netplan file
#Also applies the netplan to the running machine

	sudo sed -i "s/^$CURRENT_IP/DESIRED_IP/g" /etc/netplan/*.yaml
	sudo netplan apply
        if [ $? -ne 0 ]; then
                echo "Error trying to update /etc/netplan" >&2
                exit 1
        fi

        if [ "$verbose" == true ]; then
                echo "/etc/netplan ip address updated to $DESIRED_IP"
        fi

logger "$CURRENT_IP changed to $DESIRED_IP in etc/host and etc/netplan. Also applied ip to running machine"

else
        if [ "$verbose" == true ]; then
                echo "$CURRENT_IP is already $DESIRED_IP no change needed"
fi

#This is the hostentry part of the script to confirm if the desired name and ip address are in /etc/hosts


if [ "$verbose" == true ]; then
	echo "Checking if $DESIRED_NAME and DESIRED_IP are in /etc/hosts"

if [ grep -q "$DESIRED_IP" /etc/hosts && grep -q "DESIRED_NAME" /etc/hosts ]; then
	if [ "$verbose" == true ]; then
        	echo "$DESIRED_NAME and DESIRED_IP are in /etc/hosts"
else
	if [ "$verbose" == true ]; then
                echo "$DESIRED_NAME and/or DESIRED_IP are not in /etc/hosts Fixing, please stand by"

	sudo sed -i "s/CURRENT_IP/DESIRED_IP/g" /etc/hosts
	if [ $? -ne 0 ]; then
                echo "Error trying to update ip in /etc/hosts" >&2
                exit 1
        fi

        if [ "$verbose" == true ]; then
                echo "/etc/hosts ip address updated to $DESIRED_IP"
        fi

	sudo sed -i "s/CURRENT_NAME/DESIRED_NAME/g" /etc/hosts
	if [ $? -ne 0 ]; then
                echo "Error trying to update name in /etc/hosts" >&2
                exit 1
        fi

        if [ "$verbose" == true ]; then
                echo "/etc/hosts name updated to $DESIRED_NAME"
        fi

	logger "Updated ip and/or name to $DESIRED_IP and $DESIRED_NAME in /etc/hosts"

fi
