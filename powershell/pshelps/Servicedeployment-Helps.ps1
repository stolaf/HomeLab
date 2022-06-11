break

start https://wiki-prod.fs01.vwf.vwfs-ad/pages/viewpage.action?spaceKey=HYP&title=Agenda
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\Ressources\IOPI-Variables.xml'

#0. Untersuchung ob IBA Farm Deployments auch über das Powershell Deployment machbar wäre
#1. zeigen wie VM Deployment über Powershell funktioniert, siehe xml Description  https://wiki-prod.fs01.vwf.vwfs-ad/x/DAJu

New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSY99999' -Description 'Test-Olaf' -IPv4 @('10.41.224.175') -VMConfigFolder 'c:\Temp' -Force -Show
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSY99999' -Description 'Test-Olaf' -IPv4 @('10.41.224.175','10.41.225.254') -VMConfigFolder 'c:\Temp' -Force -Show
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSY99999' -Description 'Test-Olaf' -IPv4 @('10.41.224.175','10.41.225.254') -VMConfigFolder 'c:\Temp' -Force -Show -OperatingSystem W2K16-Standard
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSY99999' -Description 'Test-Olaf' -IPv4 @('10.41.224.190','10.41.225.254') -VMConfigFolder 'c:\Temp' -Force -Show -OperatingSystem W2K16-Standard -Net35Framework
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSY99999' -Description 'Test-Olaf' -IPv4 @('10.41.224.190','10.41.225.254') -VMConfigFolder 'c:\Temp' -Force -Show -OperatingSystem W2K16-Standard -Net35Framework -InstallSoftware SQL2016Standard
#Demo
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSY99999' -Description 'Test-Olaf' -IPv4 @('10.41.224.190','10.41.225.254') -VMConfigFolder 'c:\Temp' -Force -Show -OperatingSystem W2K12R2-Standard -Net35Framework
Connect-IOPI_HyperV_VMConsole -VMName 'FSDEBSY99999' -ComputerName $($VMInfo.VMHost) -DesktopSize 1152x864 
Remove-IOPI_HyperV_VM -VMName 'FSDEBSY99999'

# Unattend.xml und VM Powershell Konfigurationsscripte werden dynamisch erstellt und in C:\Windows\panther bzw. C:\windows\Setup\PSScripts abgelegt
psedit 'C:\Temp\unattend.xml'
psedit 'C:\Temp\000_InitialScript.ps1'
psedit 'C:\Temp\001_FirstRunScript.ps1'
psedit 'C:\Temp\002_Start-VMOSBaseConfig.ps1'
psedit 'C:\Temp\003_Start-VMOSBasefinalconfig.ps1'

#Imageerstellung funktioniert auch darüber
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\Ressources\IOPI-ImageFactory.xml'

#2. was muss getan werden um dies Verfahren ready für IBA Farmen zu machen 
#IOPI-Variables.xml mit Definitionen für VMNetworks, NetRoutes,SCStaticIPAddressPools,SCUplinkPortProfiles,SCLogicalSwitches,SCLogicalNetworks anreichern
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\Ressources\IOPI-Variables.xml'
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\SCVMM\Save-IOPI_SCVMM_VMNetworksAsXML.ps1'
. '\\fsdebsgv4911\iopi_sources$\PowerShell\SCVMM\Save-IOPI_SCVMM_VMNetworksAsXML.ps1' -SCVMMServer 'vmmdescs1p.mgmt.fsadm.vwfs-ad' -xmlFileName '\\fsdebsgv4911\iopi_sources$\PowerShell\SCVMM\VMNetworks\vmmdescs1p_vmnetworks.xml'
psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\SCVMM\VMNetworks\vmmdescs1p_vmnetworks.xml'


#5. QIP 
Get-IOPI_QIP_IBA_FreeIPAddress
Get-Help Get-IOPI_QIP_IBA_FreeIPAddress -ShowWindow

psedit '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\IOPI-VMTools.ps1'
Remove-IOPI_QIP_IPAddressesUnused
Get-Help Remove-IOPI_QIP_IPAddressesUnused -ShowWindow

Remove-IOPI_IBA_IPAddressesUnused
Get-Help Remove-IOPI_IBA_IPAddressesUnused -ShowWindow

Get-IOPI_IBA_ADComputersUnusedCandidates
Get-Help Get-IOPI_IBA_ADComputersUnusedCandidates -ShowWindow
$ADComputersUnusedCandidates = Get-IOPI_IBA_ADComputersUnusedCandidates -DCName 'FSDEBSYSI30105'  
$ADComputersUnusedCandidates | Format-Table -AutoSize

Register-IOPI_QIP_IBA_IPAddressesUsed #ToDo für alle VMs als FQDN, ohne Namensauflösung, Description: Hostet in IBA DNS

New-IOPI_IBA_ADComputerAccount  
Get-Help New-IOPI_IBA_ADComputerAccount -ShowWindow

Remove-IOPI_IBA_ADComputerAccount
Get-Help Remove-IOPI_IBA_ADComputerAccount -ShowWindow

Register-IOPI_IBA_DNSIPv4Address 
Get-Help Register-IOPI_IBA_DNSIPv4Address -ShowWindow

Register-IOPI_QIP_IBADNSIPv4Address
Get-Help Register-IOPI_QIP_IBADNSIPv4Address -ShowWindow

#6. Bespielconfig für eine Farm
powershell_ise '\\fsdebsgv4911\iopi_sources$\PowerShell\[Integration]\[TestFarm]\TestFarmConfig.xml'

function Get-IOPI_SubInfos {
  <#
      .Description
      Get some Infos from Subet for VM Deployment

      .EXAMPLE
      $SubNet = '10.41.37.64/26'
      Get-IOPI_SubInfos -SubNet $SubNet 
  #>
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory)][string] $SubNet
  )

  $VMSubNet = $IOPI_VMNetworks | Where-Object {$_.SubNet -match $SubNet }
  if (!$VMSubNet) {return $null}
  $SCStaticIPAddressPool = $IOPI_SCStaticIPAddressPools | Where-Object {$_.Name -match $($VMSubNet.SCStaticIPAddressPool)}
  $SCLogicalSwitch = $IOPI_SCLogicalSwitches | Where-Object {$_.Name -match $($VMSubNet.SCLogicalSwitch)}
  $QIPSubnetName = Get-IOPI_QIP_IPv4SubnetInfos -Subnet $($VMSubNet.Subnet) | Select-Object -ExpandProperty subnetName
 
  switch ($VMSubNet.SCStaticIPAddressPool) {
    {$_ -match 'IPP-INT-'} {$Description = "VLAN $($SCStaticIPAddressPool.VlanID) (Internal)"; $IBADNSZone='' ;break}
    {$_ -match 'IPP-EXT-'} {$Description = "VLAN $($SCStaticIPAddressPool.VlanID) (External)"; $IBADNSZone=''; break}
    Default {$Description = "VLAN $($SCStaticIPAddressPool.VlanID)"; $IBADNSZone=''}
  }

  $Domain = $IOPI_Domains | Where-Object {$_.SCVMMServer -match $($VMSubNet.SCVMMServer)} 
  if ($VMSubNet.SCStaticIPAddressPool -match '-KONS-') {$Domain = $Domain | Where-Object {$_.Environment -match 'KONS'} }
  
  if ($Description -match 'External') {$DNSLookupZone = $Domain.DNS.ExtDNSLookupZone}
  if ($Description -match 'Internal') {$DNSLookupZone = $Domain.DNS.DNSLookupZone}

  # Get-IOPI_QIP_IBA_FreeIPAddress -SubNet $SubNet
  $IPv4NextFreeAddress = Get-IOPI_QIP_IPv4NextFreeAddress -Subnet $SubNet | Select-Object -ExpandProperty objectAddr
  New-Object PSObject -Property ([ordered]@{
      SubNet = $SCStaticIPAddressPool.Subnet
      Description = $Description
      CIDR = $SCStaticIPAddressPool.CIDR
      IP = $IPv4NextFreeAddress
      Mask = $SCStaticIPAddressPool.Mask
      VlanID = $SCStaticIPAddressPool.VlanID
      DNSServers = $SCStaticIPAddressPool.DNSServers
      DNSSearchSuffixes = $SCStaticIPAddressPool.DNSSearchSuffixes
      DefaultGateways = $SCStaticIPAddressPool.DefaultGateways
      VmqWeight = $SCStaticIPAddressPool.VmqWeight
      SwitchName =  $SCLogicalSwitch.Name
      SCVMMServer = $VMSubNet.SCVMMServer
      QIPSubNetName = $QIPSubnetName
      Domain = $Domain.Name
      DomJoinAccount = $Domain.DomJoinAccount
      DC = $Domain.DC.FQDN[0]
      DNSLookupZone = $DNSLookupZone
  }) 
}
