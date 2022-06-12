# wr-nuc-01

Docker, Kubernetes, Powershell, SmartHome etc.

Unifi-U6-LR-WR: f39Ey!zg4k%$EW54Gsgo

## IPs
192.168.179.1:8443           # opnSense
http://192.168.179.2:9000    # Portainer admin
http://192.168.179.2:3000    # Grafana 
http://192.168.179.2:8085    # Heimdall 
https://192.168.179.2:8443   # Unifi  admin
http://192.168.179.2:8200    # duplicati 
http://192.168.179.2:8086    # influxdb  admin

192.168.179.3                # Unifi U6 LR
192.168.179.5                # Unifi USW-24
192.168.179.6                # Unifi USW-Flex-Mini
192.168.179.18               # Miner Olaf
192.168.179.19               # Miner Sebastian
http://192.168.179.80        # Shelly 

## Manjaro auf NUC WR-NUC01 

## Hardware
Intel-NUC D54250WYK
Processor: Core i5-4250U  4x1.3GHz
BIOS: WYLPT10H.86A.0054.2019.0902.1752
OS ist auf sdb  446,83GiB

Driver: https://www.intel.com/content/www/us/en/support/products/76977/intel-nuc/intel-nuc-kits/legacy-intel-nuc-kits/intel-nuc-kit-d54250wyk.html#support-recommended-articles

## Installation
pacmann -Syu

Datum/Zeit automatisch ermitteln
Einstellungen / Multitasking: Funktionale Ecke abschalten, Aktive Bildschirmkanten abschalten

git clone https://aur.archlinux.org/powershell-bin.git
cd powershell-bin
makepkg -si
cd ..
rm powershell-bin -r -f

## über Software hinzufügen
Thunderbird, Brave, Nextcloud Desktop Synchronisationsclien, VSCode (Code-OSS), Libreoffice Fresh, 
Keepass, VLC, Telegram, Remmina

## über Terminal hinzufügen
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub/flatpakrepo  #alle Pakete auflisten
flatpak search 
flatpak install flathub md.obsidian.Obsidian
flatpak run md.obsidian.Obsidian

## deepl AppImage
https://github.com/kumakichi/Deepl-linux-electron/releases
Ctrl+C to Clipboard, Ctrl+Alt+D übersetzen

sudo pacman -S openssh
sudo systemctl enable sshd
sudo systemctl start sshd
ssh-copy-id -i /mnt/c/Users/olaf/.ssh/id_rsa.pub olaf@192.168.178.200 #from Ubuntu WSL2

sudo pacman -S system-config-printer 
sudo pacman -S cups
sudo pacman -S ghostscript
systemctl enable --now cups.service
und dann Drucker installieren

sudo pacman -S docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

## Citrix Client  : Citrix Workspace app
https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html
https://omvs.de/2019/05/21/citrix-receiver-in-manjaro-linux-installieren/

## .deb Pakete installieren 
1. git clone https://github.com/helixarch/debtap
2. sudo debtap -u
3. bash debtap example.deb
4. sudo pacman -U example.pkg.tar.zst

## VSCode
cp ./wr-nuc01/.gitconfig ~/.gitconfig
Install Extension: Powershell, Docker, XML, Material Icon Theme
settings.json und powershell.json kopieren


## Unterverteilung
- 01: 
- 02: 
- 03: Steeckdose hinten links Fenster (Miner)
- 04: Licht Decke
- 05: Steckdose Büro sturz Mitte
- 06: 
- 07: Steckdose Büro hinten Mitte links
- 08: Steckdose Büro hinten Mitte links
- 09: Steckdose Büro vorn links
- 10: Lampe Wand links
- 11: Steckdose Büro rechts vorn neben Tür
- 12: Steckdose Büro rechts hinten Mitte
- 13:
- 14: steckdose Büro Eingang Küche
- 15:
- 16: Lampe Bad + Steckdose Tür
- 17: 
- 18: Bad Lüfter + Steckdose Waschtisch
- 19: Steckdose Badheizkörper
- 20: 
- 21:
- 22: Licht büro Wand

