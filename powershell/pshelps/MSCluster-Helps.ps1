Get-ClusterLog -Destination 'C:\Temp\FSDEBSHE0315.log' -UseLocalTime

#properly remove virtual machine from failover cluster
Remove-ClusterGroup -VMId (Get-VM -Name $VMName).VMId -RemoveResources

(Get-ClusterSharedVolume -Cluster 'FSDEBSHE0320').SharedVolumeInfo

#Query Cluster Shared Volumes' Free Space
Get-ClusterSharedVolume -Cluster 'FSDEBSHE0320' | ForEach-Object {[PSCustomObject]@{VolumeName = $_.Name; FreeSpace =$_.SharedVolumeInfo.Partition.FreeSpace / 1GB}}

#Test VM LiveMigrations
$ClusterName = (Get-Cluster).Name
$haVMs = Get-ClusterGroup -Cluster $clusterName | Where-Object {($_.GroupType -eq 'VirtualMachine')}

foreach ($VMName in $haVMs) {
    $haVM = Get-ClusterGroup -Cluster $clusterName | Where-Object {($_.Name -eq $VMName)}
    $OwnerNode = $haVM.OwnerNode.Name
    $targetClusterNode = Get-Clusternode | ? {$_.State -eq 'Up' -and $_.Name -ne $OwnerNode} | Get-Random -Count 1
    Write-Host "$VMName Move from $OwnerNode to $($targetClusterNode.Name) : " -NoNewline
    $null = $haVM | Move-ClusterVirtualMachineRole -MigrationType Live -Node $targetClusterNode.Name -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    $migVM = Get-ClusterGroup -Cluster $clusterName | Where-Object {($_.Name -eq $VMName)}
    if ($migVM.OwnerNode.Name -ne $targetClusterNode.Name) {
        Write-Host 'Live Migration failed' -ForegroundColor Red
    } Else {
        Write-Host 'OK'
    }
}

#Nach Migration auf SMBv3 Registry bereinigen auf allen Hosts bezüglich der DependsOnSharedVolumes Einträge. Die Einträge müssen entfernt werden
Get-ClusterResource | Where-Object ResourceType -eq 'Virtual Machine Configuration' | Update-ClusterVirtualMachineConfiguration
#oder
$HyperVHost = 'FSDEBSNE0301.mgmt.fsadm.vwfs-ad','FSDEBSNE0302.mgmt.fsadm.vwfs-ad','FSDEBSNE0303.mgmt.fsadm.vwfs-ad','FSDEBSNE0304.mgmt.fsadm.vwfs-ad','FSDEBSNE0305.mgmt.fsadm.vwfs-ad','FSDEBSNE0306.mgmt.fsadm.vwfs-ad'
$Keys = (Get-ChildItem -Path HKLM:\Cluster\Resources).Name
foreach ($Key in $Keys) {
    $Key = $Key.Replace('HKEY_LOCAL_MACHINE','HKLM:')
    $DependsOnSharedVolumes = (Get-ItemProperty -Path "$Key\Parameters" -Name DependsOnSharedVolumes -EA 0).DependsOnSharedVolumes
    if ($DependsOnSharedVolumes) {
        $VMID = (Get-ItemProperty -Path "$Key\Parameters" -Name VmID).VmID
        $VMName = (Get-VM -Id $VMID -ComputerName $HyperVHost -EA 0).Name
        "$VMName : $DependsOnSharedVolumes"
        Set-ItemProperty -Path "$Key\Parameters" -Name DependsOnSharedVolumes -Value $Null 
        #Read-Host -Prompt 'Press any key'
    }
}

Suspend-ClusterNode -Name FSDEBSNE0202 -Cluster FSDEBSHE0200 -Drain # -ForceDrain
Resume-ClusterNode -Name FSDEBSNE0201 -Cluster FSDEBSHE0200 -Failback Immediate

$VMs = Get-ClusterGroup | Where-Object { $_.GroupType –eq 'VirtualMachine' } | Get-VM
Foreach ($VM in $VMs) {
  $HardDrives = $vm.HardDrives
  Invoke-Command –ComputerName $vm.computername –scriptblock {
    Param($HardDrives)
    Foreach ($HardDrive in $HardDrives){$HardDrive.Path | Get-VHD}
  } -ArgumentList $HardDrives
}

#Update VM Configuration
Get-ClusterResource -Name *conf*13095* | Update-ClusterVirtualMachineConfiguration

#Check VMName to StorageLocation
Import-Module FailoverClusters
$CR = Get-ClusterResource -Name 'SCVMM TestGelumpe2 Configuration'
Update-ClusterVirtualMachineConfiguration -InputObject $CR
# oder gleiche alle Refreshen:
Get-ClusterResource | Where-Object {$_.ResourceType -like 'Virtual Machine Configuration'} | Update-ClusterVirtualMachineConfiguration

$nodes = get-clusternode
foreach ($node in $nodes) {
  get-vm -ComputerName $node.name | 
  Where-Object {$_.configurationlocation -notmatch $_.name -or $_.snapshotfilelocation -notmatch $_.name -or $_.smartpagingfilepath -notmatch $_.name -or $_.path -notmatch $_.name} | Select-Object name, configurationlocation, snapshotfilelocation, smartpagingfilepath, path | Format-Table *
} 

Import-Module FailoverClusters

Test-Cluster -Node CS-HOST1,CS-HOST2
New-Cluster -Name  CS-STAGGE -Node CS-HOST1,CS-HOST2 -StaticAddress 192.168.190.70 -NoStorage
Get-ClusterAvailableDisk -Cluster CS-STAGGE | Add-ClusterDisk

$Cluster = Get-Cluster CS-STAGGE
$cluster.EnableSharedVolumes='Enabled/NoticeRead'

$CR = Get-ClusterResource -Name 'SCVMM TestGelumpe2 Configuration'
Update-ClusterVirtualMachineConfiguration -InputObject $CR

# Oder gleiche alle Refreshen:-
Get-ClusterResource | Where-Object {$_.ResourceType -like 'Virtual Machine Configuration'} | Update-ClusterVirtualMachineConfiguration