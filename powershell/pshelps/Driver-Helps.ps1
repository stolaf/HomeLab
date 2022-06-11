#http://www.systemcentercentral.com/win-2012-r2-nic-drivers-for-asus-p8z68-v-intel-82579-gig-card/
#http://www.telnetport25.com/2012/12/installing-windows-hyper-v-server-2012-with-an-asus-p8z68-v-pro-motherboard/
#http://www.ivobeerens.nl/2012/08/08/enable-the-intel-82579v-nic-in-windows-server-2012/
#http://foxdeploy.com/2013/09/12/hacking-an-intel-network-card-to-work-on-server-2012-r2/
#Then the Network Driver Interface Specification (NDIS) that matches our OS, for reference:
#NDIS 6.0;Vista;Server 2008
#NDIS 2.1;Vista SP1;Server2008R2
#NDIS 6.2;Windows7;Server2012
#NDIS 6.3;Windows8;Server2012R2

Get-ChildItem -recurse -Filter '*.inf'| Select-String -pattern 'VEN_8086&Dev_1503' | Group-Object path | Select-Object name
bcdedit.exe /set LOADOPTIONS DISABLE_INTEGRITY_CHECKS 
bcdedit.exe /set TESTSIGNING ON 
bcdedit.exe /set nointegritychecks ON
#Reboot
pnputil.exe –i –a h:\<path>\e1c63x64.inf
#Reboot
bcdedit.exe /set LOADOPTIONS ENABLE_INTEGRITY_CHECKS 
bcdedit.exe /set TESTSIGNING OFF 
bcdedit.exe /set nointegritychecks OFF


Get-WmiObject Win32_PnPSignedDriver | Select-Object devicename, driverversion | Where-Object {$_.devicename -like '*nvidia*'}
Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.devicename -like '*Hyper-V*'} | Select-Object devicename, driverversion

driverquery.exe /v /fo csv | ConvertFrom-CSV | Select-Object 'Display Name', 'Start Mode', 'Paged Pool(bytes)’, Path
driverquery.exe /v /si /fo csv | ConvertFrom-CSV | Where-Object 'Display Name' -like '*hyper*' | Select-Object *

Get-WindowsDriver -Online
Get-WmiObject Win32_PNPEntity

#Devices with missing drivers
Get-WmiObject Win32_PNPEntity | Where-Object{$_.Availability -eq 11 -or $_.Availability -eq 12}

Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Auto'