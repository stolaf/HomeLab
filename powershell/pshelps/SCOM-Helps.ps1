<#
    fsdtbsy04441.mgmt.fsadm.vwfs-ad neu 
  
    SCOM Agent 2012R2: 7.1.10184.0
    SCOM Agent 2012  : 7.0.9538.0
    SCOM Agent 2007R2: 6.1.7221.0
  
    Performance Counter Error:http://support.microsoft.com/kb/300956
    cd\windows\system32 
    Lodctr/r
  
    #Abgleich SCVMM Computers <-> SCOM Computers
    Import-Module virtualMachineManager
    $VMs = Get-SCVirtualMachine -All
    $SCOMAgents = Invoke-Command -ComputerName 'fsdtbsy04441.mgmt.fsadm.vwfs-ad' -ScriptBlock {Import-Module OperationsManager;Get-SCOMAgent}
  
    $SCVMMComputers = $VMs | Select-Object @{Label='Name';Expression={if ($_.Name.IndexOf('.') -gt 0) {($_.Name.Substring(0,$_.Name.IndexOf('.'))).ToUpper()} else {($_.Name.ToUpper())}}}
    $SCOMComputers = $SCOMAgents | ? DisplayName | Select-Object @{Label='Name';Expression={if ($_.DisplayName.IndexOf('.') -gt 0) {($_.DisplayName.Substring(0,$_.DisplayName.IndexOf('.'))).ToUpper()} else {($_.DisplayName.ToUpper())}}}
    Compare-Object -ReferenceObject $SCVMMComputers -DifferenceObject $SCOMComputers -Property Name | ? SideIndicator -eq '<=' | Select-Object -ExpandProperty Name
  
#>

# Branding Check
$All_VMs = Get-IOPI_HyperV_VM -VMName '*' -Notes 'PRJ|INT' -ComputerName $IOPI_INT_HyperVServerNames
# $All_VMs = Get-IOPI_HyperV_VM -VMName '*' -ComputerName $IOPI_PK_HyperVServerNames 
$Check_VMs = $All_VMs | Where-Object {$_.Notes -match 'KONS|PROD' -and $_.State -eq 'Running'}

$SDPBrandings = $Check_VMs | Invoke-IOPI_Parallel -RunspaceTimeout 150 -Throttle 20 -ScriptBlock { 
  $VMInfo = $_
  Import-Module -Name '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI'
  Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_GetSDPBranding 
}
$SDPBrandings | Select-Object * -ExcludeProperty RunspaceID,PSShowComputerName | ConvertTo-Json | Out-File -Encoding utf8 -FilePath '\\fsdebsgv4911\iopi_sources$\Reports\HyperV_VMs\SDPBrandings-PK.json' -Force

############################################################

Test-NetConnection -ComputerName 'fsdebsy44441.mgmt.fsadm.vwfs-ad' -Port 5723

$MonitoringObjects = Get-MonitoringClass -Name 'Microsoft.Windows.NetworkAdapter' | Get-MonitoringObject
($MonitoringObjects).'[Microsoft.Windows.Server.NetworkAdapter].IPSubnet'
($MonitoringObjects | Where-Object Path -like 'fsdebss13232*').'[Microsoft.Windows.Server.NetworkAdapter]'
  
$IOPI_SCOMNetworkAdapter = $IOPI_SCOMNetworkAdapters | Where-Object Path -like 'fsdebsy13681*' 
$IOPI_SCOMNetworkAdapter | Select-Object '[Microsoft.Windows.Server.NetworkAdapter].MACAddress'
foreach ($Adapter in $IOPI_SCOMNetworkAdapter) {
  $Adapter
}

$IOPI_SCOMNetworkAdapter | % {$IOPI_SCOMNetworkAdapter.'[Microsoft.Windows.Server.NetworkAdapter].MACAddress' -match '00-1D-D8-B7-1D-37'} 
($IOPI_SCOMNetworkAdapter).'[Microsoft.Windows.Server.NetworkAdapter].IPSubnet'
($IOPI_SCOMNetworkAdapter).'[Microsoft.Windows.Server.NetworkAdapter].IPAddress'
($IOPI_SCOMNetworkAdapter).'[Microsoft.Windows.Server.NetworkAdapter].MACAddress'
$IOPI_SCOMNetworkAdapter | Select-Object '[Microsoft.Windows.Server.NetworkAdapter].IPSubnet'
$MonitoringObject = Get-MonitoringObject -Path Monitoring:\fsdebssa0203.fs01.vwf.vwfs-ad -id 35efd8a0-7a94-3fe7-2bb5-01a90dfe8964
$MonitoringObject | Get-MonitoringClass -Path Monitoring:\fsdebssa0203.fs01.vwf.vwfs-ad -Name 'Microsoft.Windows.NetworkAdapter'

Add-PSSnapin 'Microsoft.EnterpriseManagement.OperationsManager.Client'
$Password = ConvertTo-SecureString '!Sunsh1ne' -AsPlainText -Force
$SCOMAdminCredential = New-Object System.Management.Automation.PSCredential 'FS01\zzSCOMWMI',$Password
$null = New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\ -ErrorAction SilentlyContinue -ErrorVariable Err
$null = New-ManagementGroupConnection -ConnectionString:fsdebssa0203.fs01.vwf.vwfs-ad -Credential $SCOMAdminCredential
Set-Location Monitoring:\fsdebssa0203.fs01.vwf.vwfs-ad
$MonitoringClass = Get-MonitoringClass -Path Monitoring:\fsdebssa0203.fs01.vwf.vwfs-ad -Name 'Microsoft.Windows.Server.2008.NetworkAdapter' 

Get-MonitoringObject -Path Monitoring:\fsdebssa0203.fs01.vwf.vwfs-ad -MonitoringClass $MonitoringClass `
-Criteria "Path like 'fsdebsy13681%' AND MACAddress = '02-BF-0A-29-4A-57' " | Select-Object ?Microsoft.Windows.Server.NetworkAdapter?.IPSubnet, ?Microsoft.Windows.Server.NetworkAdapter?.IPAddress 


Select-Object * from [dbo].[vManagedEntityProperty] MEP
join [dbo].[vManagedEntity] ME ON MEP.ManagedEntityRowId = ME.ManagedEntityRowId
Where-Object FullName LIKE 'Microsoft.Windows.Server.%.NetworkAdapter:FSDEBSY12382%'
AND ToDateTime IS NULL
ORDER BY DWLastModifiedDateTime DESC

$SCOMAgentInstallBatch = @"
@echo off

SET LogPath=C:\Temp\Logs
SET Mgmt_Server=FSDEBSSA0205.fs01.vwf.vwfs-ad
SET Mgmt_Group=OpsMgr2007PROD

md %LogPath%

IF %processor_architecture% == AMD64 Goto AMD64
IF %processor_architecture% == x86 Goto x86

:AMD64
msiexec /I SCOM2012R2_Agent\Agent\amd64\msxml6.msi /qn /l*v %LogPath%\msxml6_setup.log
msiexec /i SCOM2012R2_Agent\Agent\amd64\MOMAgent.msi /qn /l*v %LogPath%\momagent_setup.log USE_SETTINGS_FROM_AD=0 USE_MANUALLY_SPECIFIED_SETTINGS=1 MANAGEMENT_GROUP=%Mgmt_Group% MANAGEMENT_SERVER_DNS=%Mgmt_Server% ACTIONS_USE_COMPUTER_ACCOUNT=1 AcceptEndUserLicenseAgreement=1
REM for /r .\x64Update\ %%f in (*.msp) do start /WAIT %WinDir%\System32\msiexec.exe /update %%f  /passive /l*v "%LogPath%\%%f.log"
Goto Ende

:x86
msiexec /I SCOM2012R2_Agent\Agent\x86\msxml6.msi /qn /l*v %LogPath%\msxml6_setup.log
msiexec /i SCOM2012R2_Agent\Agent\x86\MOMAgent.msi /qn /l*v %LogPath%\momagent_setup.log USE_SETTINGS_FROM_AD=0 USE_MANUALLY_SPECIFIED_SETTINGS=1 MANAGEMENT_GROUP=%Mgmt_Group% MANAGEMENT_SERVER_DNS=%Mgmt_Server% ACTIONS_USE_COMPUTER_ACCOUNT=1 AcceptEndUserLicenseAgreement=1
REM for /r .\x64Update\ %%f in (*.msp) do start /WAIT %WinDir%\System32\msiexec.exe /update %%f  /passive /l*v "%LogPath%\%%f.log"
Goto Ende

:ENDE
REM Import Certificate
REM MomCertImport.exe .\Certificates\PXT_Test_SCCM_1.pfx /password password

net stop healthservice && net start healthservice
"@

#region SCOM 2007
%windir%\system32\runas.exe /savecred /user:fs01\zzSCOMWMI 'C:\Program Files\System Center Operations Manager 2007\Microsoft.MOM.UI.Console.exe'
%windir%\system32\runas.exe /user:mgmt\dkx1s37481 cmd.exe

Add-PSSnapin 'Microsoft.EnterpriseManagement.OperationsManager.Client'
Start-ISB_SCOM_ServerMaintenanceMode -ComputerName 'FSDEBSNE0321' -Minutes 180

get-agent | get-member -membertype property
get-agent | sort-object computername | select-object computername, Healthstate | format-table -auto
get-agent | Format-Table name,proxyingenabled
get-agent | Where-Object {$_.computerName -match 'SCCM'} | Format-Table name,proxyingenabled

$agents = get-agent | Where-Object {$_.computerName -match 'SCCM'}
$agents | foreach {$_.ProxyingEnabled = $true}
$agents | foreach {$_.ApplyChanges()}

#To get a list of computers that report to this management server
get-agent | Format-Table *displayname
#To get a list of agent managed machines and their IP Address associated with the specified management server
get-agent | Format-Table displayname, IPAddress

#To get a list of computers whose names start with EX* associated with the specified management server:
get-agent | where-object {$_.DisplayName -like 'EX*'} | format-list -property displayname
Get-ManagementPack and Export-ManagementPack

#Export all management packs in a management group:
get-managementPack | export-managementPack -path D:\MPDUMP\

#**Criteria Is Case Sensitive with all the get data SCOM cmdlets like Get-Alert, Get-Event, Get-PerformanceCounter, Get-PerformanceCounterValue!!
(get-alert -criteria 'SeveritY = "0"').count
Get-Alert : A property name in the 'Criteria' parameter is unknown.

get-alert | get-member -membertype property
#To show all alerts for Computer NOCDC01
get-alert -criteria 'NetbiosComputerName = "NOCDC01"'
#That showed too many alerts so let's pipe the output to the export-csv cmdlet.
get-alert -criteria 'NetbiosComputerName = "NOCDC01"'| export-csv c:\alert.csv
#To show all Resolved alerts for computer NOCDC01
get-alert -criteria 'NetbiosComputerName = "NOCDC01" AND ResolutionState = "255"'
(get-alert -criteria 'Severity = "0"').count
#count of all Warning alerts
(get-alert -criteria 'Severity = "1"').count
#To get a count of all Critical alerts
(get-alert -criteria 'Severity = "2"').count
#To get a count of all new alerts:
(get-alert -criteria 'ResolutionState = "0"').count
#To get a count of all new Warning Alerts:
(get-alert -criteria 'ResolutionState = "0" AND Severity = "1"').count
#To get a count of all new Critical Alerts:
(get-alert -criteria 'ResolutionState = "0" AND Severity = "2"').count
#Get a count of all alerts whose names start with AD.
get-alert -criteria 'Name Like "AD%"' | measure-object
#Get a count of how many alert names that have the string SQL in them.
get-alert -criteria 'Name Like "%SQL%"'| measure-object
#Get open alerts whose alert names start with Agent proxying:
get-alert -criteria 'Name Like "Agent proxying%" AND ResolutionState = "0"'
get-alert -criteria 'Name Like "Script%" AND ResolutionState = "0"'
(get-alert -criteria 'Name Like "Script%" AND ResolutionState = "0"').count
#Get a count of Alerts whose name is Auto Close Flag
(get-alert -criteria 'Name = "Auto Close Flag"').count
#Get a list of netbios computer names that have alerts named Auto Close Flag and get the name of the database that has that property enabled.
get-alert -criteria 'Name = "Auto Close Flag"' | Format-Table -property Netbioscomputername, Monitoringobjectname
#Get a list of netbios computer names that have alerts named Auto Shrink Flag and get the name of the database that has that property enabled.
get-alert -criteria 'Name = "Auto Shrink Flag"' | Format-Table -property Netbios
#Other Folks get-alert one liners:

get-alert -criteria 'ResolutionState = "0"' | Group-Object Name |Sort-Object -desc Count | select-Object -first 5 Count, Name |Format-Table -auto
get-alert -criteria 'ResolutionState = "255"' | Group-Object Name |Sort-Object -desc Count | select-Object -first 5 Count, Name |Format-Table -auto
#Top 5 computers with new alerts.
get-alert -criteria 'ResolutionState = "0"' | Group-Object PrincipalName |Sort-Object -desc Count | select-Object -first 5 Count, Name | Format-table -auto
#Top 5 computers with resolved alerts:
get-alert -criteria 'ResolutionState = "255"' | Group-Object PrincipalName |Sort-Object -desc Count | select-Object -first 5 Count, Name | Format-table -auto
#Get top 5 new critical alerts by count:
get-alert -criteria 'ResolutionState = "0" AND Severity = "2"' | Group-Object Name |Sort-Object -desc Count | select-Object -first 5 Count, Name |Format-Table -auto
#what alerts are open and created by a monitor
get-alert -criteria 'ResolutionState = "0" AND IsMonitorAlert = "True"'|Group-Object Name |Sort-Object -desc Count | select-Object Count, Name |Format-Table -auto
#what alerts are open and created by a rule
get-alert -criteria 'ResolutionState = "0" AND IsMonitorAlert = "False"'|Group-Object Name |Sort-Object -desc Count | select-Object Count, Name |Format-Table -auto
#Get alert information and slap it into a csv file:
get-alert  | select-object NetbiosComputerName, Description, Severity | Export-Csv -path 'c:\alerts.csv'

#RESOLVE-ALERT:
$null = get-alert -criteria 'LastModified >= "4/6/2008" AND ResolutionState = "0" AND Category = "Alert"'| resolve-alert -comment 'Chuck Norris resolved these alerts with his fists of fury!!!!'
#Close all open alerts that were generated by a Rule:
$null = get-alert -criteria 'ResolutionState = "0" AND IsMonitorAlert = "False"'| resolve-alert -comment 'Closing rule generated alerts'
#Close all open alerts that were generated by a monitor:
$null = get-alert -criteria 'ResolutionState = "0" AND IsMonitorAlert = "True"'| resolve-alert -comment 'Closing Monitor generated alerts'
#Reset health for a monitor called "Manual monitor" on all objects of the class "Contoso.MyCustomClass" currently in an Error state(Brian Wrens Blog)
$mon = get-monitor | Where-Object {$_.displayName -eq 'Manual monitor'}
$mc = get-monitoringClass -name Contoso.MyCustomClass
$mc | get-monitoringObject | Where-Object {$_.HealthState -eq 'Error'} | foreach {$_.ResetMonitoringState($mon)}
#endregion SCOM 2007

