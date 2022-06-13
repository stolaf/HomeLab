# Raspi-01 Unterverteilung

[Raspi in 19Zoll Schrank](https://indibit.de/raspberry-pi-einbau-im-19-rack-serverschrank/)


## Raspi Images
siehe ct 11/2021 S.132ff und http://ct.de/y6mw
choco install rpi-imager
Raspberry Pi Imager starten, OS auswählen, 
Image anpassen mit Strg+Umschalt+X  Overscan deaktivieren, WiFi: DE Tastaturlayout: de, Einrichtungsassistent deaktivieren (piwiz)
modifiziert die Datei /boot/firstrun.sh

## RASPI Grundinstallation
[Raspbian Download from](https://www.raspberrypi.org/downloads/raspberry-pi-os/)

- Flash Rasperry OS mit Balena Etcher
- Edit cmdline.txt : Change quiet to Full
- Add File on Root: ssh
- login pi | raspberry   # Achtung: zunächst engl. Tastatur
- File wpa_supplicant.conf im Root anlegen für WiFi Zugriff

``` bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=DE

network={
 ssid="UNIFI-AP-PRO"
 psk="M..."
}
```

``` bash
sudo apt update && sudo apt full-upgrade -y
sudo rpi-update -y  # Firmware Chip Update
passwd   #Password für den User PI ändern
sudo apt install rpi-eeprom git xrdp inxi python3 python3-pip curl htop nfs-common -y
sudo rpi-eeprom-update -d -a
sudo nano /etc/dhcpcd.conf
    interface eth0
    static ip_address=192.168.178.2/24
    static ip6_address=fd51:42f8:caae:d92e::ff/64
    static routers=192.168.178.1
    static domain_name_servers=192.168.178.1 8.8.8.8 fd51:42f8:caae:d92e::1
sudo nano /etc/hostname
    wr-raspi-01 
sudo nano /etc/hosts
    wr-raspi-01
sudo reboot now
ssh-copy-id -i /mnt/c/Users/olaf/.ssh/id_rsa.pub pi@192.168.178.2  # from WSL2 Ubuntu

sudo nano /etc/lightdm/lightdm.conf
    #autologin-user=pi  
```

## Raspi 4 USB Boot
``` bash
sudo raspi-config
    Advanced Options/Boot Options / Boot ROM Version --> Select Latest
    Reset boot ROM to Defaultes: NO
    Boot Order: USB Boot
    Interfacing Options: Enable Camera, SSH,I2C, Remote GPIO
sudo nano /etc/default/rpi-eeprom-update
    FIRMWARE_RELEASE_STATUS="stable"
ls /lib/firmware/raspberrypi/bootloader/stable
sudo rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-12-11.bin
sudo reboot now
vcgencmd bootloader_version
vcgencmd bootloader_config    #BOOT_ORDER 4:zuerst SSD (auch USB Stick)  dann 1: SD-Card  suchen
   - 0x0 - NONE (stop with error pattern)
   - 0x1 - SD CARD
   - 0x2 - NETWORK
   - 0x3 - USB device boot Compute Module only.
   - 0x4 - USB mass storage boot
   - 0xf - RESTART (loop) - start again with the first boot order field.
Raspi GUI/Zubehör/SD Card Copier aufrufen: Kopiert die Daten auf den USB SSD Speicher
lsblk
```

## Raspi 3 USB Boot
``` bash
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
# SD Card Copier
sudo reboot now
```

## Powershell 7 Core
[[software/pwsh/Installation]]

## Docker
curl -fsSL https://get.docker.com -o get-docker.sh  
sudo sh get-docker.sh  
sudo usermod -aG docker $USER  

sudo apt-get install libffi-dev libssl-dev -y  
sudo apt install python3-dev -y  
sudo apt-get install python3 python3-pip -y  
sudo pip3 install docker-compose  
sudo pip3 install bluepy

sudo pip3 uninstall docker-compose  
sudo apt remove --purge docker*  
sudo rm -rf /var/lib/docker  
sudo apt autoremove  


## NFS
``` bash
sudo apt install nfs-common -y  
mkdir /media/backup
mkdir /media/docker

sudo mount 192.168.178.25:/export/backup /media/backup
sudo mount 192.168.178.25:/export/data/docker /media/docker
sudo mount 192.168.178.25:/export/data/videos /media/videos
sudo nano /etc/fstab  
    192.168.178.25:/export/backup /media/backup nfs rw 0 0  
    192.168.178.25:/export/data/docker /media/docker nfs rw 0
    # 192.168.178.7:/export/backup /home/nfs/backup nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
sudo mount -a  #fstab neu einlesen
ls /media/docker
```

## RPIEasy
<https://github.com/enesbcs/rpieasy>  
Installation kann auch über IOTstack erfolgen (native Installs)
``` bash
sudo apt install python3-pip screen alsa-utils wireless-tools wpasupplicant zip unzip git
git clone https://github.com/enesbcs/rpieasy.git
cd rpieasy
sudo pip3 install jsonpickle

sudo ~/rpieasy/RPIEasy.py
```

## Backup
sudo rsync -avz --recursive --progress ~/IOTstack/volumes /media/backup/raspi-01
sudo rsync -avz --recursive --progress ~/homelab/volumes /media/backup/docker-01

## Restore
sudo rsync -avz --recursive --progress /media/backup/raspi-01 ~/IOTstack/volumes 
cp /media/backup/raspi-01/volumes/heimdall/config/www/app.sqlite /home/pi/IOTstack/volumes/heimdall/config/www/app.sqlite
cp /media/backup/raspi-01/volumes/pihole/etc-pihole/pihole-FTL.db /home/pi/IOTstack/volumes/pihole/etc-pihole