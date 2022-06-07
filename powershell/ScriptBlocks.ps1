$sb_GetSystemInfo = {
  $Win32_OperatingSystem = Get-WMIObject -Query 'SELECT * FROM Win32_OperatingSystem'
  $Win32_ComputerSystem = Get-WMIObject -Query 'SELECT * FROM Win32_ComputerSystem'
  $Win32_Processor = Get-WmiObject -class Win32_Processor
  $Win32_ComputerSystemProduct = Get-WMIObject Win32_ComputerSystemProduct
  if ([Environment]::OSVersion.Version.Major -ge '10') {
    $Major = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentMajorVersionNumber).CurrentMajorVersionNumber
    $Minor = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentMinorVersionNumber).CurrentMinorVersionNumber
    $Release = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' ReleaseId).ReleaseId
    $Build = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild).CurrentBuild
    $Revision = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' UBR).UBR
    $Version = "$($Major).$($Minor).$($Release).$($Build).$($Revision)"
  } Else {
    $Version = $Win32_OperatingSystem.Version
  }
  $Domain = $Win32_ComputerSystem.Domain
  function Test-RebootPending {
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    try {
      $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
      $status = $util.DetermineIfRebootPending()
      if(($status -ne $null) -and $status.RebootPending){
        return $true
      }
    }catch{}
    
    return $false
  }

  $Release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name 'Release' -ErrorAction SilentlyContinue).Release
  $TLS = (Get-Itemproperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
  $DotNetVersion = ''
  switch ($Release) {  #https://docs.microsoft.com/de-de/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    {$_ -ge 461808}   {$DotNetVersion='4.7.2'; break}
    {$_ -ge 461308}   {$DotNetVersion='4.7.1'; break}
    {$_ -ge 460798}   {$DotNetVersion='4.7'; break}
    {$_ -ge 394802}   {$DotNetVersion='4.6.2'; break}
    {$_ -ge 394254}   {$DotNetVersion='4.6.1'; break}
    {$_ -ge 393295}   {$DotNetVersion='4.6'; break}
    {$_ -ge 379893}   {$DotNetVersion='4.5.2'; break}
    {$_ -ge 378675}   {$DotNetVersion='4.5.1'; break}
    {$_ -ge 378389}   {$DotNetVersion='4.5'; break}
    default {$DotNetVersion='unknown .NET Framework Version'; break}
  }

  New-Object PSObject -Property ([ordered]@{
      HostName=$ENV:COMPUTERNAME
      OSName=$Win32_OperatingSystem.Caption
      OSVersion=$Version
      PSVersion = $PSVersionTable.PSVersion.ToString()
      DotNetVersion = $DotNetVersion
      Model = $Win32_ComputerSystem.Model
      NumberOfProcessorSockets = ($Win32_Processor).NumberOfCores.Count
      NumberOfProcessorCores = (($Win32_Processor).NumberOfCores | Measure-Object -Sum).Sum
      NumberOfLogicalProcessors = (($Win32_Processor).NumberOfLogicalProcessors | Measure-Object -Sum).Sum
      PROCESSOR_ARCHITECTURE = $ENV:PROCESSOR_ARCHITECTURE
      RegisteredOwner= (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOwner
      RegisteredOrganization=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOrganization
      LocalDisks = Get-WmiObject -Query "SELECT * FROM  Win32_LogicalDisk WHERE DriveType = '3'" | Select-Object DeviceID,@{Name="Label";e={$_.VolumeName}}, @{Name="DiskSizeGB";e={($_.Size /1GB).ToString('##.#')}},@{Name="FreeDiskSpaceGB";e={($_.FreeSpace /1GB).ToString('##.#')}}
      InstallDate=[Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.InstallDate)
      LastBootUpTime=[Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.LastBootUpTime)
      TotalPhysicalMemoryGB=($Win32_ComputerSystem.TotalPhysicalMemory / 1GB).ToString('##.#')
      FreePhysicalMemoryGB= ($Win32_OperatingSystem | Select-Object @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,1)}}).FreeGB
      SerialNumber = $Win32_ComputerSystemProduct.IdentifyingNumber.Trim()
      Domain=$Domain
      #LogonServer= try {(nltest.exe /sc_query:$Domain)[1]} catch {''};
      SystemLocale= if (Get-Command Get-WinSystemLocale -ErrorAction SilentlyContinue) {(Get-WinSystemLocale).Name} Else {''}
      TimeZone= (Get-WmiObject -Class win32_timezone).Caption
      LocalTime= Get-Date
      UpdateCount = (Get-HotFix).Count
      HypervisorPresent = $Win32_ComputerSystem.HypervisorPresent
      RebootPending = Test-RebootPending
      'TLS1.0_Disabled' = if ($TLS -eq 0) {$True} Else {$false}
  })
}
$sb_TestPendingReboot = {
  <#
      .DESCRIPTION
      Check if Reboot Pending

      .EXAMPLE
      Invoke-Command -ComputerName 'FSDEBSNE0221.mgmt.fsadm.vwfs-ad' -HideComputerName -ScriptBlock $sb_TestPendingReboot | ft -autosize
      Invoke-Command -ComputerName $IOPI_INT_HyperVServerNames -HideComputerName -ScriptBlock $sb_TestPendingReboot | ? RequireReboot -eq $True | ft -autosize
      Invoke-Command -ComputerName $IOPI_ALL_HyperVServerNames -Credential $myAdminCredential -HideComputerName -ScriptBlock $sb_TestPendingReboot | ? RequireReboot -eq $True | ft -autosize
      #>

    $RebootCauses =  @()
    $Test = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing' -Name 'RebootPending' -ErrorAction Ignore
    if ($Test) {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='RebootPending';RequireReboot=$true;Description=''})
    } else {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='RebootPending';RequireReboot=$false;Description=''})
    }

    $Test = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Name 'RebootRequired' -ErrorAction Ignore
    if ($Test) {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='RebootRequired';RequireReboot=$true;Description=''})
    } else {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='RebootRequired';RequireReboot=$false;Description=''})
    }

    $Test = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction Ignore
    if ($Test) {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='PendingFileRenameOperations';RequireReboot=$true;Description=$($Test.PendingFileRenameOperations -join ',')})
    } else {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='PendingFileRenameOperations';RequireReboot=$false;Description=''})
    }

    $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
    $DetermineIfRebootPending = $util.DetermineIfRebootPending()
    if(($DetermineIfRebootPending -ne $null) -and $DetermineIfRebootPending.RebootPending -eq $true){
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='SCCMAgent';RequireReboot=$true;Description=''})
    }
    else {
      $RebootCauses += New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;Name='SCCMAgent';RequireReboot=$false;Description=''})
    }

    return $RebootCauses
}
$sb_GetDotNetVersion = {
  <#
      .DESCRIPTION
      Get installed .NET Version

      .EXAMPLE
      $VMInfos = Get-IOPI_HyperV_VM -VMName 'FS*' -ComputerName $IOPI_INT_HyperVServerNames | Where-Object {$_.State -eq 'Running' -and $_.FQDN -notmatch 'd-fs01'}
      $DotNetVersions = $VMInfos | Invoke-IOPI_Parallel -ScriptBlock {
      Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
      $VMInfo = $_
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_GetDotNetVersion
      }

      .LINK
      https://support.microsoft.com/de-de/help/318785/how-to-determine-which-versions-and-service-pack-levels-of-the-microso
  #>
  $Release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name 'Release' -ErrorAction SilentlyContinue).Release
  $DotNetVersions = @()
  switch ($Release) {  #https://docs.microsoft.com/de-de/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    {$_ -ge 461808}   {$DotNetVersion='4.7.2'; break}
    {$_ -ge 461308}   {$DotNetVersion='4.7.1'; break}
    {$_ -ge 460798}   {$DotNetVersion='4.7'; break}
    {$_ -ge 394802}   {$DotNetVersion='4.6.2'; break}
    {$_ -ge 394254}   {$DotNetVersion='4.6.1'; break}
    {$_ -ge 393295}   {$DotNetVersion='4.6'; break}
    {$_ -ge 379893}   {$DotNetVersion='4.5.2'; break}
    {$_ -ge 378675}   {$DotNetVersion='4.5.1'; break}
    {$_ -ge 378389}   {$DotNetVersion='4.5'; break}
    default {$DotNetVersion='unknown .NET Framework Version'; break}
  }
  $DotNetVersions += $DotNetVersion
  if (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5') {
    $Install = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5' -Name 'Install').Install
    $SP = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5' -Name 'SP').SP
    if (($Install -eq [int32]1) -and ($SP -eq [int32]0)) {
      $DotNetVersions += '3.5 without SP1'
    }
    if (($Install -eq [int32]1) -and ($SP -eq [int32]1)) {
      $DotNetVersions += '3.5 SP1'
    }
  }
  $DotNetVersions
}
$sb_GetLocalAdminGroupMembers = {
  $LocalAdminGroupName = ((New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')).Translate([System.Security.Principal.NTAccount]).Value -split '\\')[1]
  $LocalAdminGroupMembers = net.exe localgroup $LocalAdminGroupName | where-Object {$_} | Select-Object -skip 4
  if ($LocalAdminGroupMembers.Count -gt 1) {$LocalAdminGroupMembers = $LocalAdminGroupMembers | Select-Object -First ($LocalAdminGroupMembers.Count -1)} Else {$LocalAdminGroupMembers = ''}
  $LocalGroupMember = $LocalAdminGroupMembers | ForEach-Object {
    $SID = ([Security.Principal.NTAccount]"$_").Translate([Security.Principal.Securityidentifier])
    New-Object PSObject -Property ([ordered]@{Name=$_;SID=$SID})
  }
  $LocalGroupMember
}
$sb_GetVMNetworks = {
  $IPv4Match = '\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
  $IPv6Match = '^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$'
  $NLB_ClusterSettings = Get-WmiObject -Namespace 'root\MicrosoftNLB' -Query 'SELECT * FROM MicrosoftNLB_ClusterSetting' -ErrorAction SilentlyContinue
  $NLB_NodeSettings = Get-WmiObject -Namespace 'root\MicrosoftNLB' -Query 'SELECT * FROM MicrosoftNLB_NodeSetting' -ErrorAction SilentlyContinue

  if ($NLB_ClusterSettings) {
    $NLB_ClusterSetting = New-Object PSObject -Property @{
      Name = $NLB_ClusterSettings.ClusterName
      IPAddress = $NLB_ClusterSettings.ClusterIPAddress
      NetworkMask = $NLB_ClusterSettings.ClusterNetworkMask
      IPToMulticastIP = $NLB_ClusterSettings.ClusterIPToMulticastIP
      MACAddress = $NLB_ClusterSettings.ClusterMACAddress.Replace('-',':')
    }
  }
  if ($NLB_NodeSettings) {
    $NLB_NodeSetting = New-Object PSObject -Property @{
      Name = $NLB_NodeSettings.Name
      IPAddress = $NLB_NodeSettings.DedicatedIPAddress
      NetworkMask = $NLB_NodeSettings.DedicatedNetworkMask
    }
  }

  $NetAdapterConfigs = @()
  $NetworkAdapterConfigurations = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE
  foreach ($NetworkAdapterConfiguration in $NetworkAdapterConfigurations) {
    $MaskV4 = $NetworkAdapterConfiguration | Select-Object -ExpandProperty IPSubnet | Where-Object {$_ -match $IPv4Match}
    $NetName = (Get-WmiObject -Class Win32_NetworkAdapter -Filter InterfaceIndex=$($NetworkAdapterConfiguration.InterfaceIndex)).NetConnectionID
    $NetAdapterConfigs += New-Object PSObject -Property ([ordered]@{
      Name = $NetName
      Description = $NetworkAdapterConfiguration.Description
      InterfaceIndex = $NetworkAdapterConfiguration.InterfaceIndex
      IPv4  = ($NetworkAdapterConfiguration | Select-Object -ExpandProperty IPAddress | Where-Object {$_ -match $IPv4Match -and $_ -ne $NLB_ClusterSetting.IPAddress}) -join ','
      MaskV4 = if ($MaskV4 -is [array]) {$MaskV4[0]} Else {$MaskV4}
      GatewayV4  = $($NetworkAdapterConfiguration.DefaultIPGateway)
      DnsV4 = if ($NetworkAdapterConfiguration.DNSServerSearchOrder) {($NetworkAdapterConfiguration | Select-Object -ExpandProperty DNSServerSearchOrder) -join ','} Else {''}
      DomainDNSRegistrationEnabled = $($NetworkAdapterConfiguration.DomainDNSRegistrationEnabled)
      FullDNSRegistrationEnabled = $($NetworkAdapterConfiguration.FullDNSRegistrationEnabled)
      DNSDomainSuffixSearchOrder = if ($NetworkAdapterConfiguration.DNSDomainSuffixSearchOrder) {($NetworkAdapterConfiguration.DNSDomainSuffixSearchOrder) -join ','} Else {''}
      DHCPEnabled = $NetworkAdapterConfiguration.DHCPEnabled
      MACAddress = $($NetworkAdapterConfiguration.MACAddress)
    })
  }
  $NetAdapterConfigs
}
$sb_GetVMDetails = {
  param ([DateTime] $DomainTime)
  function Test-TCPConnection {
    <#
        .DESCRIPTION
        Test TCP Connection like Telnet
        .PARAMETER ComputerName
        .PARAMETER Port
        .EXAMPLE
        Test-TCPConnection -ComputerName "FSDEBSY66673.mgmt.fsadm.vwfs-ad" -Port 2080
    #>
    [CmdletBinding()] param (
      [Parameter(Mandatory=$true)][ValidateNotNull()][string] $ComputerName,
      [Parameter(Mandatory=$true)][ValidateScript( {$_ -gt 0})][int]$Port
    )

    try {
      $clientSocket = new-object System.Net.Sockets.TcpClient
      $clientSocket.SendTimeout = 2000
      $clientsocket.ReceiveTimeout = 2000
      $clientsocket.Connect($ComputerName,$Port)
      return $true
    } catch {
      return $false
    }
  }
  function Get-InstalledSoftware {
    $SoftwareList = @()
    $Softwares = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName}
    if (Test-Path 'HKLM:\Software\Wow6432Node') {
      $Softwares += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName}
    }
    foreach ($Software in $Softwares) {
      $SWInfo = New-Object psobject -Property @{
        'DisplayName' = $Software.DisplayName
        'DisplayVersion' = $Software.DisplayVersion
        'Publisher' = $Software.Publisher
        'InstallDate' = $Software.InstallDate
        'InstallSource' = $Software.InstallSource
        'HelpLink' = $Software.HelpLink
        'UninstallString' = $Software.UninstallString
        'Path' = $Software.PSPath.Replace('Microsoft.PowerShell.Core\Registry:','').Replace('HKEY_LOCAL_MACHINE','HKLM:')
      }
      $SoftwareList += $SWInfo
    }
    $SoftwareList
  }

  $DateTime = Get-Date

  $IPv4Match = '\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
  $IPv6Match = '^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$'

  $listOfVMs = @()

  $Win32_ComputerSystem = Get-WMIObject -Query 'SELECT * FROM Win32_ComputerSystem'
  $Win32_OperatingSystem = Get-WMIObject -Query 'SELECT * FROM Win32_OperatingSystem'
  $FQDN = ($ENV:COMPUTERNAME + '.' + $($Win32_ComputerSystem.Domain))
  Write-Verbose "Processing Get-VMDetails on '$FQDN'"
  $InstalledSoftware = Get-InstalledSoftware
  $NLA = (Get-WmiObject -Query "SELECT * FROM Win32_TSGeneralSetting WHERE TerminalName='RDP-Tcp'" -Namespace 'root\CIMV2\TerminalServices').UserAuthenticationRequired
  $LicenseStatus = Get-WMIObject -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object PartialProductKey | Sort-Object -Property LicenseStatus | Select-Object -ExpandProperty LicenseStatus -First 1
  $LocalAdminGroupName = ((New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')).Translate([System.Security.Principal.NTAccount]).Value -split '\\')[1]
  $LocalAdminGroupMembers = net.exe localgroup $LocalAdminGroupName | where-Object {$_} | Select-Object -skip 4
  if ($LocalAdminGroupMembers.Count -gt 1) {$LocalAdminGroupMembers = $LocalAdminGroupMembers | Select-Object -First ($LocalAdminGroupMembers.Count -1)} Else {$LocalAdminGroupMembers = ''}

  $ApplicationDiscovery = Get-ChildItem -Path 'C:\Program Files\FSAG\ApplicationDiscovery' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
  $LogFileSizeMB = $Null
  if ($Env:COMPUTERNAME -match 'FSDEBSY01000') {  #not running on LogFileServer
    $LogFileSizeMB = 'n.a.'
  } Else {
    if (Test-Path -Path 'D:\LogFiles') {
      $fso = New-Object -ComObject Scripting.FileSystemObject
      $LogFileSizeMB = [math]::Round(($fso.GetFolder('D:\LogFiles').Size / 1MB),2)
    }
  }
  $WMISVCHostProcess = Get-WmiObject -Query "SELECT * FROM win32_service WHERE Name='winmgmt'" | ForEach-Object {Get-WMIObject -Query "SELECT * FROM win32_process WHERE ProcessID='$($_.ProcessId)'"}

  $EntireX = $InstalledSoftware | Where-Object {$_.DisplayName -Match 'EntireX'}
  $AppSight = $InstalledSoftware | Where-Object {$_.DisplayName -Match 'AppSight' -and $_.UninstallString}
  $IBMWebSphere = $InstalledSoftware | Where-Object {$_.DisplayName -Match 'IBM WebSphere MQ'}
  $NotepadPlusPlus = $InstalledSoftware | Where-Object {$_.DisplayName -Match 'Notepad\+\+'}
  $IBA = New-Object PSObject -Property @{
    'ServerFarm' =  try {(Get-ItemProperty -Path 'HKLM:\Software\IBA' -Name 'ServerFarm' -ErrorAction SilentlyContinue).ServerFarm.Trim()} Catch {''} ;
    'ServerType' =  try {(Get-ItemProperty -Path 'HKLM:\Software\IBA' -Name 'ServerType' -ErrorAction SilentlyContinue).ServerType.Trim()} Catch {''} ;
    'IBA' =  try {(Get-ItemProperty -Path 'HKLM:\Software\IBA' -Name 'IBA' -ErrorAction SilentlyContinue).IBA.ToString()} Catch {''} ;
    'Version' =  try {(Get-ItemProperty -Path 'HKLM:\Software\IBA' -Name 'Version' -ErrorAction SilentlyContinue).Version.ToString()} Catch {''} ;
    'Status' =  try {(Get-ItemProperty -Path 'HKLM:\Software\FSAG' -Name 'Status' -ErrorAction SilentlyContinue).Status.ToString()} Catch {''} ;
    'ServiceLevelQuality' =  try {(Get-ItemProperty -Path 'HKLM:\Software\FSAG' -Name 'ServiceLevelQuality' -ErrorAction SilentlyContinue).ServiceLevelQuality.ToString()} Catch {''} ;
    'Department' =  try {(Get-ItemProperty -Path 'HKLM:\Software\FSAG' -Name 'Department' -ErrorAction SilentlyContinue).Department.ToString()} Catch {''} ;
    'WMISVCHostProcessSizeMB' = '{0:F0}' -f ($($WMISVCHostProcess.WorkingsetSize) / 1MB)
    'SVCHostServices' = (Get-WmiObject -Query "SELECT * FROM win32_service WHERE ProcessID='$($WMISVCHostProcess.ProcessID)' and State='Running'" | Select-Object -ExpandProperty Name) -join ','
    'ISB_ToolCollectionExist' = if (Test-Path -Path "$PSHOME\Modules\ISB-ToolCollection") {$True} Else {$False}
    'ServiceCount' = (Get-Service).Count
    'EntireX_Exist' = if ($EntireX) {$True} Else {$False}
    'IBMWebSphere_Exist' = if ($IBMWebSphere) {$True} Else {$False}
    'AppSight_Exist' = if ($AppSight) {$True} Else {$False}
    # 'SharesToInspect' = $SharesToInspect
  }

  if ($LogFileSizeMB) {$IBA | Add-Member -MemberType NoteProperty -Name 'LogFileSizeMB' -Value $LogFileSizeMB}
  if ($ApplicationDiscovery) {$IBA | Add-Member -MemberType NoteProperty -Name 'ApplicationDiscovery' -Value ($ApplicationDiscovery -join ',')}

  $PowerShell = New-Object PSObject -Property @{
    'Version' = $PSVersionTable.PSVersion.ToString()
    'CLRVersion' = $PSVersionTable.CLRVersion.ToString()
    'MaxEnvelopeSizekb' = (Get-Item WSMan:\localhost\MaxEnvelopeSizekb -ErrorAction SilentlyContinue).Value
    'PSEdition' = $PSVersionTable.PSEdition
  }

  if ((Get-Service -Name 'ccmexec' -ErrorAction SilentlyContinue).Status -eq 'Running') {
    $ccm_ClientSDK = Invoke-WmiMethod -Namespace 'ROOT\ccm\ClientSDK' -Class CCM_ClientUtilities -Name DetermineIfRebootPending -ErrorAction SilentlyContinue
    $SoftwareUpdates = Get-WMIObject -Query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK' -ErrorAction SilentlyContinue
    $SCCM_Client = [wmiclass] '\\.\root\ccm:sms_client'
    $sSiteCode = ''
    try {
      $sSiteCode = $($SCCM_Client.GetAssignedSite()).sSiteCode
    } catch {
      $sSiteCode =''
    }
    $RebootPending = $ccm_ClientSDK.RebootPending
    if ((Get-ItemProperty -Path 'HKLM:\System\FSAG\SecuritySettings-OS-WINSRV' -Name 'RebootPending' -ErrorAction SilentlyContinue).RebootPending -eq 1) {$RebootPending = $True}
    $ManagementPoint = (Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_LookupMP').Name | Where-Object {$_ -match 'FSDEBSY6667[3-4]'}
    if ($ManagementPoint -is [array]) {$ManagementPoint = $ManagementPoint[0]}
    $SCCMAgent = New-Object PSObject -Property @{
      'SCCMAgent' = $True
      'Version' = (Get-WMIObject -Namespace 'root\CCM' -Query 'Select ClientVersion From SMS_Client').ClientVersion
      'ManagementPoint' =  if ($ManagementPoint) {$ManagementPoint} Else {'n.a'}
      'ManagementPointConnection' = if ($ManagementPoint) {Test-TCPConnection -ComputerName $ManagementPoint -Port 2080} Else {$false}
      'ClientID' = (Get-WMIObject -Namespace 'root\CCM' -Query 'Select ClientID From CCM_Client').ClientID
      'ClientIDChangeDate' = (Get-WMIObject -Namespace 'root\CCM' -Query 'Select ClientIDChangeDate From CCM_Client').ClientIDChangeDate
      'SiteCode' = $sSiteCode
      'RebootPending' = $RebootPending
      'IngracePeriod' = $ccm_ClientSDK.IngracePeriod
      'UpdateCount' = $SoftwareUpdates.Count
    }
  } Else {
    $SCCMAgent = New-Object PSObject -Property @{
      'SCCMAgent' = $false
    }
  }

  $SCOMAgent = @()
  try {
    $Agent = New-Object -ComObject AgentConfigManager.MgmtSvcCfg -ErrorAction SilentlyContinue
    $ManagementGroups = $Agent.GetManagementGroups()
    $oms = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.displayName -eq 'Microsoft Monitoring Agent' }
    foreach ($ManagementGroup in $ManagementGroups) {
      $SCOMAgent += New-Object PSObject -Property @{
        'SCOMAgent' = $True
        'Version' = $oms.DisplayVersion
        'GroupName' = $ManagementGroup.managementGroupName
        'ManagementServer' = $ManagementGroup.ManagementServer
        'ManagementServerConnection' = Test-TCPConnection -ComputerName $($ManagementGroup.ManagementServer) -Port $($ManagementGroup.ManagementServerPort)
        'Port' = $ManagementGroup.ManagementServerPort
        'isADManaged' = $ManagementGroup.IsManagementGroupFromActiveDirectory
        'Account' = $ManagementGroup.ActionAccount
      }
    }
  } Catch {
    $SCOMAgent += New-Object PSObject -Property @{
      'SCOMAgent' = $False
      'Error' = "$_"
    }
  }

  $VirenScanner = New-Object PSObject -Property @{
    'McAfee_Agent_Backwards_Compatibility_Service' = if (Get-Service -Name 'McAfeeFramework' -ErrorAction SilentlyContinue) {$True} Else {$False}
    'McAfee_Agent_Common_Services' = if (Get-Service -Name 'macmnsvc' -ErrorAction SilentlyContinue) {$True} Else {$False}
    'McAfee_Agent_Service' = if (Get-Service -Name 'masvc' -ErrorAction SilentlyContinue) {$True} Else {$False}
    'McAfee_Move_Service' = if (Get-Service -Name 'mvagtsvc' -ErrorAction SilentlyContinue) {$True} Else {$False}
  }

  $Release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name 'Release' -ErrorAction SilentlyContinue).Release
  $DotNetVersion = ''
  switch ($Release) {  #https://docs.microsoft.com/de-de/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    {$_ -ge 461808}   {$DotNetVersion='.NET Framework 4.7.2 or later'; break}
    {$_ -ge 461308}   {$DotNetVersion='.NET Framework 4.7.1'; break}
    {$_ -ge 460798}   {$DotNetVersion='.NET Framework 4.7'; break}
    {$_ -ge 394802}   {$DotNetVersion='.NET Framework 4.6.2'; break}
    {$_ -ge 394254}   {$DotNetVersion='.NET Framework 4.6.1'; break}
    {$_ -ge 393295}   {$DotNetVersion='.NET Framework 4.6'; break}
    {$_ -ge 379893}   {$DotNetVersion='.NET Framework 4.5.2'; break}
    {$_ -ge 378675}   {$DotNetVersion='.NET Framework 4.5.1'; break}
    {$_ -ge 378389}   {$DotNetVersion='.NET Framework 4.5'; break}
    default {$DotNetVersion='unknown .NET Framework Version'; break}
  }

  try {
    $OracleClientVersion = ([WMI] "\\.\root\CIMV2:CIM_DataFile.Name='D:\Oracle64R2\product\11.2.0\client_1\odp.net\bin\4\Oracle.DataAccess.dll'").Version
  } catch {
    $OracleClientVersion = 'n.a'
  }

  $Software = [pscustomobject] @{
    'IntegrationServicesVersion' = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Auto' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IntegrationServicesVersion
    'DotNetVersion' = $DotNetVersion
    'OracleClientVersion' = $OracleClientVersion
    'IE_Version' = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer' -Name 'Version').Version
    'NotepadPlusPlus' = $NotepadPlusPlus.DisplayVersion
  }

  if ([Environment]::OSVersion.Version.Major -ge '10') {
    $Major = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentMajorVersionNumber).CurrentMajorVersionNumber
    $Minor = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentMinorVersionNumber).CurrentMinorVersionNumber
    $Release = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' ReleaseId).ReleaseId
    $Build = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild).CurrentBuild
    $Revision = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' UBR).UBR
    $Version = "$($Major).$($Minor).$($Release).$($Build).$($Revision)"
  } Else {
    $Version = $Win32_OperatingSystem.Version
  }

  $OSInfo = [pscustomobject] @{
    'OSName' =  $Win32_OperatingSystem.Caption
    'Version' =   $Version
    'Domain' = $Win32_ComputerSystem.Domain
    'LicenseStatus' = switch ($LicenseStatus) {
      0 {'Unlicensed'}
      1 {'Licensed'}
      2 {'Out-of-Box Grace Period'}
      3 {'Out-of-Tolerance Grace Period'}
      4 {'Non Genuine Grace Period'}
      5 {'Notification'}
      6 {'Extended Grace'}
      default {'Unknown'}
    }
    'InstallDate' =  [Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.InstallDate)
    'LastBootUpTime' = [Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.LastBootUpTime)
    'AutomaticManagedPagefile' = $Win32_ComputerSystem.AutomaticManagedPagefile
    'OSDImageRelease' = try {(Get-ItemProperty -Path 'HKLM:\System\FSAG\OSD' -Name 'ReleaseVersion' -ErrorAction SilentlyContinue).ReleaseVersion.Trim()} Catch {''} ;
    'OSDImageVersion' = try {(Get-ItemProperty -Path 'HKLM:\System\FSAG\OSD' -Name 'OSDImageVersion' -ErrorAction SilentlyContinue).OSDImageVersion.Trim()} Catch {''} ;
    'OSDTaskSequenceName' = try {(Get-ItemProperty -Path 'HKLM:\System\FSAG\OSD' -Name 'TaskSequenceName' -ErrorAction SilentlyContinue).TaskSequenceName.Trim()} Catch {''}
  }

  $UAC = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system' -Name 'EnableLua' -EA 0).EnableLUA
  $TLS = (Get-Itemproperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -EA 0).Enabled
  $HotFixes = Get-HotFix

  # $BaseLineName = 'FSAG-SRV-CCB-MON-SecuritySettings-OS-WinSrv-Windows Server*-MASTER'
  # $Baseline =  Get-CimInstance -Namespace 'root\ccm\dcm' -Class 'SMS_DesiredConfiguration' | Where-Object {$_.DisplayName -like $BaseLineName}
  # [xml]$ComplianceDetails = $Baseline.ComplianceDetails
  # $CIComplianceState = @()
  # foreach ($ConfigurationItemReport in $ComplianceDetails.ConfigurationItemReport.ReferencedConfigurationItems.ConfigurationItemReport) {
  #   $CIComplianceState += New-Object PSObject -Property ([ordered]@{
  #       Description=[int]$($ConfigurationItemReport.CIProperties.Description.'#text')
  #       Name =  $ConfigurationItemReport.CIProperties.Name.'#text'
  #       Version =  $ConfigurationItemReport.Version
  #       CISeverity =  $ConfigurationItemReport.CISeverity
  #       Type =  $ConfigurationItemReport.Type
  #       CIComplianceState = $ConfigurationItemReport.CIComplianceState
  #   })
  # }
  # $NonCompliantSettingRules = ($CIComplianceState | Where-Object {$_.CIComplianceState -match 'NonCompliant'} | Select-Object -ExpandProperty Description | Sort-Object) -join ';'
  $SecurityInfos = [pscustomobject] @{
    'FirewallPrivate' = ((netsh.exe advfirewall show private | Select-String 'State') -split ' ')[-1]
    'FirewallPublic'  = ((netsh.exe advfirewall show public  | Select-String 'State') -split ' ')[-1]
    'FirewallDomain' = ((netsh.exe advfirewall show domain  | Select-String 'State') -split ' ')[-1]
    'UAC' = switch ($UAC) {
      0 {$False}
      1 {$true}
      $Null {'unknown'}
    }
    'NLA' = if ($NLA -eq '1') {$True} Else {$false}
    'UpdateCount' = ($HotFixes | Where-Object {$_.Description -like 'Update'}).Count
    'SecurityUpdateCount' = ($HotFixes | Where-Object {$_.Description -like 'Security Update'}).Count
    'HotfixCount' = ($HotFixes | Where-Object {$_.Description -like 'Hotfix'}).Count
    'TLS1.0_Disabled' = if ($TLS -eq 0) {$True} Else {$false}
    'SysLog' = (Get-Service 'syslog-ng Agent' -ErrorAction SilentlyContinue).Status
    'SysMon64' = (Get-Service 'Sysmon64' -ErrorAction SilentlyContinue).Status
    'NonCompliantSettingRules' = "" #$NonCompliantSettingRules
  }

  $LogicalDisk = Get-WMIObject -class Win32_LogicalDisk -Filter 'DriveType = 3'
  $Disks = @()
  foreach ($Disk in $LogicalDisk) {
    $BlockSize = Get-WmiObject -Query "SELECT BlockSize FROM Win32_Volume WHERE DriveLetter = '$($Disk.Name)'"
    $Disks += New-Object PSObject -Property @{
      Name = $Disk.Name
      VolumeName = $Disk.VolumeName
      SizeGB = [math]::Round(($Disk.Size / 1GB))
      FreeSpaceMB = [math]::Round(($Disk.FreeSpace / 1MB))
      FileSystem = $Disk.FileSystem
      BlockSizeKB = $BlockSize.BlockSize / 1kb
    }
  }

  $NLB_ClusterSettings = Get-WmiObject -Namespace 'root\MicrosoftNLB' -Query 'SELECT * FROM MicrosoftNLB_ClusterSetting' -ErrorAction SilentlyContinue
  $NLB_NodeSettings = Get-WmiObject -Namespace 'root\MicrosoftNLB' -Query 'SELECT * FROM MicrosoftNLB_NodeSetting' -ErrorAction SilentlyContinue

  if ($NLB_ClusterSettings) {
    $NLB_ClusterSetting = New-Object PSObject -Property @{
      Name = $NLB_ClusterSettings.ClusterName
      IPAddress = $NLB_ClusterSettings.ClusterIPAddress
      NetworkMask = $NLB_ClusterSettings.ClusterNetworkMask
      IPToMulticastIP = $NLB_ClusterSettings.ClusterIPToMulticastIP
      MACAddress = $NLB_ClusterSettings.ClusterMACAddress.Replace('-',':')
    }
  }
  if ($NLB_NodeSettings) {
    $NLB_NodeSetting = New-Object PSObject -Property @{
      Name = $NLB_NodeSettings.Name
      IPAddress = $NLB_NodeSettings.DedicatedIPAddress
      NetworkMask = $NLB_NodeSettings.DedicatedNetworkMask
    }
  }

  $NetAdapterConfigs = @()
  #  $NetworkAdapterConfigurations = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE
  $NetworkAdapterConfigurations = Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = 'True' AND ServiceName = 'netvsc'"
  foreach ($NetworkAdapterConfiguration in $NetworkAdapterConfigurations) {
    $MaskV4 = $NetworkAdapterConfiguration | Select-Object -ExpandProperty IPSubnet | Where-Object {$_ -match $IPv4Match}
    $NetName = (Get-WmiObject -Class Win32_NetworkAdapter -Filter InterfaceIndex=$($NetworkAdapterConfiguration.InterfaceIndex)).NetConnectionID
    $NetAdapterConfigs += New-Object PSObject -Property @{
      Name = $NetName
      DHCPEnabled = $NetworkAdapterConfiguration.DHCPEnabled
      IPv4  = ($NetworkAdapterConfiguration | Select-Object -ExpandProperty IPAddress | Where-Object {$_ -match $IPv4Match -and $_ -ne $NLB_ClusterSetting.IPAddress}) -join ','
      MaskV4 = if ($MaskV4 -is [array]) {$MaskV4[0]} Else {$MaskV4}
      GatewayV4  = $($NetworkAdapterConfiguration.DefaultIPGateway)
      Description = $NetworkAdapterConfiguration.Description
      InterfaceIndex = $NetworkAdapterConfiguration.InterfaceIndex
      DnsV4 = if ($NetworkAdapterConfiguration.DNSServerSearchOrder) {($NetworkAdapterConfiguration | Select-Object -ExpandProperty DNSServerSearchOrder) -join ','} Else {''}
      DomainDNSRegistrationEnabled = $($NetworkAdapterConfiguration.DomainDNSRegistrationEnabled)
      FullDNSRegistrationEnabled = $($NetworkAdapterConfiguration.FullDNSRegistrationEnabled)
      MACAddress = $($NetworkAdapterConfiguration.MACAddress)
      DNSDomainSuffixSearchOrder = if ($NetworkAdapterConfiguration.DNSDomainSuffixSearchOrder) {($NetworkAdapterConfiguration.DNSDomainSuffixSearchOrder) -join ','} Else {''}
    }
  }

  if (Get-Command -Name 'Get-Cluster' -ErrorAction SilentlyContinue -WarningAction Ignore) {
    if (Get-Cluster -ErrorAction SilentlyContinue -WarningAction Ignore) {
      if (Get-ClusterResource -Name 'File Share Witness' -ErrorAction SilentlyContinue -WarningAction Ignore) {
        $FileShareWitness = Get-clusterresource -Name 'File Share Witness' | Get-ClusterParameter -Name 'SharePath' | Select-Object -ExpandProperty Value
      } Else {
        $FileShareWitness = ''
      }
      $Cluster = New-Object PSObject -Property ([ordered] @{
          Name =  (Get-Cluster).Name
          Nodes = (Get-Cluster | Get-ClusterNode).Name -join ','
          Group = (Get-ClusterGroup | Where-Object {$_.IsCoreGroup -eq $false}).Name -join ','
          Ipv4Addresses = (Get-ClusterNetworkInterface).Ipv4Addresses -join ','
          QuorumResource = (Get-ClusterQuorum).QuorumResource.Name
          QuorumState = (Get-ClusterQuorum).QuorumResource.State
          QuorumType = (Get-ClusterQuorum).QuorumType
          FileShareWitness = $FileShareWitness
      })
    }
  }

  $VMProperties = [pscustomobject]@{
    'Name' = $env:COMPUTERNAME
    'DateTime' = $DateTime
    'DomainTime' = $DomainTime
    'ScanTime' = Get-Date
    'OSInfo' = $OSInfo
    'Disk' = $Disks
    'AdminGroupMembers' = $LocalAdminGroupMembers
    'SecurityInfos' = $SecurityInfos
    'Network' = $NetAdapterConfigs
    'IBA' = $IBA
    'PowerShell' = $PowerShell
    'Software' = $Software
    'SCCMAgent' = $SCCMAgent
    'SCOMAgent' = $SCOMAgent
    'VirenScanner' = $VirenScanner
  }
  if ($NLB_ClusterSetting) {$VMProperties | Add-Member -MemberType NoteProperty -Name 'NLB_ClusterSetting' -Value $NLB_ClusterSetting }
  if ($NLB_NodeSetting) {$VMProperties | Add-Member -MemberType NoteProperty -Name 'NLB_NodeSetting' -Value $NLB_NodeSetting }
  if ($Cluster) {$VMProperties | Add-Member -MemberType NoteProperty -Name 'Cluster' -Value $Cluster}

  $listOfVMs += $VMProperties
  $listOfVMs
}
$sb_GetInstalledSoftware = {
  $SoftwareList = @()
  $Softwares = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName}
  if (Test-Path 'HKLM:\Software\Wow6432Node') {
    $Softwares += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName}
  }
  foreach ($Software in $Softwares) {
    $SWInfo = New-Object psobject -Property @{
      'DisplayName' = $Software.DisplayName
      'DisplayVersion' = $Software.DisplayVersion
      'Publisher' = $Software.Publisher
      'InstallDate' = $Software.InstallDate
      'InstallSource' = $Software.InstallSource
      'HelpLink' = $Software.HelpLink
      'UninstallString' = $Software.UninstallString
      'Path' = $Software.PSPath -replace '^.*::HKEY_LOCAL_MACHINE','HKLM:'
    }
    $SoftwareList += $SWInfo
  }
  $SoftwareList | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate,InstallSource,UninstallString,Path
}
$sb_GetLocalUserMemberShips = {
  $LocalUserMemberShips = @()
  $adsi = [ADSI]"WinNT://."
  $Groups = $adsi.Children | Where-Object {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
  }
  $LocalUsers = (Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True' AND Disabled='False'")  #| ft -AutoSize
  foreach ($LocalUser in $LocalUsers) {
    $Group = $Groups | Where-Object {$_.UserName -match $($LocalUser.Name)} | Select-Object -ExpandProperty Groups
    if ($Group -ne 'Users' -and $Group -ne '') {
      $Group = $Group.Replace("Users",'').TrimEnd(';').Replace(';',',')
      if ($Group -is [array]) {$Group = $Group[0]}
      $LocalUserMemberShips += New-Object PSObject -Property ([ordered]@{LocalUser=$LocalUser.Name;GroupMembers=$Group})
    }

  }
  $LocalUserMemberShips
}
$sb_GetInstalledUpdates = {
  <#
      .DESCRIPTION
      Get Installed Updates

      .PARAMETER
      optonal Updates since in Days or DateTime

      .EXAMPLE
      $sb_GetInstalledUpdates
      $sb_GetInstalledUpdates.Invoke()
      $sb_GetInstalledUpdates.Invoke(-10)

      .EXAMPLE
      $VMInfo = Get-IOPI_HyperV_VM -VMName 'FSDIBSY12651' -ComputerName $IOPI_All_HyperVServerNames
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_GetInstalledUpdates | Select-Object PSComputerName,Description,HotFixID,InstalledBy,InstalledOn | Format-Table -AutoSize
      etsn -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential)
      # Input Date Year-Month-Day
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_GetInstalledUpdates -ArgumentList ([DateTime] '2015-10-06 00:00:00') | Select-Object PSComputerName,Description,HotFixID,InstalledBy,InstalledOn | Format-Table -AutoSize
  #>
  $since = $Args[0]   #optional since DateTime

  $UpdatesInstalled = Get-HotFix | Select-Object Description,HotFixID,InstalledBy, @{l="InstalledOn";e={[DateTime]::Parse($_.psbase.properties["installedon"].value,$([Globalization.CultureInfo]::GetCultureInfo("en-US"))).ToShortDateString()}}
  if ($since -is [DateTime]) { # Input in DateTime
    return $UpdatesInstalled |  Where-Object {($_.InstalledOn -ge $since)} | Sort-Object -Property InstalledOn -Descending
  }
  return $UpdatesInstalled | Sort-Object -Property InstalledOn -Descending
}
$sb_CurrentDateTime = {
  <#
      .DESCRIPTION
      Get Current DateTime Difference

      .EXAMPLE
      Invoke-Command -ComputerName $IOPI_All_HyperVServerNames -ArgumentList (Get-Date) -ScriptBlock $sb_CurrentDateTime | ft -AutoSize
  #>
  $SourceDateTime = $Args[0]
  $SourceDateTimeString = (($SourceDateTime).ToShortDateString() + ' ' + ($SourceDateTime).ToShortTimeString() + ':' + ($SourceDateTime).Second + ',' + $SourceDateTime.Millisecond)
  $TimeSource = w32tm /query /source
  $Difference = '{0:F1}' -f (Get-Date).Subtract($SourceDateTime).TotalSeconds
  New-Object PSObject -Property ([ordered]@{
      TimeSource=$TimeSource;
      SourceDateTime=  $SourceDateTimeString;
      LocalDateTime=$(Get-Date -format 'dd.mm.yyyy HH:mm:ss.fff');
      TimeDiffSec=$Difference
  })
}
$sb_SCCM_GetClientVersion = {
  $ClientVersion =  (Get-WMIObject -namespace root\ccm -class sms_client -ErrorAction SilentlyContinue).ClientVersion
  Return New-Object PSObject -Property ([ordered]@{SCCMClientVersion=$ClientVersion})
}
$sb_SCCM_GetUpdatesToInstall = {
  <#
      .DESCRIPTION
      Get SCCM Updates

      .EXAMPLE
      $VMInfos | Invoke-IOPI_Parallel -ScriptBlock {
      $VM = $_
      Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
      Invoke-Command -ComputerName $($VM.FQDN) -Credential $($VM.WinRMCredential) -ScriptBlock $sb_SCCM_GetUpdates
      } | Where-Object UpdatesToInstall -gt 0 | Select-Object ComputerName,UpdatesToInstall,PendingReboot
  #>
  function Test-PendingReboot {
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    try {
      $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
      $status = $util.DetermineIfRebootPending()
      if(($status -ne $null) -and $status.RebootPending){
        return $true
      }
    }catch{}
    return $false
  }

  $SoftwareUpdates = Get-CimInstance -Query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK' -ErrorVariable WMISCCMError -ErrorAction SilentlyContinue
  $SCCMClientVersion = (Get-WMIObject -namespace root\ccm -class sms_client -ErrorAction SilentlyContinue).ClientVersion
  if (!$WMISCCMError) {
    if ($SoftwareUpdates) {
      if ($SoftwareUpdates.Count) {$UpdateCount = $($SoftwareUpdates.Count)} Else {$UpdateCount=1}
      return New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;UpdatesToInstall=$UpdateCount;PendingReboot=Test-PendingReboot;SCCMClientVersion=$SCCMClientVersion})
    } Else {
      return New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;UpdatesToInstall=0;PendingReboot=Test-PendingReboot;SCCMClientVersion=$SCCMClientVersion})
    }
  } Else {
    return New-Object PSObject -Property ([ordered]@{ComputerName=$ENV:COMPUTERNAME;UpdatesToInstall=$WMISCCMError;PendingReboot=Test-PendingReboot;SCCMClientVersion=$SCCMClientVersion})
  }
}
$sb_SCCM_TriggerDSCBaseLine = {
  <#
      .DESCRIPTION
      Trigger SCCM BaseLine

      .EXAMPLE
      $VMInfos = Get-IOPI_HyperV_VM -VMName 'FS*' -ComputerName $IOPI_INT_HyperVServerNames | Where-Object {$_.State -eq 'Running'}
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerDSCBaseLine -ArgumentList 'FSAG-SRV-CCB-REM-SecuritySettings-OS-WinSrv-Windows Server *-MASTER'
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerDSCBaseLine -ArgumentList 'FSAG-SRV-CCB-MON-SecuritySettings-OS-WinSrv-Windows Server *-Master'

      .EXAMPLE
      $VMInfos = Get-IOPI_HyperV_VM -VMName 'FS*' -ComputerName $IOPI_INT_HyperVServerNames | Where-Object {$_.State -eq 'Running' -and $_.FQDN -notmatch 'd-fs01'}
      $VMInfos | Invoke-IOPI_Parallel -ScriptBlock {
      Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
      $VMInfo = $_
      #Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerDSCBaseLine -ArgumentList 'FSAG-SRV-CCB-REM-SecuritySettings-OS-WinSrv-Windows Server *-MASTER'
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerDSCBaseLine -ArgumentList 'FSAG-SRV-CCB-MON-SecuritySettings-OS-WinSrv-Windows Server *-Master'
      }
  #>

  $BaseLineName = $Args[0]   # $BaselineName = 'FSAG-SRV-CCB-REM-SecuritySettings-OS-WinSrv-Windows Server *-MASTER'
  if ([environment]::OSVersion.Version.ToString() -match '6.3|10.0') {
    $Baseline =  Get-CimInstance -Namespace 'root\ccm\dcm' -Class 'SMS_DesiredConfiguration' | Where-Object {$_.DisplayName -like $BaseLineName}
  } Else {
    $Baseline =  Get-WmiObject -Namespace 'root\ccm\dcm' -Class 'SMS_DesiredConfiguration' | Where-Object {$_.DisplayName -like $BaseLineName}
  }
  $Baseline | ForEach-Object {($null = [wmiclass]"\\.\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version)} | Out-Null
  if ($Baseline.DisplayName) {
    Write-Host "$ENV:COMPUTERNAME : BaseLine '$($Baseline.DisplayName)' triggered"
  } Else {
    Write-Host "$ENV:COMPUTERNAME : BaseLine '$BaseLineName' not triggered" -ForegroundColor Red
  }
}
$sb_SCCM_GetDSCBaseLineStatus = {
  <#
      .DESCRIPTION
      Get SCCM DSC BaseLine Status

      .EXAMPLE
      Invoke-Command -ComputerName 'FSDEBSNE0255.mgmt.fsadm.vwfs-ad' -ScriptBlock $sb_SCCM_GetDSCBaseLineStatus -ArgumentList 'FSAG-SRV-CCB-REM-SecuritySettings-OS-WinSrv-Windows Server *-MASTER' | ft -a
      Invoke-Command -ComputerName 'FSDEBSNE0255.mgmt.fsadm.vwfs-ad' -ScriptBlock $sb_SCCM_GetDSCBaseLineStatus -ArgumentList 'FSAG-SRV-CCB-MON-SecuritySettings-OS-WinSrv-Windows Server *-Master' | ft -a
  #>
  $BaseLineName = $Args[0]
  $Baseline =  Get-CimInstance -Namespace 'root\ccm\dcm' -Class 'SMS_DesiredConfiguration' | Where-Object {$_.DisplayName -like $BaseLineName}
  [xml]$ComplianceDetails = [xml]$Baseline.ComplianceDetails
  foreach ($ConfigurationItemReport in $ComplianceDetails.ConfigurationItemReport.ReferencedConfigurationItems.ConfigurationItemReport) {
    New-Object PSObject -Property ([ordered]@{
        Description=$ConfigurationItemReport.CIProperties.Description.'#text'
        Name =  $ConfigurationItemReport.CIProperties.Name.'#text'
        Version =  $ConfigurationItemReport.Version
        CISeverity =  $ConfigurationItemReport.CISeverity
        Type =  $ConfigurationItemReport.Type
        CIComplianceState = $ConfigurationItemReport.CIComplianceState
    })
  }
}
$sb_SCCM_TriggerInstallUpdates = {
  <#
      .DESCRIPTION
      Trigger SCCM Updates without Reboot

      .EXAMPLE
      $VMInfos | Invoke-IOPI_Parallel -Throttle 10 -ScriptBlock {
      $VM = $_
      Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
      Invoke-Command -ComputerName $($VM.FQDN) -Credential $($VM.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerInstallUpdates
      Start-Sleep -Seconds 300
      }
  #>
  [string[]] $KB_ToExclude = $Args[0] -split ';'
  [Management.ManagementObject[]] $SCCMUpdates = Get-WMIObject -Query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK'
  if ($KB_ToExclude) {$SCCMUpdates | Foreach-Object {foreach ($KB in $KB_ToExclude) {$SCCMUpdates = $SCCMUpdates | Where-Object {$_.Name -notmatch $KB}}} }
  if ($SCCMUpdates) {
    Write-Host "$($Env:ComputerName): Install Updates $($SCCMUpdates.Name)"
    $Null = ([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates($SCCMUpdates)
  } Else {
    Write-Host "$($Env:ComputerName): Nothing to Install"
  }

}
$sb_SCCM_GetDSCBaseLines = {
  return Get-CimInstance -Namespace 'root\ccm\dcm' -Class 'SMS_DesiredConfiguration' | Select-Object DisplayName,LastEvalTime,Status,Version,LastComplianceStatus,IsMachineTarget
}
$sb_SCCM_TriggerInstallApplication = {
  <#
      .DESCRIPTION
      Trigger SCCM Application Installation

      .EXAMPLE
      Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI' -Force
      $VMInfo = Get-IOPI_HyperV_VM -VMName 'FSEIBADE0002' -ComputerName $IOPI_All_HyperVServerNames
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerInstallApplication -ArgumentList 'McAfee Agent*'
      Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerInstallApplication -ArgumentList 'IBM Security QRadar*'
  #>
  $ApplicationName = $Args[0]
  $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" | Where-Object {$_.Name -like $ApplicationName})  #Where-Object {$_.Publisher -match $Using:AppName})
  if ($Application) {
    if ($Application.InstallState -eq 'Installed') {
      Write-Host "$ENV:COMPUTERNAME : '$($Application.FullName)' allready installed"
    } Else {
      Write-Host "$ENV:COMPUTERNAME : Installing '$($Application.FullName)'"
      $Null = ([wmiclass]'ROOT\ccm\ClientSdk:CCM_Application').Install($Application.Id, $Application.Revision, $True, 0, 'Normal', $False)
    }
  } Else {
    Write-Host "$ENV:COMPUTERNAME : Application '$ApplicationName' not found!"
  }
}
$sb_SCCM_GetApplications = {
  Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" | Select-object  FullName,InstallState,Publisher,LastInstallTime,Revision,IsMachineTarget
}
$sb_SCCM_ClearClientCache = {
  $CMObject = New-Object -ComObject "UIResource.UIResourceMgr" -ErrorAction STOP
  $CMCacheObject = $CMObject.GetCacheInfo()
  foreach($CItem in $CMCacheObject.GetCacheElements()){
    $CMCacheObject.DeleteCacheElement($CItem.CacheElementId)
  }
}
$sb_InstallPowerShellCore = {
  <#
      .DESCRIPTION
      Install PowerShell Core

      .EXAMPLE
      'FSDEBSY44418' | ForEach-Object {$sb_InstallPowerShellCore.Invoke($_)}
      'FSDEBSY04433','FSDEBSY04434','FSDEBSY44191','FSDEBSY44192','FSDEBSY04491','FSDEBSY04492' | ForEach-Object {$sb_InstallPowerShellCore.Invoke($_)}
  #>
  $VMName = $Args[0]
  Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
  $MSIFileName = "\\fsdebsv00130\Sourcen\IH-IOPI\Install\Microsoft\PowerShell\Core6.x\PowerShell-6.2.0-win-x64.msi"
  $MSIFileNameShort = Split-Path -Path $MSIFileName -Leaf
  $VMInfo = Get-IOPI_HyperV_VM -VMName $VMName -ComputerName $IOPI_All_HyperVServerNames
  $Session = New-PSSession -ComputerName  $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential)
  Copy-Item -ToSession $Session -Path $MSIFileName -Destination 'C:\Temp' -Recurse -Force
  Invoke-Command -Session $Session -ScriptBlock {
    Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList "/I C:\Temp\$Using:MSIFileNameShort /quiet" -Wait
    Remove-Item -Path "C:\Temp\$MSIFileNameShort" -Recurse -Force
    $Null = New-Item -Path 'C:\Temp' -ItemType Directory
  }
  $Session | Remove-PSSession
}
$sb_InstallOpenSSH= {
  <#
      .DESCRIPTION
      Install Microsoft OpenSHH

      .EXAMPLE

      .LINK
      https://4sysops.com/archives/enable-powershell-core-6-remoting-with-ssh-transport/
  #>

  $VMName = $Args[0]
  $VMName = 'FSDEBSY04492'
  $OpenSSHFolder = '\\fsdebsv00130\Sourcen\IH-IOPI\Install\Microsoft\OpenSSH\OpenSSH7.7.2.0'
  Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'

  $VMInfo = Get-IOPI_HyperV_VM -VMName $VMName -ComputerName $IOPI_All_HyperVServerNames
  $Session = New-PSSession -ComputerName  $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential)
  Copy-Item -ToSession $Session -Path $OpenSSHFolder -Destination 'C:\Program Files\OpenSSH' -Recurse -Force
  Invoke-Command -Session $Session -ScriptBlock {
    Set-Location -Path "C:\Program Files\OpenSSH"
    .\install-sshd.ps1
    Start-Service sshd
    Set-Service sshd -StartupType Automatic
    $env:Path="$env:Path;C:\Program Files\OpenSSH\"
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $env:Path
  }
  Copy-Item -ToSession $Session -Path "\\fsdebsv00130\Sourcen\IH-IOPI\Install\Microsoft\OpenSSH\sshd_config" -Destination 'C:\ProgramData\ssh'
  Invoke-Command -Session $Session -ScriptBlock {
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c mklink /D c:\pwsh "C:\Program Files\PowerShell\6"' -Wait
    Restart-Service sshd
  }

  Invoke-Command -Session $Session -ScriptBlock {
    $Null = New-NetFirewallRule -DisplayName 'SSH Inbound' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22
    Restart-Computer -Force
  }
  $Session | Remove-PSSession
}
$sb_InstallPSModulePester = {
  $VMName = $Args[0]
  Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
  $VMInfo = Get-IOPI_HyperV_VM -VMName $VMName -ComputerName $IOPI_All_HyperVServerNames
  if ($VMInfo) {
    $Session = New-PSSession -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential)
    $PesterPath = Invoke-Command -Session $Session -ScriptBlock {
      if (Test-Path -Path "$PSHome\Modules\Pester") {Remove-Item -Path "$PSHome\Modules\Pester" -Recurse -Force}
      if (Test-Path -Path 'C:\Program Files\WindowsPowerShell\Modules\Pester') {
        Remove-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\Pester' -Recurse -Force
        return 'C:\Program Files\WindowsPowerShell\Modules\Pester'
      } else {
        return "$PSHome\Modules\Pester"
      }
    }
    Copy-Item -ToSession $Session -Path '\\fsdebsv00130\Sourcen\IH-IOPI\Install\Microsoft\PowerShell\Modules\Pester' -Destination $PesterPath -Recurse -Force
    Remove-PSSession -Session $Session
  }
}
$sb_InstallPSModuleLogging = {
  $VMName = $Args[0]
  Import-Module -Name '\\fsdebsv00130\Sourcen\IH-IOPI\PowerShell\Modules\IH-IOPI'
  $VMInfo = Get-IOPI_HyperV_VM -VMName $VMName -ComputerName $IOPI_All_HyperVServerNames
  if ($VMInfo) {
    $Session = New-PSSession -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential)
    $PowerShellLoggingPath = Invoke-Command -Session $Session -ScriptBlock {
      if (Test-Path -Path "$PSHome\Modules\PowerShellLogging") {Remove-Item -Path "$PSHome\Modules\PowerShellLogging" -Recurse -Force}
      if (Test-Path -Path 'C:\Program Files\WindowsPowerShell\Modules\PowerShellLogging') {
        Remove-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\PowerShellLogging' -Recurse -Force
        return 'C:\Program Files\WindowsPowerShell\Modules\PowerShellLogging'
      } else {
        return "$PSHome\Modules\PowerShellLogging"
      }
    }
    Copy-Item -ToSession $Session -Path '\\fsdebsv00130\Sourcen\IH-IOPI\Install\Microsoft\PowerShell\Modules\PowerShellLogging' -Destination $PowerShellLoggingPath -Recurse -Force
    Remove-PSSession -Session $Session
  }
}
$sb_GetHyperV_SystemInfo = {
  $Win32_OperatingSystem = Get-WMIObject -Query 'SELECT * FROM Win32_OperatingSystem'
  $Win32_ComputerSystem = Get-WMIObject -Query 'SELECT * FROM Win32_ComputerSystem'
  $Win32_Processor = Get-WmiObject -class Win32_Processor
  $Win32_ComputerSystemProduct = Get-WMIObject Win32_ComputerSystemProduct
  if ([Environment]::OSVersion.Version.Major -ge '10') {
    $Major = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentMajorVersionNumber).CurrentMajorVersionNumber
    $Minor = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentMinorVersionNumber).CurrentMinorVersionNumber
    $Release = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' ReleaseId).ReleaseId
    $Build = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild).CurrentBuild
    $Revision = $(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' UBR).UBR
    $Version = "$($Major).$($Minor).$($Release).$($Build).$($Revision)"
  } Else {
    $Version = $Win32_OperatingSystem.Version
  }
  $Domain = $Win32_ComputerSystem.Domain
  function Test-RebootPending {
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    try {
      $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
      $status = $util.DetermineIfRebootPending()
      if(($status -ne $null) -and $status.RebootPending){
        return $true
      }
    }catch{}

    return $false
  }

  $Release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name 'Release' -ErrorAction SilentlyContinue).Release
  $DotNetVersion = ''
  switch ($Release) {  #https://docs.microsoft.com/de-de/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    {$_ -ge 461808}   {$DotNetVersion='4.7.2'; break}
    {$_ -ge 461308}   {$DotNetVersion='4.7.1'; break}
    {$_ -ge 460798}   {$DotNetVersion='4.7'; break}
    {$_ -ge 394802}   {$DotNetVersion='4.6.2'; break}
    {$_ -ge 394254}   {$DotNetVersion='4.6.1'; break}
    {$_ -ge 393295}   {$DotNetVersion='4.6'; break}
    {$_ -ge 379893}   {$DotNetVersion='4.5.2'; break}
    {$_ -ge 378675}   {$DotNetVersion='4.5.1'; break}
    {$_ -ge 378389}   {$DotNetVersion='4.5'; break}
    default {$DotNetVersion='unknown .NET Framework Version'; break}
  }

  $VMHost = Hyper-V\Get-VMHost
  New-Object PSObject -Property ([ordered]@{
      HostName=$ENV:COMPUTERNAME
      FQDN=($ENV:COMPUTERNAME + '.' + $Domain)
      #  Cluster = (Get-Cluster -ErrorAction SilentlyContinue).Name  #not work over PS Remoting
      OSName=$Win32_OperatingSystem.Caption
      OSVersion=$Version
      PSVersion = $PSVersionTable.PSVersion.ToString()
      DotNetVersion = $DotNetVersion
      Model = $Win32_ComputerSystem.Model
      NumberOfProcessorSockets = ($Win32_Processor).NumberOfCores.Count
      NumberOfProcessorCores = (($Win32_Processor).NumberOfCores | Measure-Object -Sum).Sum
      NumberOfLogicalProcessors = (($Win32_Processor).NumberOfLogicalProcessors | Measure-Object -Sum).Sum
      PROCESSOR_ARCHITECTURE = $ENV:PROCESSOR_ARCHITECTURE
      RegisteredOwner= (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOwner
      RegisteredOrganization=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOrganization
      LocalDisks = Get-WmiObject -Query "SELECT * FROM  Win32_LogicalDisk WHERE DriveType = '3'" | Select-Object DeviceID,@{Name="Label";e={$_.VolumeName}}, @{Name="DiskSizeGB";e={($_.Size /1GB).ToString('##.#')}},@{Name="FreeDiskSpaceGB";e={($_.FreeSpace /1GB).ToString('##.#')}}
      InstallDate=[Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.InstallDate)
      LastBootUpTime=[Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.LastBootUpTime)
      TotalPhysicalMemoryGB=($Win32_ComputerSystem.TotalPhysicalMemory / 1GB).ToString('##.#')
      FreePhysicalMemoryGB= ($Win32_OperatingSystem | Select-Object @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,1)}}).FreeGB
      SerialNumber = $Win32_ComputerSystemProduct.IdentifyingNumber.Trim()
      Domain=$Domain
      #LogonServer= try {(nltest.exe /sc_query:$Domain)[1]} catch {''};
      SystemLocale= if (Get-Command Get-WinSystemLocale -ErrorAction SilentlyContinue) {(Get-WinSystemLocale).Name} Else {''}
      TimeZone= (Get-WmiObject -Class win32_timezone).Caption
      LocalTime= Get-Date
      UpdateCount = (Get-HotFix).Count
      HypervisorPresent = $Win32_ComputerSystem.HypervisorPresent
      RebootPending = Test-RebootPending
      MacAddressMinimum = $($VMHost.MacAddressMinimum)
      MacAddressMaximum = $($VMHost.MacAddressMaximum)
      VirtualMachinePath = $($VMHost.VirtualMachinePath)
      VirtualHardDiskPath = $($VMHost.VirtualHardDiskPath)
      EnableEnhancedSessionMode = $($VMHost.EnableEnhancedSessionMode)
      VirtualMachineMigrationAuthenticationType = $($VMHost.VirtualMachineMigrationAuthenticationType)
      VirtualMachineMigrationPerformanceOption = $($VMHost.VirtualMachineMigrationPerformanceOption)
      MaximumStorageMigrations = $($VMHost.MaximumStorageMigrations)
      MaximumVirtualMachineMigrations = $($VMHost.MaximumVirtualMachineMigrations)
      NumaSpanningEnabled = $($VMHost.NumaSpanningEnabled)
      McAfeeExist = if ((Get-Service -Name @('masvc','macmnsvc') -ErrorAction SilentlyContinue).Count -eq 2) {$true} else {$false}
  })
}
$sb_GetHyperV_Roles = {
  $ExpectedRoles2012R2 = @(
    'Failover-Clustering',
    'FileAndStorage-Services',
    'File-Services',
    'FS-FileServer',
    'Hyper-V',
    'Hyper-V-PowerShell',
    'Hyper-V-Tools',
    'Multipath-IO',
    'NET-Framework-45-Core',
    'NET-Framework-45-Features',
    'NET-WCF-Services45',
    'NET-WCF-TCP-PortSharing45',
    'PowerShell',
    'PowerShell-ISE',
    'PowerShellRoot',
    'RDC',
    'RSAT',
    'RSAT-Clustering',
    'RSAT-Clustering-AutomationServer',
    'RSAT-Clustering-CmdInterface',
    'RSAT-Clustering-Mgmt',
    'RSAT-Clustering-PowerShell',
    'RSAT-Feature-Tools',
    'RSAT-Hyper-V-Tools',
    'RSAT-Role-Tools',
    'Server-Gui-Mgmt-Infra',
    'Server-Gui-Shell',
    'User-Interfaces-Infra',
    'Storage-Services',
    'WoW64-Support'
  )
  $ExpectedRoles2016 = $ExpectedRoles2012R2 | Where-Object {$_ -notin @('Server-Gui-Mgmt-Infra','Server-Gui-Shell','User-Interfaces-Infra')}

  $InstalledRoles = Get-WindowsFeature | Where-Object Installed | Select-Object -ExpandProperty Name | Sort-Object
  if ([Environment]::OSVersion.Version.Major -eq '10') {
    $ToManyRoles = Compare-Object -ReferenceObject $ExpectedRoles2016 -DifferenceObject $InstalledRoles | Where-Object SideIndicator -eq '=>' | Select-Object -ExpandProperty InputObject
    $MissingRoles = Compare-Object -ReferenceObject $ExpectedRoles2016 -DifferenceObject $InstalledRoles | Where-Object SideIndicator -eq '<=' | Select-Object -ExpandProperty InputObject
  }
  if ([Environment]::OSVersion.Version.Major -eq '6') {
    $ToManyRoles = Compare-Object -ReferenceObject $ExpectedRoles2012R2 -DifferenceObject $InstalledRoles | Where-Object SideIndicator -eq '=>' | Select-Object -ExpandProperty InputObject
    $MissingRoles = Compare-Object -ReferenceObject $ExpectedRoles2012R2 -DifferenceObject $InstalledRoles | Where-Object SideIndicator -eq '<=' | Select-Object -ExpandProperty InputObject
  }
  $ToManyRoles = $ToManyRoles | Where-Object {$_ -NotMatch 'File-Services|FS-FileServer'}
  $MissingRoles = $MissingRoles | Where-Object {$_ -NotMatch 'File-Services|FS-FileServer'}
  New-Object PSObject -Property ([ordered]@{
      InstalledRoles = $InstalledRoles
      InstalledRolesCount = $InstalledRoles.Count
      ToManyRoles = $ToManyRoles
      ToManyRolesCount = $ToManyRoles.Count
      MissingRoles = $MissingRoles
      MissingRolesCount = $MissingRoles.Count
  })
}
$sb_GetHyperV_NetAdapter = {
  $AdapterInfos = Get-NetAdapter -Name @('VMs*','*MGMT*') | Select-Object Name,ifDesc,Status,Mtusize,DriverVersion,MacAddress,LinkSpeed | Sort-Object Name
  $AdapterInfos | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ENV:COMPUTERNAME
  $AdapterVMQs = Get-NetAdapterVmq -Name @('VMs*','MGMT*') | Select-Object Name,NumaNode,Enabled,BaseProcessorGroup,BaseProcessorNumber,MaxProcessorNumber,MaxProcessors,NumberOfReceiveQueues
  $AdapterVMQs | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ENV:COMPUTERNAME
  $AdapterRSSs = Get-NetAdapterRss -Name @('VMs*','MGMT*') | Select-Object Name,Enabled,Profile,BaseProcessorGroup,BaseProcessorNumber,MaxProcessorGroup,MaxProcessorNumber,MaxProcessors,NumaNode,NumberOfReceiveQueues#
  $AdapterRSSs | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ENV:COMPUTERNAME
  New-Object PSObject -Property ([ordered]@{
      AdapterInfos = $AdapterInfos
      AdapterVMQs = $AdapterVMQs
      AdapterRSSs = $AdapterRSSs
      HVSwitches = Hyper-V\Get-VMSwitch
  })
}
$sb_GetHyperV_Software = {
  $ExpectedSoftwareHP = @(
    'Configuration Manager Client'
    'HP Lights-Out Online Configuration Utility'
    'HP Universal Discovery Agent (x86)'
    'HPE ProLiant Agentless Management Service'
    'HPE ProLiant Agentless Management Service'
    'HPE System Management Homepage'
    'iLO 3/4 Core Driver (X64)'
    'iLO 3/4 Management Controller Driver Package'
    'Insight Diagnostics'
    'Integrated Management Log Viewer'
    'Integrated Smart Update Tools for Windows'
    'McAfee Agent'
    'MergeModule2012'
    'Microsoft Monitoring Agent'
    'Microsoft Policy Platform'
    'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660'
    'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660'
    'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660'
    'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660'
    'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660'
    'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660'
    'ProLiant Monitor Service (X64)'
    'Smart Storage Administrator'
    'Smart Storage Administrator CLI'
    'Smart Storage Administrator Diagnostics and SSD Wear Gauge Utility'
  )
  $SoftwareList = @()
  $Softwares = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName}
  if (Test-Path 'HKLM:\Software\Wow6432Node') {
    $Softwares += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName}
  }
  foreach ($Software in $Softwares) {
    $SWInfo = New-Object psobject -Property @{
      'DisplayName' = $Software.DisplayName
      'DisplayVersion' = $Software.DisplayVersion
      'Publisher' = $Software.Publisher
      'InstallDate' = $Software.InstallDate
      'InstallSource' = $Software.InstallSource
      'HelpLink' = $Software.HelpLink
      'UninstallString' = $Software.UninstallString
    }
    $SoftwareList += $SWInfo
  }
  $SoftwareList | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate,InstallSource,UninstallString
  $ToManySoftware = Compare-Object -ReferenceObject $ExpectedSoftwareHP -DifferenceObject $($SoftwareList.DisplayName) | Where-Object SideIndicator -eq '=>' | Select-Object -ExpandProperty InputObject
  New-Object PSObject -Property ([ordered]@{
      masvc = if (Get-Service -Name 'masvc' -ErrorAction SilentlyContinue) {$true} Else {$false}
      macmnsvc = if (Get-Service -Name 'macmnsvc' -ErrorAction SilentlyContinue) {$true} Else {$false}
      McAfeeFramework = if (Get-Service -Name 'McAfeeFramework' -ErrorAction SilentlyContinue) {$true} Else {$false}
      ToManySoftware = $ToManySoftware
  })
}
$sb_GetHyperV_EmptyFolders = {
  <#
      Invoke-Command -ComputerName 'FSDEBSNE0411.mgmt.fsadm.vwfs-ad' -ScriptBlock $sb_GetHyperV_EmptyFolders | Select-Object VMPath,FolderSizeGB
  #>

  $Folders = @('\\fsdebsgv2110\kC07DMZ1VMs-1','\\fsdebsgv2110\kC07DMZ23VMs-1','\\fsdebsgv2110\kC07MSC-1','\\fsdebsgv2110\pC07DMZ1VMs','\\fsdebsgv2110\pC07DMZ23VMs','\\fsdebsgv2110\pC07MSC','\\fsdebsgv2110\scbC07SQLVMs','\\fsdebsgv2110\scbC07VMs')
  $Folders += @('\\fsdebsgv2010\kA06DMZ1VMs-1','\\fsdebsgv2010\kA06DMZ23VMs-1','\\fsdebsgv2010\kA06MSC-1','\\fsdebsgv2010\pA06DMZ1VMs','\\fsdebsgv2010\pA06DMZ23VMs','\\fsdebsgv2010\pA06MSC','\\fsdebsgv2010\scbA06SQLVMs','\\fsdebsgv2010\scbA06VMs')
  $Folders += @('\\fsdebsgv2020\kA06SQLVMs','\\fsdebsgv2020\pA06SQLVMs','\\fsdebsgv2020\pkA06SQLLibrary')
  $Folders += @('\\fsdebsgv2120\kC07SQLVMs','\\fsdebsgv2120\pC07SQLVMs','\\fsdebsgv2120\pkC07SQLLibrary')
  $Folders += @('\\fsdebsgv0530\iSRDMZ1VMs','\\fsdebsgv0530\iSRDMZ2u3VMs','\\fsdebsgv0530\iSRLibrary')
  $Folders += @('\\fsdebsgv0430\iGFDMZ1VMs','\\fsdebsgv0430\iGFDMZ2u3VMs','\\fsdebsgv0430\iGFLibrary')
  $Folders += @('\\fsdebsgv0460\eA06SQLVMs','\\fsdebsgv0460\eiA06SQLLibrary','\\fsdebsgv0460\iA06SQLVMs')
  $Folders += @('\\fsdebsgv0560\eC07SQLVMs','\\fsdebsgv0560\eiC07SQLLibrary','\\fsdebsgv0560\iC07SQLVMs')

  $fso = New-Object -ComObject Scripting.FileSystemObject
  $VMList = @()
  Get-ChildItem -Path $Folders -Directory | ForEach-Object {$VMList += New-Object PSObject -Property ([ordered]@{VMPath=$($_.FullName);FolderSizeGB=[math]::Round(($fso.GetFolder($_.FullName).Size / 1GB),0)})}
  $VMList = $VMList | Sort-Object -Property FolderSizeGB
  $VMList | Where-Object FolderSizeGB -eq 0 | Sort-Object -Property VMPath
}
$sb_GetIBAInfos = {
  New-Object PSObject -Property ([ordered]@{
      Status = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSAG' -Name 'Status').Status
      ServiceLevelQuality = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSAG' -Name 'ServiceLevelQuality').ServiceLevelQuality
      Department = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSAG' -Name 'Department').Department
      IBAVersion =  (Get-ItemProperty -Path 'HKLM:\SOFTWARE\IBA' -Name 'Version').Version
      ServerType =  (Get-ItemProperty -Path 'HKLM:\SOFTWARE\IBA' -Name 'ServerType').ServerType
      ServerFarm =  (Get-ItemProperty -Path 'HKLM:\SOFTWARE\IBA' -Name 'ServerFarm').ServerFarm

  })
}
$sb_GetSDPBranding = {
  $keyBase = 'HKLM:\SOFTWARE\FSAG'
  $obj = [ordered]@{}
  Get-Item $keyBase -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property  | ForEach-Object {
    $obj.add($_,(Get-ItemProperty $keyBase ).$_)
  }
  $apps = [Ordered]@{}
  $keyBase ="$keyBase\Apps"
  Get-Item $keyBase -ErrorAction SilentlyContinue| Select-Object -ExpandProperty Property  | ForEach-Object {
    if((Get-ItemProperty $keyBase ).$_ -ne 'NA'){
      $apps.add($_,(Get-ItemProperty $keyBase ).$_)
    }
  }
  $obj.add("Apps",$apps)

  $apps = [Ordered]@{}
  Get-ChildItem $keyBase -ErrorAction SilentlyContinue  | ForEach-Object{
    if((Get-ItemProperty $_.PsPath ).Name -ne 'NA'){
      $apps.add($_.PSChildName,(Get-ItemProperty $_.PsPath ).Name)
    }
  }
  $obj.add("SDPs",$apps)

  Get-Item 'HKLM:\SOFTWARE\IBA' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty property | ForEach-Object {
    $obj.Add("IBA_$_",(Get-ItemProperty HKLM:\SOFTWARE\IBA).$_)
  }
  [pscustomobject]$obj
}

