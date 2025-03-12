#!/bin/bash
#Assignment2: System Modification script

#This is the desired target server configuration code

NETPLAN=$(grep -w "^addresses:" /etc/netplan/*.yaml | awk -F ': ' '{print $2}')
DESIRED_IP='192.168.16.21'
CURRENT_IP=$(grep -w "server1$" /etc/hosts | awk '{print $1}')
APACHE_CHECK="sudo apachectl configtest"
SQUID_FILE="/etc/squid/squid.conf"
SQUID_DEFAULT="/tmp/squid.conf"
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "perrier" "cindy" "tiger" "yoda")


echo "Checking server1 IP address in /etc/hosts"

sleep 2


if [[ "$NETPLAN" != "$DESIRED_IP" ]]; then
	echo "Current IP is different in netplan. Updating, Please stand by... "\
	echo "$NETPLAN"
fi

if [[ "$CURRENT_IP" != "$DESIRED_IP" ]]; then
	echo "Current IP is different then $DESIRED_IP. Updating, Please stand by..."
	sudo sed -i "s/^$CURRENT_IP server1/$DESIRED_IP server1/" /etc/hosts
	sleep 2
	echo "IP updated to $DESIRED_IP in /etc/hosts"
else
	echo "Desired target server configuration is already $DESIRED_IP"
fi

sleep 2

#This section is for installing apache2 and checking if it is running default

echo "Checking if apache2 is installed and running default"

sleep 2

if command -v apache2; then
	echo "apache2 is installed"
else
	echo "apache2 is not installed. Now installing apache2. Please wait..."
	sudo apt update && sudo apt install -y apache2 
	echo "apache2 is now installed"
	sudo systemclt enable apache2
	sudo systemclt start apache2
fi 

echo "Checking if apache2 is currently running default"

sleep 2

$APACHE_CHECK

if [ $? -eq 0 ]; then
	echo "Apache2 is running in default configuration"  
else
	echo "Apache2 is not running in default. Restoring to default, please stand by..."
	sudo apt-get install --reinstall -y apache2
	sudo systemctl restart apache2
fi

sleep 2

#This section is for installing squid web proxy and checking if its running default

echo "Checking if squid web proxy is installed"

sleep 2

if command -v squid; then
	echo "Squid web proxy is installed" 
else
	echo "Squid web proxy is not installed. Now installing squid web proxy, please stand by..."
	sleep 2
	sudo apt update && sudo apt install -y squid
	echo "Squid web server is now installed. Now enabling and starting proxy"
	sleep 2
	sudo systemctl enable squid
	sudo systemctl start squid
fi

sleep 2

echo "Checking if squid web proxy is running default configuration"

wget https://www.squid-cache.org/Versions/v6/6.13/squid.conf.default -O /tmp/squid.conf

if diff "$SQUID_FILE" "$SQUID_DEFAULT" > /dev/null; then
	echo "Squid web proxy is running default configuration"
else
	echo "Squid web proxy is not running default configuration. Restoring to default, please stand by... "
	sleep 2
	sudo apt-get install --reinstall -y squid
	sudo systemctl restart squid
	echo "Squid web proxy has been restored to default configuration"
fi

#This section is for the user accounts

sleep 2

echo "Checking user accounts..."

sleep 2

for user in ${USERS[@]}; do

	grep -q "^$user" /etc/passwd

	if [[ $? -ne 0  ]]; then
		echo "Adding user $user"
		echo "Please stand by..."
		sleep 2

		if [[ $user == "dennis" ]]; then
			sudo useradd -m -s /bin/bash  $user
			sudo usermod -aG sudo $user
			echo "User $user created as sudoer"
			sleep 2
			echo "Now generating ssh keys for rsa and ed25519"
			sudo -u "$user" ssh-keygen -t rsa -b 4096 -f "/home/$user/.ssh/id_rsa" -N ""
			sudo -u "$user" ssh-keygen -t ed25519 -f "/home/$user/.ssh/id_ed25519" -N ""
			echo "Keys successfully created. Can be found in /home/$user/.ssh"
			sleep 2
			echo "Creating authorized_keys file in .ssh and appending rsa and ed25519 public keys to it" 
			echo "Please stand by..."
			sleep 2
			sudo touch /home/$user/.ssh/authorized_keys
                        cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
                        cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys
                        echo "Keys successfully appended to authorized_keys"
			sleep 2
			echo "Appending special public ssh key to authorized_keys"
			echo "ssh-ed25519 AAAAC3NzaC1IZDI1NTE5AAAAIG4rT3vTt99Ox5kndHmgTrKBT8SKzhK4rhGkEVGICI student@generic-vm" >> /home/$user/.ssh/authorized_keys
			echo "Special key successfully appended to authorized_keys"
			sleep 2
		else
			sudo useradd -m -s /bin/bash $user
			echo "User $user created"
			sleep 2
			echo "Now generating ssh keys for rsa and ed25519"
			sudo -u "$user" ssh-keygen -t rsa -b 4096 -f "/home/$user/.ssh/id_rsa" -N ""
			sudo -u "$user" ssh-keygen -t ed25519 -f "/home/$user/.ssh/id_ed25519" -N ""
			echo "Keys successfully created. Can be found in /home/$user/.ssh"
			sleep 2
			echo "Creating authorized_keys file in .ssh and appending rsa and ed25519 public keys to it"
			echo "Please stand by..."
			sleep 2
			sudo touch /home/$user/.ssh/authorized_keys
			cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
			cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys
			echo "Keys successfully appended to authorized_keys"
		fi
	else
		echo "User $user already exist"
	fi
done

sleep 2

echo "System Modification Complete"
