break

#Memory ermitteln
$Slots=Get-CimInstance -ClassName Win32_PhysicalMemoryArray 
$RAM=Get-CimInstance -ClassName Win32_PhysicalMemory 
$slots | % {"DIMM Slots: $($_.MemoryDevices)"} 
$ram | % {"Memory installed: $($_.DeviceLocator)"; "Memory Size $($_.Capacity/1GB)"}

#freien Memory ermitteln
Get-CimInstance win32_operatingsystem | Select-Object @{N="Frei GB";E={$_.FreePhysicalMemory/1MB}}, @{N="Gesamt GB";E={$_.TotalVisibleMemorySize/1MB }}, @{N="Anteil frei in Prozent";E={$_.FreePhysicalMemory*100 / $_.TotalVisibleMemorySize}}

#Finding CimClassMethods
$class = Get-CimClass -ClassName StdRegProv
$class.CimClassMethods
$class.CimClassMethods['GetStringValue'].Parameters

#Finding Attached USB Sticks
Get-WmiObject -Query 'Select * From Win32_PnPEntity where DeviceID Like "USBSTOR%"'

#Check WMI Repository
WinMgmt.exe /verifyrepository
mofcomp.exe hbaapi.mof   #aus dem Ordner C:\Windows\System32\wbem wenn mal eine Komponente zickt

#Speeding Up Multiple WMI Queries
$session = New-CimSession -ComputerName localhost
$os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session
$bios = Get-CimInstance -ClassName Win32_BIOS -CimSession $session

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
$wmidate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($date)
$os = Get-WmiObject -Class Win32_OperatingSystem
$bootTime = $os.LastBootUpTime
[System.Management.ManagementDateTimeConverter]::ToDateTime($bootTime)

#Checking System Uptime
$os = Get-WmiObject -Class Win32_OperatingSystem
$boottime = [System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootupTime)
$timedifference = New-TimeSpan -Start $boottime
$days = $timedifference.TotalDays
'Your system is running for {0:0.0} days.' -f $days
Function Get-UpTime {
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

######CIM CmdLets
iexplore.exe http://blogs.msdn.com/b/powershell/archive/2013/08/19/cim-cmdlets-some-tips-amp-tricks.aspx
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBoot*
Get-Command -module CimCmdlets
$creds = Get-Credential -Credential username
$creds | Export-Clixml -Path c:\a.clixml
$savedCreds = Import-Clixml -Path C:\a.clixml
$session = New-CimSession -ComputerName 'machineName' -Credentials $savedCreds
$inst = Get-CimInstance Win32_OperatingSystem -ComputerName localhost

$allSessions = New-CimSession -ComputerName 'machine1', 'machine2', 'machine3' -Credentials $credentials
Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $allSessions
Invoke-CimMethod -ClassName Win32_OperatingSystem -MethodName Reboot -CimSession $allSessions   or
Invoke-CimMethod -ClassName Win32_OperatingSystem -MethodName Reboot -ComputerName 'Machine1', 'Machine2','Machine3'

#make multiple WMI queries to a remote machine more efficient
$sess = New-CimSession -Computername server02
Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $sess

$disks = Get-CimInstance -class Win32_LogicalDisk -Filter 'DriveType = 3'
Get-CimAssociatedInstance -CimInstance $disks[0] -ResultClassName Win32_DiskPartition
Get-CimAssociatedInstance -CimInstance $disks[0] -Association Win32_LogicalDiskRootDirectory
Get-CimClass -MethodName create

Invoke-CimMethod -ClassName Win32_Process -Name Create -Arguments @{Commandline='Notepad C:\Windows\System.ini'}
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
Get-CimInstance -class 'win32_volume' | Where-Object {$_.Caption -match ':' -and $_.DriveType -eq '3'} | Select-object -Property caption,@{Label='BlocksizeKB';Expression={($_.BlockSize)/1KB}} | Format-Table -AutoSize

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

