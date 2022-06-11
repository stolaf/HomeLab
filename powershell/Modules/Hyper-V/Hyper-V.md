# Hyper-V
## Allgemeines
https://4sysops.com/archives/creating-and-configuring-a-virtual-machine-completely-with-powershell-using-azure-stack-hci-as-an-example/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+4sysops+%284sysops%29

## Snapshots
```Poweshell
#Remove Snapshot
Get-VM -Name 'FSDEBSYSI23010' | Get-VMSnapshot -SnapshotTpye Recovery | Remove-VMSnapshot
```
```Powershell
# Nested Virtualization auf dem Host für die VM aktivieren. VM muss off sein
Set-VMProcessor -VMName "Windows 10-Entwicklungsumgebung" -ExposeVirtualizationExtensions $true 
Set-VMNetworkAdapter -VMName "Windows 10-Entwicklungsumgebung" -MacAddressSpoofing On

get-vm | sort creationtime | Select Name,CreationTime
Set-VMFirmware -vm $vm -SecureBootTemplate MicrosoftUEFICertificateAuthority

#eine VM nach VMId suchen
Invoke-Command -ComputerName $IOPI_All_HyperVServerNames -ScriptBlock {Hyper-V\Get-VM | ? VMid -match 'F9102B8E-A2AD-42B6-83B1-2A0039D9156C'}

#alle VMs ohne DVD Drive
Invoke-Command -ComputerName @('FSDEBSNE0541.mgmt.fsadm.vwfs-ad','FSDEBSNE0542.mgmt.fsadm.vwfs-ad' ,'FSDEBSNE0543.mgmt.fsadm.vwfs-ad' ,'FSDEBSNE0544.mgmt.fsadm.vwfs-ad')  -ScriptBlock {
  Hyper-V\Get-VM | ? {($_ | Get-VMDvdDrive) -eq $null} 
}

#wenn sich eine VM im Hyper-Manager nicht löschen lässt (VM's laufen weiter)
Restart-Service vmms

#Reading Hyper-V Event logs
# https://blogs.technet.microsoft.com/virtualization/2018/01/23/looking-at-the-hyper-v-event-log-january-2018-edition/
Get-WinEvent -ListProvider *hyper-v*
Get-WinEvent -ProviderName Microsoft-Windows-Hyper-V-VMMS
Get-WinEvent -ProviderName Microsoft-Windows-VHDMP

Get-WinEvent -FilterHashTable @{LogName ='Microsoft-Windows-Hyper-V*'}  # All
Get-WinEvent -FilterHashTable @{LogName ='Microsoft-Windows-Hyper-V*'; StartTime = (Get-Date).AddDays(-1); Level = 2}  # Errors
Get-WinEvent -FilterHashTable @{LogName ='Microsoft-Windows-Hyper-V*'; StartTime = (Get-Date).AddDays(-1); Level = 3}  # Warnings

#Find correlation between vmwp process and VM in Hyper-V 2012
Get-WmiObject Win32_Process -Filter "Name like '%vmwp%'" | Select-Object ProcessId, @{Label='VMName';Expression = {(Get-SCVirtualMachine -Id $_.Commandline.split(' ')[1] | Select-Object VMName).VMName}} | Format-Table -AutoSize

#Disable VMQueue
foreach ($NetworkAdapter in ($VM | Get-VMNetworkAdapter)) {$NetworkAdapter | Set-VMNetworkAdapter -VmqWeight 0}

#Resize VHD
Get-SCVirtualMachine 'FSDEBSYDE50016' | Get-VMHardDiskDrive -ControllerType SCSI | Resize-VHD -SizeBytes 200GB

#Integration Service
Get-VMIntegrationService -VMName * | Where-Object {$_.SecondaryOperationalStatus -eq 'ProtocolMismatch'} | Sort-Object Name  | Select-Object VMName,Name,SecondaryStatusDescription

#Updating ICVersion
$ISVersion = '6.2.9200.16433'
Get-SCVirtualMachine | Where-Object State -eq 'Running' | Select-Object Name,State,Integrationservicesversion |  Format-Table -AutoSize
Get-SCVirtualMachine | Where-Object State -eq 'Running' |  Where-Object  IntegrationServicesVersion -ne $ISVersion | Get-VMDvdDrive | Set-VMDvdDrive -Path C:\Windows\system32\vmguest.iso

#Move a running virtual machine
Move-SCVirtualMachine 'cs-mcs' rz-host1.pc-stagge.local -IncludeStorage -DestinationStoragePath c:\vm\cs-mcs

#Event-Logging
get-winevent -LogName Microsoft-Windows-Hyper-V-VMMS-Admin

# in VM
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Auto' | Select-Object -ExpandProperty IntegrationServicesVersion

#Die Optimierung einer VHD-Datei erfordert, dass diese schreibgeschützt eingebunden wurde
Mount-VHD -Path "$Path" -ReadOnly
Optimize-VHD -Path "$Path" -Mode Full
Dismount-VHD -Path "$Path"

#falls WMI für Hyper-V rumzickt
stop-service vmms
mofcomp %SYSTEMROOT%\System32\WindowsVirtualizationUninstall.mof
mofcomp %SYSTEMROOT%\System32\WindowsVirtualization.V2.mof

#auf welchen Netzwerken findet LiveMigration statt
Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_VirtualSystemMigrationService | Select-Object -ExpandProperty MigrationServiceListenerIPAddressList | Where-Object {$_ -notmatch '::'}

#VMs and Switch and IP
Hyper-V\Get-VM| Select-Object @{N="VMName";E={$_.Name}},@{N="Switch";E={$_.NetworkAdapters.Switchname}},@{N="IPAddresses";E={$_.Networkadapters.IPAddresses}},@{N="SwitchType";E={(Get-VMSwitch $_.NetworkAdapters.SwitchName).SwitchType}} | Sort-Object Switch | Select-Object VMName, Switch,IPAddresses, SwitchType
Hyper-V\Get-VM| Select-Object @{N="VMName";E={$_.Name}},@{N="Switch";E={$_.NetworkAdapters.Switchname}},@{N="IPAddresses";E={$_.Networkadapters.IPAddresses}} | Sort-Object Switch | Select-Object VMName, Switch,IPAddresses | Out-GridView

#Hyper-V Live Migration methods in 2012 and 2012 R2 VMs
#http://www.altaro.com/hyper-v/hyper-v-live-migration-methods/
Move-ClusterVirtualMachineRole -Name svmanage -Node svhv1 -MigrationType Quick
Hyper-V\Move-VM -Name svmanage -Node svhv1 -MigrationType Live
Hyper-V\Move-VM -ComputerName svhv2 -Name svmanage -DestinationHost svhv1 #For Live Migrations, you can also use Move-VM
Move-VMStorage svtest -DestinationStoragePath G:\
Move-VMStorage svtest -VirtualMachinePath C:\ClusterStorage\CSV1 -Vhds @(@{'SourceFilePath' = 'G:\Virtual Hard Disks\svtest_os.vhdx'; 'DestinationFilePath' = 'C:\ClusterStorage\CSV1\Virtual Hard Disks\svtest_os.vhdx'}, @{'SourceFilePath' = 'G:\Virtual Hard Disks\svtest_data.vhdx'; 'DestinationFilePath' = 'C:\ClusterStorage\CSV1\Virtual Hard Disks\svtest_data.vhdx'})
Remove-ClusterGroup -Name svtest -RemoveResources #To prepare a clustered virtual machine for Shared Nothing Live Migration
Hyper-V\Move-VM svtest -ComputerName svhv2 -DestinationHost svhv1 -VirtualMachinePath C:\ClusterStorage\CSV1 -Vhds @(@{'SourceFilePath' = '\\svstore\vms\Virtual Hard Disks\svtest.vhdx'; 'DestinationFilePath' = 'C:\ClusterStorage\CSV1\Virtual Hard Disks\svtest.vhdx' } # Shared Nothing Live Migration

#VM AdapterNaming
Rename-VMNetworkAdapter -...   #im Host
Add-VMNetworkAdapter -VMName 'Windows 10' -Name 'test1' -DeviceNaming On
Get-NetAdapterAdvancedProperty | Where-Object DisplayValue -eq 'Name'  #in der VM

#Lock the VM Console when you close Hyper-V UI
Hyper-V\Set-VM 'Windows 10 Enterprise' -LockOnDisconnect On

#Abfrage der End-IP-Adresse des Systems
$IP = Read-Host 'Bitte geben Sie den vierten und letzten Bereich der IP-Adresse an (z.B. 101 fuer 192.168.210.101)'

#ConvergedSwitch-Team erstellen
New-NetLbfoTeam -Name Team01 -TeamMembers '10GbE #1','10GbE #2' -LoadBalancingAlgorithm HyperVPort -TeamingMode Lacp -Confirm:$false
#Management-Team erstellen
New-NetLbfoTeam -Name Team02 -TeamMembers '1GbE #1','1GbE #2' -LoadBalancingAlgorithm TransportPorts -TeamingMode SwitchIndependent -Confirm:$false

# Die virtuelle Switch erstellen, keine gemeinsame Verwendung
New-VMSwitch 'VM' -MinimumBandwidthMode weight -NetAdapterName 'Team01' -AllowManagementOS 0 -Confirm:$false

# Standard-Bandbreitenreservierung setzen
Set-VMSwitch 'VM' -DefaultFlowMinimumBandwidthWeight 1

# Erstellen der virtuellen Netzwerkkarten
Add-VMNetworkAdapter -ManagementOS -Name 'Livemigration' -SwitchName 'VM'
Add-VMNetworkAdapter -ManagementOS -Name 'CSV' -SwitchName 'VM'
Add-VMNetworkAdapter -ManagementOS -Name 'iSCSI' -SwitchName 'VM'
Add-VMNetworkAdapter -ManagementOS -Name 'iSCSI2' -SwitchName 'VM'

# Assign static IP addresses to the virtual network adapters
Set-NetIPInterface -InterfaceAlias 'vEthernet (Livemigration)' -dhcp Disabled -verbose
New-NetIPAddress -AddressFamily IPv4 -PrefixLength 24 -InterfaceAlias 'vEthernet (Livemigration)' -IPAddress 192.168.214.$IP -verbose
Set-NetAdapterBinding -Name 'vEthernet (Livemigration)' -ComponentID ms_tcpip6 -Enabled $False

Set-NetIPInterface -InterfaceAlias 'vEthernet (CSV)' -dhcp Disabled -verbose
New-NetIPAddress -AddressFamily IPv4 -PrefixLength 24 -InterfaceAlias 'vEthernet (CSV)' -IPAddress 192.168.215.$IP -verbose
Set-NetAdapterBinding -Name 'vEthernet (CSV)' -ComponentID ms_tcpip6 -Enabled $False

Set-NetIPInterface -InterfaceAlias 'vEthernet (iSCSI)' -dhcp Disabled -verbose
New-NetIPAddress -AddressFamily IPv4 -PrefixLength 24 -InterfaceAlias 'vEthernet (iSCSI)' -IPAddress 192.168.212.$IP -verbose
Set-NetAdapterBinding -Name 'vEthernet (iSCSI)' -ComponentID ms_tcpip6 -Enabled $False
Set-NetAdapterBinding -Name 'vEthernet (iSCSI)' -ComponentID ms_msclient -Enabled $False
Set-NetAdapterBinding -Name 'vEthernet (iSCSI)' -ComponentID ms_server -Enabled $False

Set-NetIPInterface -InterfaceAlias 'vEthernet (iSCSI2)' -dhcp Disabled -verbose
New-NetIPAddress -AddressFamily IPv4 -PrefixLength 24 -InterfaceAlias 'vEthernet (iSCSI2)' -IPAddress 192.168.213.$IP -verbose
Set-NetAdapterBinding -Name 'vEthernet (iSCSI2)' -ComponentID ms_tcpip6 -Enabled $False
Set-NetAdapterBinding -Name 'vEthernet (iSCSI2)' -ComponentID ms_msclient -Enabled $False
Set-NetAdapterBinding -Name 'vEthernet (iSCSI2)' -ComponentID ms_server -Enabled $False

# QoS-Konfiguration der vNICs
Set-VMNetworkAdapter -ManagementOS -Name 'LiveMigration' -MinimumBandwidthWeight 20 -verbose
Set-VMNetworkAdapter -ManagementOS -Name 'CSV' -MinimumBandwidthWeight 25 -verbose
Set-VMNetworkAdapter -ManagementOS -Name 'iSCSI' -MinimumBandwidthWeight 10 -verbose
Set-VMNetworkAdapter -ManagementOS -Name 'iSCSI2' -MinimumBandwidthWeight 10 -verbose

# Konfiguration des Management-Teams
Set-NetIPInterface -InterfaceAlias 'Team02' -dhcp Disabled -verbose
New-NetIPAddress -AddressFamily IPv4 -PrefixLength 23 -InterfaceAlias 'Team02' -IPAddress 192.168.210.$IP -verbose
Set-DnsClientServerAddress -InterfaceAlias 'Team02' -ServerAddresses ('192.168.210.2','192.168.210.4')

# Show VLanIDs on VMNetWorkAdapters
Get-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName *

#Einrichtung der Gewichtung und Priorität für die vier Klassen von Netzwerkdaten
New-NetQosPolicy 'Live Migration' -LiveMigration -MinBandwidthWeight 30 -Priority 5
New-NetQosPolicy 'SMB' -SMB -MinBandwidthWeight 50 -Priority 3
New-NetQosPolicy 'Cluster' -IPDstPort 3343 -MinBandwidthWeight 10 -Priority 6
New-NetQosPolicy 'Management' -Default -MinBandwidthWeight 10

#HyperV 2012R2 Copy Files over VMBus
$VMName = 'FSDEBSEA0700'
$SourcePath = '\\fsdebsgv4911\iopi_sources$\Install\HP\BPM Server\Install-BPM.zip'
$DestinationPath = 'D:\Install-BPM.zip'
$VM = Get-SCVirtualMachine -Name $VMName 
if ($VM) {
  $VM | Enable-VMIntegrationService -Name 'Guest Service Interface'
  Copy-VMFile -VM $VM -SourcePath $SourcePath -DestinationPath $DestinationPath -CreateFullPath -FileSource Host -Force
  $VM | Disable-VMIntegrationService -Name 'Guest Service Interface'
}

##############Live Migration Status abfragen
Get-CimInstance -Namespace 'root\virtualization\v2' -Class Msvm_MigrationJob | Format-List Name, JobStatus, PercentComplete, VirtualSystemName

#find VM over multible Hosts fast
Get-CimInstance -Namespace 'root\virtualization\v2' -Query "SELECT * FROM Msvm_ComputerSystem WHERE ElementName='fsdebss12281'" -ComputerName $HyperVServerList

#Get Hyper-V Macadress Pool
Get-CimInstance Msvm_VirtualSystemManagementServiceSettingdata -Namespace 'root\virtualization\v2'

#Get currently available MAC address from Hyper-V MAC address pool
$CurrentAddress = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\Worker' -Name CurrentMacAddress
[System.BitConverter]::ToString($CurrentAddress.CurrentMacAddress)

```

## Nested Virtualization
### Hyper-V Server
https://www.thomasmaurer.ch/2021/09/hyper-v-nested-virtualization-for-amd-processors/
1. Create Hyper-V VM 
2. Turn off
3. Set-VMProcessor -ExposeVirtualizationExtensions $true
4. Get-VMNetworkAdapter -VMName 'Hyper-V' | Set-VMNetworkAdapter -MacAddressSpoofing On
5. Turn on and install Hyper-V Role

### Nested Hyper-V VM
https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization
Set-VMProcessor -VMName 'VMName' -ExposeVirtualizationExtensions $true
