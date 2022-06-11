break
########################

function Start-ClusterValidationReport { 
  # Start-ClusterValidationReport -ValidationXmlPath .\ValidationResult.xml
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [String]
    $ValidationXmlPath
  )

  $xml = [xml](Get-Content -Path $ValidationXmlPath)
  $channels = $xml.Report.Channel.Channel

  $validationResultArray = New-Object -TypeName System.Collections.ArrayList

  foreach ($channel in $channels)
  {
    if ($channel.Type -eq 'Summary')
    {
      $channelSummaryHash = [PSCustomObject]@{}
      $summaryArray = New-Object -TypeName System.Collections.ArrayList

      $channelId = $channel.id
      $channelName = $channel.ChannelName.'#cdata-section'        
        
      foreach ($summaryChannel in $channels.Where({$_.SummaryChannel.Value.'#cdata-section' -eq $channelId}))
      {
        $channelTitle = $summaryChannel.Title.Value.'#cdata-section'
        $channelResult = $summaryChannel.Result.Value.'#cdata-section'
        $channelMessage = $summaryChannel.Message.'#cdata-section'

        $summaryHash = [PSCustomObject] @{
          Title = $channelTitle
          Result = $channelResult
          Message = $channelMessage
        }

        $null = $summaryArray.Add($summaryHash)
      }

      $channelSummaryHash | Add-Member -MemberType NoteProperty -Name Category -Value $channelName
      $channelSummaryHash | Add-Member -MemberType NoteProperty -Name Results -Value $summaryArray

      $null = $validationResultArray.Add($channelSummaryHash)
    }
  }
  return $validationResultArray
}

#Witness Share
$ClusterName = 'FSDEBSH44403'
$WitnessShare = "\\fsdebsgv3208\WitnessB10\SQL\$ClusterName"
If (Test-Path -Path $WitnessShare) {Remove-Item -Path $WitnessShare -Recurse -force}
$Null = New-Item -Path $WitnessShare -ItemType Directory
$Acl = Get-Acl $WitnessShare
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("mgmt\$($ClusterName)$",'FullControl','ContainerInherit,ObjectInherit','None','Allow')
$Acl.SetAccessRule($AccessRule)
$Acl | Set-Acl -Path $WitnessShare
Write-Output "Set Cluster WitnessShare to '$WitnessShare'"
Get-Cluster -Name $ClusterName | Set-ClusterQuorum -NoWitness
Get-Cluster -Name $ClusterName | Set-ClusterQuorum -FileShareWitness $WitnessShare

#Check CSV Redirect
Get-ClusterSharedVolumeState | Select-Object VolumeFriendlyName,StateInfo

Stop-Cluster -Cluster 'FSDEBSHE0510.mgmt.fsadm.vwfs-ad' -Force
Start-Service -Name 'ClusSvc'
Start-Cluster -Cluster 'FSDEBSHE0510.mgmt.fsadm.vwfs-ad' 
Suspend-ClusterNode -

#Change Cluster IP
Add-Type -AssemblyName Microsoft.FailoverClusters.PowerShell
$res = Get-ClusterResource "Cluster IP Address" 
$param1 = New-Object Microsoft.FailoverClusters.PowerShell.ClusterParameter $res,Address,10.40.175.80
$param2 = New-Object Microsoft.FailoverClusters.PowerShell.ClusterParameter $res,SubnetMask,255.255.255.192 
$params = $param1,$param2 
Stop-ClusterResource "Cluster IP Address"
Stop-ClusterResource "Cluster Name"
$params | Set-ClusterParameter
Start-ClusterResource "Cluster IP Address"
Start-ClusterResource "Cluster Name"
Get-ClusterResource "Cluster IP Address"| Get-ClusterParameter
Get-ClusterResource "Cluster Name" | Get-ClusterParameter


(Get-ClusterGroup 'SCVMM FSDEBSYDI22001 Resources').AntiAffinityClassNames
(Get-ClusterGroup 'SCVMM FSDEBSYDI22001 Resources').AntiAffinityClassNames = '123'

$antiaffinityclassnames = New-Object System.Collections.Specialized.StringCollection
$antiaffinityclassnames.Add('File Servers')
$antiaffinityclassnames.Add('Critical Systems')
(Get-ClusterGroup sfs1).AntiAffinityClassNames = $antiaffinityclassnames

dir 'HKLM:\Cluster\Nodes'
Get-ClusterLog -Destination 'C:\Temp\FSDEBSHE0310.log' -UseLocalTime -TimeSpan 1260   #2h
Get-ClusterLog -Destination '\\fsdebsgv4911\iopi_sources$\LogFiles\FailoverCluster\FSDEBSHE0320.log' -UseLocalTime 

#only Errors
Get-Content -Path "C:\Temp\FSDEBSHE0370.log\FSDEBSNE0373.mgmt.fsadm.vwfs-ad_cluster.csv" | Select-String -Pattern ' ERR ' | Out-File -FilePath "C:\Temp\FSDEBSHE0370.log\FSDEBSNE0373_ERR_cluster.csv" -Encoding utf8 -Force

#filter Clusterlogs for DateTime
#search for 'Found the following interfaces'
$ClusterLogPath = '\\fsdebsgv4911\iopi_sources$\SupportCases\Hyper-V\Cluster\FSDEBSHE0370'
Get-ChildItem -Path $ClusterLogPath -Filter '*_cluster.log' | % { 
  #$LogItems =  Select-String -Path $_.FullName -Pattern '2017/03/06-14:[1-4][0-9]'
  $LogItems =  Select-String -Path $_.FullName -Pattern '2017/03/07-21:[4-5][0-9]'
  $FilteredLogFileName = ($ClusterLogPath + '\' + $_.Name.SubString(0,$_.Name.IndexOf('.mgmt.fsadm.vwfs-ad')) + '_TimeFilteredCluster.Log')
  $LogItems.Line | Select-Object | Out-File -FilePath $FilteredLogFileName -Encoding utf8 -force
}


#properly remove virtual machine from failover cluster
Remove-ClusterGroup -VMId (Hyper-V\Get-VM -Name 'FSDTBSY04515').VMId -RemoveResources

Hyper-V\Get-VM | Add-ClusterVirtualMachineRole

Add-ClusterVirtualMachineRole -VMId (Hyper-V\Get-VM -Name 'FSDTBSY04515').VMId -
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
Resume-ClusterNode -Name FSDEBSNE0112 -Cluster FSDEBSHE0110 -Failback Immediate

$VMs = Get-ClusterGroup | Where-Object { $_.GroupType -eq 'VirtualMachine' } | Get-VM
Foreach ($VM in $VMs) {
  $HardDrives = $vm.HardDrives
  Invoke-Command -ComputerName $vm.computername -scriptblock {
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

Test-Cluster -Node FSDEBSNE0111,FSDEBSNE0112
New-Cluster -Name  CS-STAGGE -Node CS-HOST1,CS-HOST2 -StaticAddress 192.168.190.70 -NoStorage
Get-ClusterAvailableDisk -Cluster CS-STAGGE | Add-ClusterDisk

$Cluster = Get-Cluster CS-STAGGE
$cluster.EnableSharedVolumes='Enabled/NoticeRead'

$CR = Get-ClusterResource -Name 'SCVMM TestGelumpe2 Configuration'
Update-ClusterVirtualMachineConfiguration -InputObject $CR

# Oder gleiche alle Refreshen:-
Get-ClusterResource | Where-Object {$_.ResourceType -like 'Virtual Machine Configuration'} | Update-ClusterVirtualMachineConfiguration