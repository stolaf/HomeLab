break

#wmi Reparieren in administrativer Powershell

winmgmt /verifyrepository
winmgmt /salvagerepository
Stop-service -Name 'winmgmt' -force
Set-Service -Name 'Winmgmt' -StartupType Disabled 
Rename-Item -Path "$ENV:windir\System32\wbem\Repository" -NewName "$ENV:WINDIR\System32\wbem\Repository_old"

Wechseln Sie in der DOS-Box in den Ordner cd c:\Windows\system32\wbem
for /f %s in ('dir /b /s *.dll') do regsvr32 /s %s

Set-Service -Name 'Winmgmt' -StartupType Automatic
Start-service -Name 'winmgmt'

# Setzen Sie unter Umständen die folgenden Befehle in einer DOS-Box ab:
# winmgmt /clearadap
# winmgmt /kill
# winmgmt /unregserver
# winmgmt /regserver
# winmgmt /resyncperf
Restart-Computer -force

#System error Codes: https://msdn.microsoft.com/de-de/library/windows/desktop/ms681381(v=vs.85).aspx
#The RPC server is unavailable. (Exception from HRESULT: 0x800706BA) bei Remote WMI Abfragen
#Firewall?
[ComponentModel.Win32Exception]0x800706BA

Get-WmiHelpLocation Win32_Share
http://msdn.microsoft.com/en-us/library/aa394435(VS.85).aspx

#Finding Attached USB Sticks
Get-WmiObject -Query 'Select * From Win32_PnPEntity where DeviceID Like "USBSTOR%"'

#Check WMI Repository
WinMgmt.exe /verifyrepository
mofcomp.exe hbaapi.mof   #aus dem Ordner C:\Windows\System32\wbem wenn mal eine Komponente zickt

#Changing Computer Description
$os = Get-WmiObject -Class Win32_OperatingSystem
$os.Description = 'I changed this!'
$result = $os.PSBase.Put()

# Check Windows License Status
Get-WmiObject SoftwareLicensingService
Get-WmiObject SoftwareLicensingProduct | Select-Object -Property Description, LicenseStatus | Out-GridView

#Finding Computer Serial Number
Get-WmiObject Win32_SystemEnclosure | Select-Object -ExpandProperty serialnumber

#Listing All WMI Namespaces
Get-WmiObject -Query 'Select * from __Namespace' -Namespace Root | Select-Object -ExpandProperty Name
Get-WmiObject -Namespace root\SecurityCenter2 -List
Get-WmiObject -Namespace root\SecurityCenter2 -Class AntivirusProduct

#Converting WMI Date and Time
$date = Get-Date
$wmidate = [Management.ManagementDateTimeConverter]::ToDmtfDateTime($date)
$os = Get-WmiObject -Class Win32_OperatingSystem
$bootTime = $os.LastBootUpTime
[Management.ManagementDateTimeConverter]::ToDateTime($bootTime)

#Checking System Uptime
$os = Get-WmiObject -Class Win32_OperatingSystem
$boottime = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootupTime)
[Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem).LastBootupTime)
$timedifference = New-TimeSpan -Start $boottime
$days = $timedifference.TotalDays
'Your system is running for {0:0.0} days.' -f $days
function Get-UpTime {
  param
  (
    $ComputerName='localhost'
  )
  Get-WmiObject Win32_NTLogEvent -Filter 'Logfile="System" and EventCode>6004 and EventCode<6009' -ComputerName $ComputerName |
  ForEach-Object {
    $rv = $_ | Select-Object EventCode, TimeGenerated
    switch ($_.EventCode) {
      6006 { $rv.EventCode = 'shutdown' }
      6005 { $rv.EventCode = 'start' }
      6008 { $rv.EventCode = 'crash' }
    }
    $rv.TimeGenerated = $_.ConvertToDateTime($_.TimeGenerated)
    $rv
  }
}

#Get Running Process Owners
Get-WmiObject Win32_Process | ForEach-Object {$ownerraw = $_.GetOwner();$owner = '{0}\{1}' -f $ownerraw.domain, $ownerraw.user;$_ | Add-Member NoteProperty Owner $owner -PassThru} | Select-Object Name, Owner

# save current power plan
$PowerPlan = (Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter 'isActive=True').ElementName
"Current power plan: $PowerPlan"
# turn on high performance power plan
(Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter 'ElementName="HighPerformance"').Activate()
# turn power plan back to what it was before
(Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter "ElementName='$PowerPlan'").Activate()
"Power plan is back to $PowerPlan"

#Get All Logged-On Users
Get-WmiObject Win32_Process -Filter 'name="explorer.exe"' -Computername 'localhost' | ForEach-Object { $owner = $_.GetOwner(); '{0}\{1}' -f $owner.Domain, $owner.User } | Sort-Object -Unique

#List Local Groups, This uses WMI to retrieve all groups where the domain part is equal to your local computer name and returns the group name and SID.
Get-WmiObject -Query "SELECT * FROM Win32_Group WHERE LocalAccount='True'" 
Get-WmiObject Win32_Group -Filter "domain = '$env:computername'" | Select-Object Name,SID

# Getting WMI Help
function Get-WmiHelpLocation {
  param ($WmiClassName='Win32_BIOS')
  $Connected = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet
  if ($Connected) {
    $uri = 'http://www.bing.com/search?q={0}+site:msdn.microsoft.com' -f $WmiClassName
    $url = (Invoke-WebRequest -Uri $uri -UseBasicParsing).Links | Where-Object href -like 'http://msdn.microsoft.com*' | Select-Object -ExpandProperty href -First 1
    Start-Process $url
    $url
  } else {
    Write-Warning 'No Internet Connection Available.'
  }
}
Get-WmiHelpLocation Win32_Share

[WMI]'Win32_Service.Name="W32Time"'
[WMI]'\\SERVER5\root\cimv2:Win32_Service.Name="W32Time"'
[WMI]'Win32_Logicaldisk="C:"'
[WMI]"\\$ComputerName\root\cimv2:Win32_LogicalDisk='C:'"

#Calling ChkDsk via WMI
([WMI]"Win32_LogicalDisk='D:'").Chkdsk($true, $false, $false, $false, $false, $true).ReturnValue


Get-WmiObject -Query 'Select * from __Namespace' -Namespace Root | Select-Object -ExpandProperty Name
Get-WmiObject -Namespace root\SecurityCenter2 -List
Get-WmiObject -Namespace root\SecurityCenter2 -Class AntivirusProduct
Get-WmiObject -Namespace 'root\MicrosoftIISv2' -List
Get-WmiObject Win32_Process | Get-Member -memberType *prop* *Size*

#Make VSS Copy
(Get-WmiObject -list win32_shadowcopy).Create('C:\','ClientAccessible')

# Directly access a WMI instance of a drive (drive C:)
$a = [wmi]'Win32_LogicalDisk="C:"' 
$a | Format-Table Name, Freespace -autosize
$a.FreeSpace
'Free Space {0:0.0} GB' -f ($a.FreeSpace/1GB)

$machine = get-wmiobject -class 'Win32_OperatingSystem' -ComputerName $ComputerName -Credential $myDomainAdminCredentials
Write-Host "BootUp Time from $ComputerName : " ($machine.ConvertToDateTime($machine.LastBootUpTime))

$c = Get-WmiObject Win32_ComputerSystem -EnableAllPrvileges
$c.AutomaticManagedPagefile = $false
$c.Put()

Get-WmiObject Win32_Share -filter 'type=0'   #ohne Admin Shares
Get-WmiObject Win32_Share -filter 'description!=""'
Get-WmiObject -Class Win32_VideoController -ComputerName $Computername |Select-Object *resolution*, __SERVER

#IP Change Event is 4201 im System Log
register-wmievent -SourceIdentifier 'IP Change Event' `
-query "Select * from __instancecreationevent where TargetInstance isa 'Win32_NTLogEvent'and TargetInstance.SourceName = 'System' And TargetInstance.EventCode = '999'" `
-action {DynDNSUpdate}
get-eventsubscriber -force
Unregister-Event 'IP Change Event'
Unregister-Event -SubscriptionId 2

#Get Cluster Size
get-wmiobject -class 'win32_volume' -filter "DriveLetter = '$Drive'" -ComputerName $Server | select-object BlockSize

Get-WmiObject Win32_PnPEntity -Filter "Name='Flash Drive AU USB20 USB Device'"

#Format Drive
(Get-WmiObject -Class Win32_Volume -Filter "DriveLetter='D:'" ).Format('NTFS',$true,4096,'', $false)

#Get HD Drive SerialNumber
Get-WmiObject -Class Win32_DiskDrive | Select-Object -ExpandProperty SerialNumber

#Shutdown / Reboot / Logoff
# 0 = Log off
# 4 = Forced log off
# 1 = Shutdown
# 5 = Forced shutdown
# 2 = Reboot
# 6 = Forced reboot
# 8 = Power off
# 12 = Forced power off
(Get-WmiObject -Class Win32_OperatingSystem -ComputerName MyComputer).InvokeMethod('Win32Shutdown',4)
(Get-WmiObject win32_operatingsystem -ComputerName MyComputer -cred (get-credential)).Win32Shutdown(6)

#rename Computer
netdom.exe renamecomputer $Env:COMPUTERNAME /newname:"RZ-DC1" /Force /Reboot:1
(Get-WmiObject Win32_ComputerSystem -ComputerName $ComputerName -EnableAllPrivileges).Rename($NewName)

#Get IP Address
(Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=true' | Select-Object -ExpandProperty IPAddress) -join ', '
$ipaddresses = @(Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress } | % { $_.IPAddress } | Where-Object { $_ -notlike '127.*' -and $_ -notlike '*::*' })

#Get Mac Address
Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.MacAddress } | Select-Object Name, MacAddress

#Get NetworkkworkAdapter listet in Panel
Get-WmiObject Win32_NetworkAdapter -Filter 'NetConnectionID!=null'

(Get-WmiObject -Class win32_Process -ComputerName $ComputerName -Credential $myDomainAdminCredentials -filter "name='setup.exe'")

