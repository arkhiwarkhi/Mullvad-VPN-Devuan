#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run this script with elevated permissions"
	exit 1
fi

postup_content="PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL ! -d 192.168.1.0/24 -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
predown_content="PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL ! -d 192.168.1.0/24 -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark \$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT" 

echo "Installing Mullvad dependencies.."

apt-get update -y
apt_get_update_status=$?
if [ $apt_get_update_status -eq 0 ]; then
	#iptables, though replaced by nftables on devuan systems, is required for compatibility with mullvad
	apt-get install -y curl jq openresolv wireguard iptables
 	apt_get_install_status=$?
  	if [ $apt_get_install_status -eq 0 ]; then
		echo "Installed dependencies, fetching Mullvad auth script."
  		curl -o mullvad-wg.sh https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh
    		curl_status=$?
      		if [ $curl_status -eq 0 ]; then
			chmod +x mullvad-wg.sh
   			chmod_auth_status=$?
      			if [ $chmod_auth_status -eq 0 ]; then
				./mullvad-wg.sh
    				auth_status=$?
				if [ $auth_status -eq 0 ]; then
					echo "Successfully authenticated with Mullvad."
					read -p "Please enter what server you would like to use. Please make sure this is a valid entry: " server
     					sed -i "5s/.*/command_args=\"$server\"/" "wireguard"
	  				set_server_status=$?
       					if [ $set_server_status -eq 0 ]; then
						read -p "Would you like to implement a killswitch? (yes/no): " killswitch
      						if [ "$killswitch" = "yes" ]; then
	    						sed -i "7i\\$postup_content" "wireguard"
	   						postup_status=$?
	  						if [ $postup_status -eq 0 ]; then
								sed -i "8i\\$predown_content" "wireguard"
								predown_status=$?
								if [ $predown_status -eq 0 ]; then
									echo "Killswitch has been enabled."
								else
									echo "Could not set predown table, exiting."
	 								exit 1
								fi
      							else
								echo "Could not set postup table, exiting."
								exit 1
      							fi
	  					elif [ "$killswitch" = "no" ]; then
							echo "Continuing with no killswitch."
 						else
       							echo "Not an acceptable input, exiting."
	      						exit 1
 						fi
      						
	 				else
      						echo "Could not set server."
      					fi
 				else
					echo "Could not authenticate with Mullvad."
     				fi
			else
				echo "Could not make mullvad-wg.sh executable."
   			fi
  		else
			echo "Could not curl Mullvad's auth script."
    		fi
  		
    	else
     		echo "Could not install dependencies, exiting."
       		exit 1
     	fi
else
	echo "Could not update repositories, exiting."
 	exit 1
fi

mv wireguard /etc/init.d/
wireguard_service_status=$?
if [ $wireguard_service_status -eq 0 ]; then
	echo "Added configured wireguard service .. Enabling"
 	if [ -x /sbin/openrc ]; then
  		rc-update add wireguard default
    		rc_update_status=$?
      		if [ $rc_update_status -eq 0 ]; then
			rc-service wireguard start
   			rc_service_status=$?
      			if [ $rc_service_status -eq 0 ]; then
	 			echo "Successfully started wireguard service. Testing connection now."
     				echo "Testing connection..."
				curl https://am.i.mullvad.net/connected
     			else
				echo "Could not start wireguard service; try rebooting. You can then test connection by curling https://am.i.mullvad.net/connected"
   			fi
      		else
			echo "Could not add wireguard to default runlevel."
 		fi
else
	echo "Unable to implement wireguard service."
fi
