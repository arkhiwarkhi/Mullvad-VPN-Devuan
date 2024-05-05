# Mullvad-VPN-OpenRC
A guide to run Mullvad VPN on OpenRC systems (particularly Devuan via Wireguard).

1. Install WireGuard and dependencies.
```
sudo apt-get update && sudo apt-get install curl jq openresolv wireguard
```
2. Download the Mullvad configuration script.
```
curl -o mullvad-wg.sh https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh
```
3. Run the Mullvad configuration script.
```
chmod +x ./mullvad-wg.sh && ./mullvad-wg.sh
```
4. Clone this repository and change directories.
```
git clone https://github.com/arkhiwarkhi/Mullvad-VPN-OpenRC && cd Mullvad-VPN-OpenRC
```
5. Refer to the ```servers``` file to determine which server you would like to use.
6. In the ```wireguard``` file, replace ```gb-lon-wg-001``` (in both command_args and in stop()) with the server you would like to use.
7. To implement a killswitch to prevent traffic leakage, edit the config file of the relevant server (in ```/etc/wireguard/```) by adding at the bottom of the [Interface] section:
```
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL ! -d 192.168.1.0/24 -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL ! -d 192.168.1.0/24 -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
```
(this enables compatibility with local network)

8. Move the ```wireguard``` file to /etc/init.d/
```
sudo mv wireguard /etc/init.d/
```
9. Update the service.
```
rc-update add wireguard default
```
10. Reboot or run (with no guarantees):
```
rc-service wireguard start
```
11. Verify connection:
```
curl https://am.i.mullvad.net/connected
```
12. Congrats! Enjoy your freedom, able to torrent as many free Linux ISOs as you'd like.
