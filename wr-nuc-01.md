# Manjaro auf NUC WR-NUC01 

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

# deepl AppImage
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

