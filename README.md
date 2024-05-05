# Mullvad-VPN-OpenRC
A script to install Mullvad VPN on OpenRC & sysvinit systems (particularly Devuan) via Wireguard.

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
### Post-Install Configuration
You are prompted for a server location during install. The default server location is ```gb-lon-wg-001``` (London, England). If you want to change the server you are connecting to post-installation, you will need to edit the ```command_args``` variable in /etc/init.d/wireguard.

### Privacy
No account numbers or other information are collected by me; mullvad-wg.sh is fetched directly from Mullvad's repositories for authentication. If you would like to verify the authenticity of mullvad-wg.sh, which is fetched and executed during this script's installation of Mullvad VPN, you can do so by executing:
```
curl -o mullvad-wg.sh.asc https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh.asc
curl -o mullvad-code-signing.asc https://mullvad.net/media/mullvad-code-signing.asc
gpg --import mullvad-code-signing.asc
gpg --verify mullvad-wg.sh.asc
```
