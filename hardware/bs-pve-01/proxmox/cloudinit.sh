wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
# wget https://cloud-images.ubuntu.com/eoan/current/eoan-server-cloudimg-amd64.img  #nicht nehmen

#oder in VM
apt-get install cloud-init

# create a new VM auf Proxmox Host
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0 --cpulimit 2

# import the downloaded disk to local-lvm storage
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
qm importdisk 9000 bionic-server-cloudimg-amd64.img local-lvm

# finally attach the new disk to the VM as scsi drive
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm template 9000

qm clone 9000 129 --name testsrv-03

qm set 129 --sshkey ~/.ssh/id_rsa.pub
qm set 129 --ipconfig0 ip=192.168.178.29/24,gw=192.168.178.1
qm set 129 --nameserver=192.168.178.1
qm set 129 --ciuser olaf
qm start 129

ssh olaf@192.168.178.29
wget https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.sh
chmod 755 install-powershell.sh
sudo install-powershell.sh -preview

https://github.com/PowerShell/PowerShell/releases/tag/v7.0.0-rc.2
wget https://github.com/PowerShell/PowerShell/releases/download/v7.0.0-rc.2/powershell-preview_7.0.0-rc.2-1.ubuntu.18.04_amd64.deb
sudo dpkg -i powershell-preview_7.0.0-rc.2-1.ubuntu.18.04_amd64.deb
sudo apt-get install -f

#https://docs.microsoft.com/de-de/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-7

sudo nano /etc/ssh/sshd_config
* PubkeyAuthentication yes
* PasswordAuthentication yes
* Subsystem powershell /usr/bin/pwsh-preview -sshs -NoLogo -NoProfile
sudo service sshd restart

pwsh-preview
Install-Module Microsoft.PowerShell.GraphicalTools
