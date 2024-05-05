#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run this script with elevated permissions"
	exit 1
fi

echo "Installing Mullvad dependencies.."

apt-get update -y
#Mullvad does not state iptables is required, but is not installed on Devuan
apt-get install -y curl jq openresolv wireguard iptables

#Gets Mullvad's authentication script to permit connections
curl -o mullvad-wg.sh https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh

chmod +x mullvad-wg.sh

./mullvad-wg.sh

read -p "Please enter what server you would like to use: " server

sed -i "5s/.*/command_args=\"$server\"/" "wireguard"

read -p "Would you like to implement a killswitch? (yes/no): " killswitch

postup_content="PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL ! -d 192.168.1.0/24 -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
predown_content="PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL ! -d 192.168.1.0/24 -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT" 

if [ "$killswitch" = "yes" ]; then
	sed -i "7i\\$postup_content" "wireguard"
	sed -i "8i\\$predown_content" "wireguard"
	echo "Killswitch enabled."
else
	echo "Killswitch not enabled."
fi

if [ -x /sbin/openrc ]; then
	rc-update add wireguard default
	rc-service wireguard start
elif [ -x /sbin/init ]; then
	ln -s /etc/init.d/wireguard /etc/rc5.d/wireguard
	update-rc.d wireguard defaults
	echo "Reboot may be required!"
fi

echo "Testing connection..."
curl https://am.i.mullvad.net/connected
