break

<#
    add siem entry in etc\hosts on attached VMs due to FMO Migration of SIEM:
    10.32.26.6        siem-de-lb-win      siem-de-lb-win
#>


foreach ($VMName in $VMNames) {
  $VMInfo = Get-IOPI_HyperV_VM -VMName $VMName -ComputerName $IOPI_All_HyperVServerNames 
  Write-Output "Processing  $($VMInfo.FQDN)"
  Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_AddHostEntry -ArgumentList '10.32.26.6','siem-de-lb-win.fs01.vwf.vwfs-ad      siem-de-lb-win'
  Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_GetHostEntrys
  Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock {Restart-Service -Name 'syslog-ng Agent' -Force}
}


###########################################################################
Please install new route to the SIEM network on systems in attached file.
Install first on integration servers after one day on the others

The SIEM network is 10.40.237.96/27
Port 6514
telnet 10.40.237.100 6514
siem-de-lb-win.fs01.vwf.vwfs-ad
$VMNames = @(
  'FSDEBSYDI21074',
  'FSDEBSYDI21075',
  'FSDEBSYDI21076',
  'FSDEBSYDI21077',
  'FSDEBSYDI21903',
  'FSDEBSYDI21904'
)

Import-Module -Name 'PowerShellLogging' -Force -Verbose:$False 
$LogFileName = '\\fsdebsgv4911\iopi_sources$\LogFiles\IBA-VMs\Siem_NetRoute_ADD.log' 
$LogFile = Enable-LogFile -Path $LogFileName

$VMs = Import-Csv -Path 'C:\Temp\SiemVMs.csv' -Delimiter ';' | ? VMName -match 'FSDEBSYSI30106'
foreach ($VMName in $VMNames) {
  $VMInfo = Get-IOPI_HyperV_VM -VMName $VMName -ComputerName $IOPI_All_HyperVServerNames 
  if ($VMInfo) {
    Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock { 
      $GateWay = Get-WmiObject win32_IP4RouteTable | Where-Object {$_.Mask -like '255.255.255.*' -and $_.NextHop -ne '0.0.0.0'} | Select-Object -First 1 -ExpandProperty NextHop
      if (!(route.exe print | Select-String '10.40.237.96')) {
        Write-Host "$($env:COMPUTERNAME): Add NetRoute 10.40.237.96"
        $Null = ROUTE.EXE add -p 10.40.237.96 mask 255.255.255.224 $GateWay 
      } Else {
        Write-Host "$($env:COMPUTERNAME): Route 10.40.237.96 exist"
      }
    }
  }
}

$LogFile | Disable-LogFile
