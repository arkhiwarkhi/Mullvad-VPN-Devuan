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
### Privacy
No account numbers or other information are collected by me; Mullvad-wg.sh is fetched directly from Mullvad's repositories to receive your account number. If you would like to verify the authenticity of Mullvad-wg.sh, which is fetched and executed during this script's installation of Mullvad VPN, you can do so by executing:
```
curl -o mullvad-wg.sh.asc https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh.asc
curl -o mullvad-code-signing.asc https://mullvad.net/media/mullvad-code-signing.asc
gpg --import mullvad-code-signing.asc
gpg --verify mullvad-wg.sh.asc
```
