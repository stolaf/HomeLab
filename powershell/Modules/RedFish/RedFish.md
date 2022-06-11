# Redfish

https://github.com/dell/iDRAC-Redfish-Scripting
https://www.dell.com/support/home/de/de/debsdt1/product-support/product/idrac9-lifecycle-controller-v4.x-series/overview

iDRAC9 with Lifecycle Controller Version 3.36.36.36 Redfish API Guide
https://www.dell.com/support/article/de-de/sln310624/webfish-api-mit-dell-integrated-remote-access-controller?lang=de

https://www.dell.com/support/manuals/de/de/debsdt1/idrac9-lifecycle-controller-v3.36.36.36/idrac9_3.36_redfishapiguide/overview?guid=guid-e85fd9c0-f4d1-4eff-be5d-550ebb77ff0d&lang=en-us

```powershell

ipmo 'C:\Users\dkx8zb8adm\Git\iDRAC-Redfish-Scripting\Redfish PowerShell\Get-StorageInventoryREDFISH'
ipmo 'C:\Users\dkx8zb8adm\Git\iDRAC-Redfish-Scripting\Redfish PowerShell\Get-IdracLifecycleLogsREDFISH'

Get-StorageInventoryREDFISH -idrac_ip 10.32.18.112 -idrac_username 'ILOINSTALL' -idrac_password 'DAde$mP!' -storage_controller RAID.Integrated.1-1 -get_disks y
Get-IdracLifecycleLogsREDFISH -idrac_ip 10.32.18.111 -idrac_username 'ILOINSTALL' -idrac_password 'DAde$mP!'

resolve-dnsname 'FSDEBSNE20412r'
$idrac_ip = '10.33.18.122'
$user = 'ILOINSTALL'
$pass= '...'
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)

$u = "https://$idrac_ip/redfish/v1/Managers/iDRAC.Embedded.1/Logs/Lclog"

$system = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Systems/System.Embedded.1" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
$systemData = $system.Content | ConvertFrom-Json
Write-Output "Manufacturer: $($systemData.Manufacturer)"
Write-Output "Service tag: $($systemData.SKU)"
Write-Output "Serial number: $($systemData.SerialNumber)"
Write-Output "Hostname: $($systemData.Hostname)"
Write-Output "Power state: $($systemData.PowerState)"
Write-Output "Asset tag: $($systemData.AssetTag)"
Write-Output "Memory size: $($systemData.MemorySummary.TotalSystemMemoryGiB)"
Write-Output "CPU Type: $($systemData.ProcessorSummary.Model)"
Write-Output "CPU Status: $($systemData.ProcessorSummary.Status)"
Write-Output "Number of CPUs: $($systemData.ProcessorSummary.Count)"
Write-Output "LogicalProcessorCount: $($systemData.ProcessorSummary.LogicalProcessorCount)"
Write-Output "SystemStatus: $($systemData.Status.Health)"
$systemData.Boot
$systemData.Boot.'BootSourceOverrideTarget@Redfish.AllowableValues'

$Chassis = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Chassis/System.Embedded.1" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
$ChassisData = $Chassis.Content | ConvertFrom-Json

$Managers = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Managers/iDRAC.Embedded.1" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
$ManagersData = $Managers.Content | ConvertFrom-Json
$ManagersData.FirmwareVersion
$ManagersData.DateTime
$ManagersData.CommandShell


$Accounts = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Managers/iDRAC.Embedded.1/Accounts" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
$AccountsData = $Accounts.Content | ConvertFrom-Json
$AccountsData.'Members@odata.count'

for ($i=1; $i -lt $($AccountsData.'Members@odata.count'); $i++) {
  $Account = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Managers/iDRAC.Embedded.1/Accounts/$i" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
  $AccountData = $Account.Content | ConvertFrom-Json
  Write-Output "$($AccountData.UserName)"
  Write-Output "$($AccountData.RoleId)"
  Write-Output "$($AccountData.Password)"
  Write-Output "$($AccountData.Enabled)"
  Write-Output "###############################"
}


$Bios = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Systems/System.Embedded.1/Bios" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
$BiosData = $Bios.Content | ConvertFrom-Json
$BiosData.Attributes

https://fsdebsne10411r/redfish/v1/Managers/iDRAC.Embedded.1/Logs/Sel
https://fsdebsne10411r/redfish/v1/Managers/iDRAC.Embedded.1/NetworkProtocol

resolve-dnsname 'FSDEBSNE10522r'
$idrac_ip = '10.32.18.132'

$iDRAC = Invoke-WebRequest -Uri "https://$idrac_ip/redfish/v1/Managers/iDRAC.Embedded.1/EthernetInterfaces/NIC.1" -Credential $credential -Method Get -UseBasicParsing -ErrorVariable RespErr -Headers @{"Accept"="application/json"}
$iDRACData = $iDRAC.Content | ConvertFrom-Json
$iDRACData.MACAddress
$iDRACData.HostName
$iDRACData.MTUSize
$iDRACData.SpeedMbps
$iDRACData.Status

<#
    Zum Thema BIOS Settings für Virtualisierung
    Die Server besitzen bereits eingebaute Workloadprofile, die die Best Practice Einstellungen f�r verschiedene Workloads enthalten.
    (Siehe auch angeh�ngtes Dokument). Für Virtualisierung stehen 2 Profile (Performance Optimized Virtualization | Power Optimized Virtualization )
    zur Verfügung.
    Ich würde einen Server das entsprechende Profil zuweisen. ZB über die iDRAC Funktion das BIOS Parameter bearbeiten:
    Configuration > BIOS Settings > System Profile Settings > Workload Profil ausw�hlen  >>> Apply   >> Apply and Reboot

    Danach das Configuration Profile per Powershell abholen (BIOS Parameter reichen) und auf den anderen Servern einspielen.
#>
FSDEBSNE10411: BIOS Referenz
Set-ExportServerConfigurationProfileLocalREDFISH -idrac_ip $idrac_ip -idrac_username $user -idrac_password $pass -Target "BIOS"
Set-ImportServerConfigurationProfileLocalFilenameREDFISH -idrac_ip $idrac_ip -idrac_username $user -idrac_password $pass -Target BIOS -FileName 03212018-213336_scp_file.xml
```

