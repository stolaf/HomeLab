break

Get-SCStorageArray |Select StorageArrayData,ManagementServer,FirmwareVersion,LogicalUnitCopyMethod,StorageVolumes,IsCloneCapable,IsSnapshotCapable,TotalCapacity,RemainingCapacity,InUseCapacity
Get-SCStorageProvider |Select NetworkAddress,TCPPort,ProviderType,Status,RunAsAccount,StorageArrays
Get-SCStorageFileServer | Select Name,StorageArray,StorageFileShares,StorageProvider,FirmwareVersion
Get-SCStorageFileShare | Select Name,ShareName,SharePath,StorageClassification,ObjectState,StorageVolume,IsAvailableForPlacement | ft -AutoSize

Get-SCStorageProvider -Name fsdebsy1p40012.mgmt.fsadm.vwfs-ad | Read-SCStorageProvider

Get-ItemProperty hklm:\system\currentcontrolset\control\filesystem -Name "FilterSupportedFeaturesMode"


#NetApp Storage Abfrage
Get-SCStoragePool -VMMServer 'vmmdescs2p.mgmt.fsadm.vwfs-ad' | Select-Object StorageArray,Name, `
 @{n='TotalManagedSpaceGB';expression={[math]::Round($_.TotalManagedSpace/1GB,0)}},
 @{n='RemainingManagedSpaceGB';expression={[math]::Round($_.RemainingManagedSpace/1GB,0)}},
 @{n='InUseCapacityGB';expression={[math]::Round($_.InUseCapacity/1GB,0)}} | Format-Table -AutoSize 
 
#join VM to Service
$vmname = 'FSDEBSYDI23901'                                               #Name of orphaned VM
$ServiceName = 'IBA2-INT-TestFarm with Powershell Deployment'    #Name of affected Service Instance
$Tiername = 'BL'                                     #Name of affected Service Computer Tier
$owner = 'fs01\dkx8zb8adm'                                               #Owner of VM and Service must be the same
$scvmmservername = 'vmmdescs2i.mgmt.fsadm.vwfs-ad'                                    #Name of affected SCVMM Server
$scvmmserver = Get-SCVMMServer $scvmmservername

$vm = Get-SCVirtualMachine -Name $vmname -VMMServer $scvmmserver
$vm | Set-SCVirtualMachine -Owner $owner                                 #Set Owner of VM
$vm = Get-SCVirtualMachine -Name $vmname -VMMServer $scvmmserver
$scservice = Get-SCService -Name $ServiceName -VMMServer $scvmmserver    #Get VMM Service Instance
$sccomputertier = Get-SCComputerTier -Service $scservice | Where-Object { $_.Name -eq $Tiername }   #Get VMM Service Computer Tier
Join-SCVirtualMachine -VM $vm -ComputerTier $sccomputertier              #Join VM to service instance

#unused VHDX Files
$VHDxFilesWithNoDependicies = New-Object System.Collections.ArrayList
$SCVMMServers = @('vmmdescs1p.mgmt.fsadm.vwfs-ad','vmmdescs1i.mgmt.fsadm.vwfs-ad','vmmdescs2i.mgmt.fsadm.vwfs-ad','vmmdescs1scb.mgmt.fsadm.vwfs-ad')
foreach ($SCVMMServer in $SCVMMServers) { 
  $VHDs = Get-SCVirtualHardDisk -VMMServer $SCVMMServer | Where-Object {$_.Name -match 'W2K12R2|W2K16'}  
  foreach ($VHD in $VHDs) {
    $SCDependentLibraryResource = Get-SCDependentLibraryResource -VMMServer $SCVMMServer -LibraryResource $VHD 
    if (!$SCDependentLibraryResource) {
      $Info = New-Object PSObject -Property ([ordered]@{VMMServer=$SCVMMServer;FilePath=$($VHD.location);SizeGB=[math]::Round(($($VHD.Size)/1GB),0);LibraryServer=$($VHD.LibraryServer);Release=$($VHD.Release);FamilyName=$($VHD.FamilyName)})
      $Null = $VHDxFilesWithNoDependicies.Add($Info)
    }
  }
}
Remove-Item -Path '\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\Unused-VHD-Files.xlsx' -ErrorAction SilentlyContinue
Start-IOPI_ExcelExport -Path '\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\Unused-VHD-Files.xlsx' -List $VHDxFilesWithNoDependicies  -WorkSheetName 'Unused VHD-Files'
Start-Process '\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\Unused-VHD-Files.xlsx'


#VMM ISO
$ISOs = Get-SCISO -VMMServer "vmmdescs1p.mgmt.fsadm.vwfs-ad"  # | Where-Object { $_.LibraryServer.Name -match "fsdebsy44431|fsdebsy44432|fsdebsy44433|fsdebsy44434"}
foreach ($ISO in $ISOs) {
  $SCDependentLibraryResource = Get-SCDependentLibraryResource -LibraryResource $iso 
  if ($SCDependentLibraryResource) {
    #    $SCDependentLibraryResource | select name,@{n='location';e={$vhd.Location}} | ft -AutoSize
  } Else {
    write-host "No depent on $($iso.Sharepath)" -ForegroundColor Yellow
  }
} 


#######SCVMM Networks automatisiert anlegen, Datenbasis ist IOPI-Variables.xml
# 1. Create Logical Network mit LogicalNetwork Definitionen
# 2. Create IP Pool
# 3. Create Uplink Portprofile
# 4. Create Logical Switch
# 5. Create VM Network

# ? PRJ Networks löschen?
# ? leere VLANs löschen INT: 1117, 1172
Import-Module -Name '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI' -Force 
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\Ressources\IOPI-Variables.xml'

psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\SCVMM\Save-IOPI_SCVMM_VMNetworksAsXML.ps1'

$SCVMMServer = 'vmmdescs2p.mgmt.fsadm.vwfs-ad'
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\IOPI-SCVMMTools.ps1'
Get-Help New-IOPI_SCVMM_VMNetwork -ShowWindow
New-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.222.0/26'
$VMNetworks = $IOPI_VMNetworks | Where-Object {$_.SCVMMServer -match $SCVMMServer}
$VMNetworks | ft -AutoSize
$VMNetworks.Count
New-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.222.0/26'
New-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.214.192/26'
New-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.223.0/24'
Remove-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.222.0/26'
Remove-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.214.192/26'
Remove-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet '10.41.223.0/24'

foreach ($VMNetwork in $VMNetworks) {New-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet $($VMNetwork.Subnet)}
foreach ($VMNetwork in $VMNetworks) {Remove-IOPI_SCVMM_VMNetwork -SCVMMServer $SCVMMServer -SubNet $($VMNetwork.Subnet)}

#SCVMM IPPool Modifikations, Datenbasis ist IOPI-Variables.xml
$StaticIPAddressPoolName = 'IPP-EXT-1132-KONS-DMZ2-IBA_FW1'
Get-SCStaticIPAddressPool -VMMServer $SCVMMServer -Name $StaticIPAddressPoolName 
Set-IOPI_SCVMM_SCStaticIPAddressPool -SCVMMServer $SCVMMServer -StaticIPAddressPoolName $StaticIPAddressPoolName 

#VMM Admin Overview
$VMMServer = 'vmmdescs2i.mgmt.fsadm.vwfs-ad'
$VMMAdmins = Get-SCUserRole -VMMServer $VMMServer | Where-Object Name -match 'Administrator' 
$VMMAdmins | Select-Object -ExpandProperty Members | fl 
$UserList = @()
foreach ($UserName in $VMMAdmins.Members.Name) {
  $Identity = ($UserName -split '\\')[1]
  if ( $Identity) {
    $ADUser = Get-ADUser -Identity $Identity -Server 'fs01.vwf.vwfs-ad' -Properties Description, DisplayName 
    $UserList += New-Object PSObject -Property ([ordered]@{VMMserver=$VMMAdmins.ServerConnection.Name;SCUserRoleName=$VMMAdmins.Name;SamAccountName=$ADUser.SamAccountName;DisplayName=$ADUser.DisplayName;GivenName=$ADUser.GivenName;Surname=$ADUser.Surname;Enabled=$ADUser.Enabled})
  }
}
$UserList | Out-GridView
$UserList | Export-Csv -Path 'C:\Temp\Members_2i.csv' -Delimiter ';' -NoTypeInformation -Force


#Set BootOrder
$Null = $SCVM | Set-SCVirtualMachine -FirstBootDevice 'NIC,0'

#SCVMM GuestService
Name: SCVMMGuestServiceV5
Description: Microsoft System Center 2012 Virtual Machine Manager Guest Agent

if ($vm.StopAction -ne 'ShutdownGuestOS'){Set-SCVirtualMachine -VM $vm -StopAction ShutdownGuestOS}
if ($vm.StartAction -ne 'TurnOnVMIfRunningWhenVSStopped'){Set-SCVirtualMachine -VM $vm -StartAction TurnOnVMIfRunningWhenVSStopped}

#only Remove VM from Database and then refresh VMHost
Get-SCVirtualMachine -Name 'FSDEBSYDI21036' -VMMServer 'vmmdescs1i.mgmt.fsadm.vwfs-ad' | Remove-SCVirtualMachine -Force

#Reassociate Host 
$VMHost = Get-SCVMMManagedComputer -ComputerName FSDEBSNE0121.mgmt.fsadm.vwfs-ad
Register-SCVMMManagedComputer -VMMManagedComputer $VMHost -Credential $Credential

#Updating IC Version
Import-Module virtualmachinemanager
$ISVersion = '6.1.7601.17514'
$VMs = Get-SCVirtualMachine -VMMServer $SCVMMServer
ForEach ($VM in $VMs) {
  if ($VM.Status -eq 'PowerOff' -and $VM.VMAddition -ne $ISVersion) {
    Write-Host "Upgrading $VM, please wait..." -f Green
    Set-SCVirtualMachine $VM -InstallVirtualizationGuestServices $True | Out-Null
  } elseif ($VM.VMAddition -ne $ISVersion) {
    Write-Host "Shutdown $VM..." -f Green
    Stop-SCVirtualMachine $VM | Out-Null
    Write-Host "Upgrading $VM, please wait..." -f Green
    Set-SCVirtualMachine $VM -InstallVirtualizationGuestServices $True | Out-Null
    Write-Host "Starting $VM..." -f Green
    Start-SCVirtualMachine $VM | Out-Null
  }
}

SCVMM 2012R2 SCOM Console Integration
# http://technet.microsoft.com/en-us/library/hh882396.aspx

ReportViewer installieren  http://go.microsoft.com/fwlink/?LinkId=313207
SCOM Standard Setup / Install / Operations console
fsdtbsy04441

Import-Module operationsmanager
New-SCOMManagementGroupConnection -ComputerName fsdtbsy04441
Get-SCOMAgent

$credential = Get-Credential
$runAsAccount = New-SCRunAsAccount -Credential $credential -Name 'OM12 Tools account' -Description 'OM12 Tools account ' -JobGroup 'd23c12c4-2ad2-4ec2-bd1c-7b84267b52f4'
Write-Output $runAsAccount

$vmmCredential = Get-Credential 'mgmt\DKX1S37481'
$opsMgrServerCredential = Get-SCRunAsAccount -Name 'OM12 Tools account' 
New-SCOpsMgrConnection -EnablePRO $true -EnableMaintenanceModeIntegration $true -OpsMgrServer 'fsdtbsy04441' -RunAsynchronously -VMMServerCredential $vmmCredential -OpsMgrServerCredential $opsMgrServerCredential

#List of Build Numbers for System Center Virtual Machine Manager (VMM)
http://social.technet.microsoft.com/wiki/contents/articles/15361.list-of-build-numbers-for-system-center-virtual-machine-manager-vmm.aspx
#region Trace
New-Item C:\vmmlogs -ItemType Directory
logman.exe delete VMM  #Elevated ausführen
logman.exe create trace VMM -v mmddhhmm -o $env:SystemDrive\VMMlogs\VMMLog_$env:computername.ETL -cnf 01:00:00 -p Microsoft-VirtualMachineManager-Debug -nb 10 250 -bs 16 -max 512 -a
logman.exe start vmm
#Reproduce your issue. 
logman.exe stop vmm
#The ETL file can be found in C:\vmmlogs
netsh.exe trace convert $FileName   #The converted trace file will be named in the format $FileName.txt.

#endregion Trace

#detect Replica VM
$VM = Get-SCVirtualMachine 'TS Gateway' | Where-Object{$_.IsPrimaryVM}
$VM = Get-SCVirtualMachine 'TS Gateway' | Where-Object{$_.IsRecoveryVM}

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Administrator Console\Settings' -Name IndigoTcpPort -Value 0x1fa4 -Type DWord -force
#Get Processor Count Hyper-V
Import-Module virtualMachineManager

Get-SCVirtualDVDDrive -VMMServer $VMM_Server_PK -All | Where-Object {$_.ISO -ne $null} | Select-Object Name,ISO,ISOLinked
Get-SCVMCheckpoint -VMMServer $VMM_Server_PK -VM $VMs[0] | Select-Object VM,Name,Description,AddedTime,ModifiedTime
Get-SCVirtualMachine -VMMServer $VMM_Server_PK | Get-SCVirtualHardDisk | Where-Object {$_.VHDType -like 'DynamicallyExpanding'}

'HostName;Sockets;numberOfCores;NumberOfLogicalProcessors' | Out-File -FilePath C:\Temp\ProcessorList.csv
$sb = {
  $Processor = Get-WmiObject Win32_Processor
  $numberOfCores = 0
  $NumberOfLogicalProcessors = 0
  for ($i = 0;$i -lt $Processor.Count;$i++) {
    $numberOfCores += $Processor[$i].numberOfCores
    $NumberOfLogicalProcessors += $Processor[$i].NumberOfLogicalProcessors
  }
  "$Env:COMPUTERNAME;$($Processor.Count);$numberOfCores;$NumberOfLogicalProcessors"
}
$VMHosts = Get-SCVMHost | Select-Object -ExpandProperty Name
Invoke-Command -ComputerName $VMHosts -ScriptBlock $sb | Out-File -FilePath C:\Temp\ProcessorList.csv -Append

notepad.exe  C:\Temp\ProcessorList.csv
#Clusternode freiräumen
$VMs = Get-SCVirtualMachine -All | Where-Object HostName -like 'FSDEBSNE0223*'
$DestHost = Get-SCVMHost | Where-Object { $_.Name -eq 'FSDEBSNE0222.mgmt.fsadm.vwfs-ad' }
foreach ($VM in $VMs) {Write-Host "Move $($VM.Name)"; Move-SCVirtualMachine -VM $VM -VMHost $DestHost -HighlyAvailable $true}

#Versionlist SCVMM 2012 
# SCVMM 2012 First = "3.0.6005.0"
# SCVMM 2012 Rollup 1 = KB2663960, KB2663959
# SCVMM 2012 Rollup 2 = KB2742355, KB2724539
# SCVMM 2012 Rollup 4 = 3.0.6055.0, KB2791326, KB2791325  VMM Agent 3.0.6055.0
# SCVMM 2012 SP1 Rollup 1 = 3.1.6018.0 KB2792925, KB2792926

#Snapshot löschen (zum einem früheren Zeitpunkt die VM zurücksetzen)
# Manage Checkpoints --> Restore 
# Delete Snapshot 

$backupPath = 'D:\SCVMM_DBBackups'
Backup-SCVMMServer -VMMServer 'FSDEBSEA1102.mgmt.fsadm.vwfs-ad' -Path $backupPath 
get-item -Path "$backupPath\*" | Where-Object {$_.LastWriteTime -lt (get-date).AddDays(-7) -and $_.Name -match 'bak'} | Remove-Item

#Add Adapter to a Virtual Machine
ADD-VMNetworkAdapter -vmname 'My Virtual Machine' -switchname 'ProdVlan'

#Template Unattend
$MyTemplate = Get-SCVMtemplate 'MyWS2012'
$MySettings = $MyTemplate.UnattendSettings
$MySettings.Add('oobeSystem/Microsoft-Windows-International-Core/UserLocale','de-DE')
$MySettings.Add('oobeSystem/Microsoft-Windows-International-Core/SystemLocale','en-US')
$MySettings.Add('oobeSystem/Microsoft-Windows-International-Core/UILanguage','en-US')
$MySettings.Add('oobeSystem/Microsoft-Windows-International-Core/InputLocale','de-DE')
Set-SCVMTemplate -VMTemplate $MyTemplate -UnattendSettings $MySettings

#SC2012 VMM SP1 Self-Signed Certificate wiederherstellen (Host) : meist Fehlercode 0x80072f0d
$Credential = Get-Credential
Get-VMMManagedComputer -ComputerName 'ComputerName' | Register-SCVMMManagedComputer -Credential $Credential

Get-SCVirtualHardDisk -VM $VM | Where-Object {$_.VHDType -eq 'DynamicallyExpanding'}

(Get-SCVirtualNetworkAdapter -All | Where-Object {$_.VMNetworkOptimizationEnabled -eq $true}).Count
Get-SCVirtualNetworkAdapter -All | Where-Object {$_.VMNetworkOptimizationEnabled -eq $true} | Select-Object -Last 25 | Set-SCVirtualNetworkAdapter -EnableVMNetworkOptimization $false 
foreach ($VM in (Get-SCVirtualMachine -All)) {if (-NOT ($VM | Get-VirtualSCSIAdapter)) {$VM.Name}}

Get-SCVirtualMachine | Where-Object {$_.Tag -like 'Kons*' -and $_.HostGroupPath -like '*old*'} | Sort-Object Name | Select-Object Name,Tag,HostGroupPath | Format-Table -AutoSize
Get-SCVirtualMachine | Where-Object {$_.HostGroupPath -like '*old*'} | Sort-Object Name | Select-Object Name,Tag,HostGroupPath | Format-Table -AutoSize
Get-SCVirtualMachine | Where-Object {$_.Tag -like 'Kons*' -and $_.HostGroupPath -like '*old*'} | Group-Object -Property Tag
(Get-SCVirtualMachine | Where-Object {$_.HostGroupPath -like '*old*'}).Count
Get-SCVMCheckpoint | Select-Object VM,Name,Description,AddedTime,ModifiedTime
$VM = Get-SCVirtualMachine -Name Fsddbsy13001
$VM | Get-SCVMCheckpoint

#Livemigration einer VM
$VM = Get-SCVirtualMachine -Name 'FSDEBSY12174'
Repair-SCVirtualMachine
$VMNewHost = Get-SCVMHost -ComputerName 'FSDEBSNE0212.mgmt.fsadm.vwfs-ad'
Move-SCVirtualMachine -VM $VM -VMHost $VMNewHost -HighlyAvailable $true
