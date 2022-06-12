# bs-raspi-01 

Für Octoprint, Docker und co.

[Raspi in 19Zoll Schrank](https://indibit.de/raspberry-pi-einbau-im-19-rack-serverschrank/)

## RASPI Grundinstallation

[Raspbian Download from](https://www.raspberrypi.org/downloads/raspberry-pi-os/)

- Flash Rasperry OS mit Balena Etcher
- Edit cmdline.txt : Change quiet to Full
Am Ende mit einem Leerzeichen anhängen (c't 3/2021 S176):  ip=192.168.178.5::192.168.178.1:255.255.255.0:bs-raspi-01:eth0:off
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

Nachträglich wlan-Settings: sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

``` bash
sudo apt update && sudo apt full-upgrade -y
sudo rpi-update -y  # Firmware Chip Update
passwd   #Password für den User PI ändern
sudo apt install rpi-eeprom git xrdp inxi python3 python3-pip htop nfs-common -y
sudo rpi-eeprom-update -d -a
sudo nano /etc/dhcpcd.conf
    interface eth0
    static ip_address=192.168.178.2/24
    static ip6_address=fd51:42f8:caae:d92e::ff/64
    static routers=192.168.178.1
    static domain_name_servers=192.168.178.1 8.8.8.8 fd51:42f8:caae:d92e::1
sudo nano /etc/hostname
    bs-raspi-01 
sudo nano /etc/hosts
    bs-raspi-01
sudo reboot now
ssh-copy-id -i /mnt/c/Users/olaf/.ssh/id_rsa.pub pi@192.168.178.2  # from WSL2 Ubuntu

sudo nano /etc/lightdm/lightdm.conf

```

## Powershell
```
sudo apt update  && sudo apt install -y curl gnupg apt-transport-https
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
sudo apt update && sudo apt install -y powershell
pwsh
```

<https://github.com/PowerShell/PowerShell>  

<https://github.com/PowerShell/PowerShell/releases>  

``` bash
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/powershell-7.2.4-linux-arm32.tar.gz
mkdir ~/powershell
tar -xvf ./powershell-7.2.4-linux-arm32.tar.gz -C ~/powershell
sudo ln -s ~/powershell/pwsh /usr/bin/pwsh
sudo ln -s ~/powershell/pwsh /usr/local/bin/powershell

#falls man PS Remoting möchte
sudo nano /etc/ssh/sshd_config
    Subsystem powershell /usr/bin/pwsh -sshs -NoLogo -NoProfile
    PubkeyAuthentication yes
sudo service sshd restart
```

## Raspi 4 USB Boot

``` bash
sudo raspi-config
    Boot Options / Boot ROM Version --> Select Latest
    Reset boot ROM to Defaultes: NO
    Boot Order: USB Boot
    Interfacing Options: Enable Camera, SSH,I2C, Remote GPIO
sudo nano /etc/default/rpi-eeprom-update
    FIRMWARE_RELEASE_STATUS="stable"
ls /lib/firmware/raspberrypi/bootloader/stable
sudo rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-07-31.bin
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

## NFS
``` bash
sudo apt install nfs-common -y  
sudo mkdir /media/backup
sudo mkdir /media/docker

sudo mount 192.168.178.6:/export/backup /media/backup
sudo mount 192.168.178.25:/export/data/docker /media/docker
sudo nano /etc/fstab  
    192.168.178.25:/export/backup /media/backup nfs rw 0 0  
    192.168.178.25:/export/data/docker /media/docker nfs rw 0
    # 192.168.178.7:/export/backup /home/nfs/backup nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
sudo mount -a  #fstab neu einlesen
ls /media/docker
```

## Raspi als AccesPoint mit WLAN USB3 Stick Agedate (NAT)

Chip RTL8812BU
[Amazon Link](https://www.amazon.de/Adapter-Empf%C3%A4nger-1200Mbit-Dualband-Notebook/dp/B07RKVTYSC)

<https://developer-blog.net/raspberry-pi-als-wlan-access-point-einrichten/>

Internes Wlan deaktivieren

``` bash
sudo nano /boot/config.txt
  dtoverlay=pi3-disable-wifi

# sudo systemctl disable hciuart  # nicht deaktivieren sonst geht BT nicht mehr
sudo reboot
```

[siehe Driver Installation Github](https://github.com/cilynx/rtl88x2BU_WiFi_linux_v5.3.1_27678.20180430_COEX20180427-5959)  
besser clone und siehe readme.md  
<https://github.com/cilynx/rtl88x2bu>  

``` bash
# Update all packages per normal
sudo apt update
sudo apt upgrade

# Install prereqs
sudo apt install git bc build-essential dkms raspberrypi-kernel-headers -y

# Reboot just in case there were any kernel updates
sudo reboot now

# Pull down the driver source
git clone https://github.com/cilynx/rtl88x2BU_WiFi_linux_v5.3.1_27678.20180430_COEX20180427-5959.git  
cd rtl88x2BU_WiFi_linux_v5.3.1_27678.20180430_COEX20180427-5959/  

# Configure for RasPi
sed -i 's/I386_PC = y/I386_PC = n/' Makefile  
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile  

# DKMS as above
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)  
sudo rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}  
sudo dkms add -m rtl88x2bu -v ${VER}  
sudo dkms build -m rtl88x2bu -v ${VER} # Takes ~3-minutes on a 3B+  
sudo dkms install -m rtl88x2bu -v ${VER}  

# Plug in your adapter then confirm your new interface name
ip addr
```

Setting up a Raspberry Pi as an access point in a standalone network (NAT) - **Nur das!**  
<https://www.elektronik-kompendium.de/sites/raspberry-pi/2002171.htm>  
oder weniger gut:  
<https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md>  

## Backlight Power 7Zoll TouchScreen

``` bash
sudo chmod 777 /sys/class/backlight/rpi_backlight/bl_power
echo 1 > /sys/class/backlight/rpi_backlight/bl_power    #off
echo 0 > /sys/class/backlight/rpi_backlight/bl_power    #ON
```

## PI Autologon deaktivieren

``` bash
sudo nano /etc/lightdm/lightdm.conf
    #auto-login-user=pi
```

## PI ScreenSaver

``` bash
sudo apt install xscreensaver
# screensaver application under the Preferences 
```

## Shelly

ssh pi@192.168.178.180 curl http://192.168.4.9/relay/0/?turn=on # schnell ~ 1s
ssh pi@192.168.178.180 curl http://192.168.4.9/relay/0?turn=on&timer=10  #Will switch output ON for 10 sec.

ssh pi@192.168.178.180 pwsh -command {Invoke-RestMethod -Uri http://192.168.4.9/relay/0/?turn=off}  # langsam ~10s
invoke-command -HostName 192.168.178.180 -UserName pi -ScriptBlock {Invoke-RestMethod -Uri http://192.168.4.9/relay/0/?turn=on}  #PS Core langsam ~ 12s

route add 192.168.4.0 MASK 255.255.255.0 192.168.4.1 -p #auf Notebook bzw. Server Route zu raspi-01

## shellyswitch25-B9566E

Invoke-WebRequest -Uri  http://192.168.4.9/relay/0/?turn=on -UseBasicParsing
Invoke-WebRequest -Uri  http://192.168.4.9/relay/0/?turn=off -UseBasicParsing
(Invoke-WebRequest -Uri  http://192.168.4.9/status/meters/0 -UseBasicParsing).Content | ConvertFrom-Json
Invoke-WebRequest -Uri  http://192.168.4.9/relay/0/meters -UseBasicParsing
(Invoke-WebRequest -Uri http://192.168.4.9/settings -UseBasicParsing).Content | ConvertFrom-Json
(Invoke-WebRequest -Uri  http://192.168.4.9/status -UseBasicParsing).Content  | ConvertFrom-Json

## GPIO Pins schalten

<https://www.elektronik-kompendium.de/sites/raspberry-pi/2202121.htm>  

``` bash
sudo apt-get install pigpio
sudo systemctl start pigpiod
sudo systemctl enable pigpiod

pigs modes 17 w
pigs modes 18 w

pigs w 17 1   #ON
pigs w 17 0   #Off
```

``` python
import RPi.GPIO as GPIO

GPIO.setwarnings(False)

GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.OUT)
GPIO.setup(18, GPIO.OUT)

GPIO.output(17, GPIO.HIGH)
GPIO.output(18, GPIO.HIGH)
```


## Raspi meldet sich im WLAN ab
iw wlan0 set power_safe off
wlan-Settings: sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

Der lässt sich zum Beispiel in der Datei /etc/network/interfaces im Abschnitt für ein WLAN Interface (iface wlan0) hinter der Interface Option "post-up" einfügen.