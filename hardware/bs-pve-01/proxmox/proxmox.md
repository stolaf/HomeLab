# Allgemeines zu Proxmox 

* [Proxmox Wiki] (https://pve.proxmox.com/wiki/Main_Page)
* [Proxmox Forum](https://forum.proxmox.com/forums/proxmox-ve-deutsch-german.20/)  
* [Proxmox Downloads](https://www.proxmox.com/de/downloads)
* [Proxmox Installation] (https://www.youtube.com/watch?v=DHpkD5N6HC0)
* [Spice Doku] (https://pve.proxmox.com/wiki/SPICE)
* [User Management] (https://pve.proxmox.com/wiki/User_Management)
* [KVM mit gutem Bild und Ton] (https://www.youtube.com/watch?v=wZCm0C7JbJc&t=1260s)
* [Virt Manager Download] (https://virt-manager.org/download/)
* [Windows 10 mit VirtIO und SSD Passthrough] (https://www.youtube.com/watch?v=XEZaLJLJaaA&list=PLTeOo_Khba2Nzc0qAh7SRTJxrY8FKvtIO&index=22)

## Installation

<https://www.biteno.com/tutorial/proxmox-pve/>

``` bash
mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
nano /etc/apt/sources.list.d/pve-enterprise.list  # stretch-enterprise auskommentieren
nano /etc/apt/sources.list.d/pve-no-subscription.list
  deb http://download.proxmox.com/debian/pve stretch pve-no-subscription

apt update && apt dist-upgrade
apt install sudo
adduser olaf
visudo
   olaf ALL=(ALL:ALL) ALL

pveum groupadd admin -comment "System Administrators"
pveum aclmod / -group admin -role Administrator
```

* Proxmox VM path  
* Backups /var/lib/vz/dump  
* ISOs /var/lib/vz/template/iso  
* Images /var/lib/vz/images  
* Templates /var/lib/vz/template/cache  

LVM: https://wiki.ubuntuusers.de/Logical_Volume_Manager/

<https://www.howtoforge.com/tutorial/how-to-configure-nfs-storage-in-proxmox-ve>  
<https://www.linuxhelp.com/how-to-add-nfs-storage-on-proxmox-ve>  

https://forum.proxmox.com/threads/vm-location.48417/  
https://pve.proxmox.com/wiki/Moving_disk_image_from_one_KVM_machine_to_another  
https://pve.proxmox.com/wiki/Storage  
https://pve.proxmox.com/wiki/Cloud-Init_Support  


you should never ever run 'apt-get upgrade' on a PVE systems

## alte Files löschen
Files löschen unter cd /var/cache/apt/archives
```
ncdu
df -h
du -hsx /*
du -hsx /var/*
du -hsx /usr/*

apt autoremove --dry-run    
apt autoremove -y
apt-get purge $( dpkg --list | grep -P -o "pve-kernel-\d\S+" | grep -v $(uname -r | grep -P -o ".+\d") )

dpkg --list | grep kernel | grep amd64 | grep pve

apt purge pve-kernel-5.3* -y
apt purge pve-kernel-5.4* -y
apt-get -y autoremove && apt-get -y autoclean
```

## LVM 
Logical Volume Manager
https://wiki.ubuntuusers.de/Logical_Volume_Manager/
vergrößern: lvextend -r -L +1G /dev/mapper/pve-root

## Konfigurations Optionen für VMs
* https://pve.proxmox.com/wiki/Manual:_qm.conf  
* nano /etc/pve/qemu-server/180.conf

## PCI Devices durchreichen

ICH9 Chipsatz für besseren Durchsatz PCI-E Passthrough  
* [PCI Pass Thrugh] (https://pve.proxmox.com/wiki/Pci_passthrough)

```bash
sudo nano -w /etc/default/grub
	GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"
sudo update-grub	
sudo nano /etc/modules
	vfio
	vfio_iommu_type1
	vfio_pci
	vfio_virqfd
reboot
dmesg | grep -e DMAR -e IOMMU   # vorletzte Zeile Intel VTD
lsmod | grep vfio
```

## Festplatten durchreichen

* [Anleitung] (https://www.youtube.com/watch?v=XEZaLJLJaaA&index=22&list=PLTeOo_Khba2Nzc0qAh7SRTJxrY8FKvtIO)  
* [Wiki] (https://pve.proxmox.com/wiki/Manual:_qm.conf)

```bash
ls -l /dev/disk/by-id
qm set 200 -virtio0 /dev/disk/by-id/ata-MKNSSDAT480GB_MK131126AS1176304
qm set 125 -virtio2 /dev/disk/by-id/ata-ST5000LM000-2AN170_WCJ13M7R
qm set 125 -virtio3 /dev/disk/by-id/ata-ST5000LM000-2AN170_WCJ16Y02
qm set 125 -virtio4 /dev/disk/by-id/ata-ST5000LM000-2AN170_WCJ18VG5
```

## Windows 11 Installation
https://kayomo.de/blog/windows-11-unter-proxmox-installieren/
allerdings als Machine: pc-i440fx
Spice Grafik:  https://pve.proxmox.com/wiki/SPICE
Download von Win_x64.msi  : https://virt-manager.org/download/ 
Download von UsbDK*_x64.msi : https://www.spice-space.org/download.html

## Windows 10 Best Practises
<https://pve.proxmox.com/wiki/Windows_10_guest_best_practices>  
<https://docs.fedoraproject.org/en-US/quick-docs/creating-window-virtual-machines-using-virtio-drivers/index.html>  

* [in virtual Machine Spice Guest Tools installieren] (https://spice-space.org/download.html)
* [Wiki Spice] (https://pve.proxmox.com/wiki/SPICE)
* [Windows binaries / spice-guest-tools] (https://www.spice-space.org/download.html)

## USB Drive
``` bash
mkdir /media/usb-drive
fdisk -l | grep 465
mount /dev/sda1 /media/usb-drive/
mount | grep sdd1  #Überprüfung
cd /media/usb-drive
```

## USB Device in VM durchreichen  
über die GUI, VM vorher ausgeschaltet!

## Dark Theme

<https://github.com/Weilbyte/PVEDiscordDark>

``` bash
apt install git -y
git clone https://github.com/Weilbyte/PVEDiscordDark
python3 ./PVEDiscordDark/PVEDiscordDark.py
```
