# Mullvad-VPN-OpenRC
A guide to run Mullvad VPN on OpenRC & sysvinit systems (particularly Devuan) via Wireguard.

1. Clone this repository & change to it's directory.
```
git clone https://github.com/arkhiwarkhi/Mullvad-VPN-Devuan/ && cd Mullvad-VPN-Devuan
```
2. Set the script to executable.
```
chmod +x install-mullvad.sh
```
3. Run the script with elevated privileges, answering prompts as necessary. The server list can be found in the 'servers' file.
```
doas ./install-mullvad.sh
```

