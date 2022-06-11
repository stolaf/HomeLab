break

function Get-InstalledSoftwareGUID {
    <#
      .SYNOPSIS
        Retrieves a list of all software installed

      .EXAMPLE
        Get-InstalledSoftware
        This example retrieves all software installed on the local computer

      .PARAMETER Name
        Get-InstalledSoftware -Name 'McAfee'
        The software title you'd like to limit the query to.

      .LINK
      https://4sysops.com/archives/find-the-product-guid-of-installed-software-with-powershell/
    #>
    [OutputType([Management.Automation.PSObject])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
 
    $UninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS
    $UninstallKeys += Get-ChildItem HKU: -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | ForEach-Object { "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall" }
    if (-not $UninstallKeys) {
        Write-Verbose -Message 'No software registry keys found'
    } else {
        foreach ($UninstallKey in $UninstallKeys) {
            if ($PSBoundParameters.ContainsKey('Name')) {
                $WhereBlock = { ($_.PSChildName -match '^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$') -and ($_.GetValue('DisplayName') -like "$Name*") }
            } else {
                $WhereBlock = { ($_.PSChildName -match '^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$') -and ($_.GetValue('DisplayName')) }
            }
            $gciParams = @{
                Path        = $UninstallKey
                ErrorAction = 'SilentlyContinue'
            }
            $selectProperties = @(
                @{n='GUID'; e={$_.PSChildName}}, 
                @{n='Name'; e={$_.GetValue('DisplayName')}}
            )
            Get-ChildItem @gciParams | Where-Object $WhereBlock | Select-Object -Property $selectProperties
        }
    }
}

#list of devices with missing drivers
#StatusCodes : https://support.microsoft.com/en-us/kb/310123

#KMS Activation
resolve-dnsname FSDEBSSA0666.vwf.vwfs-ad  # --> 10.40.236.101 
route ADD 10.40.236.96 MASK 255.255.255.240 10.41.42.161 /p
10.40.236.101   FSDEBSSA0666  FSDEBSSA0666.vwf.vwfs-ad   # Host Eintrag
Test-NetConnection -ComputerName FSDEBSSA0666.vwf.vwfs-ad -Port 1688   #KMS only then port 1688 is enough
cscript.exe $Env:WINDIR\System32\slmgr.vbs -skms fsdebssa0666.vwf.vwfs-ad
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk C3RCX-M6NRP-6CXC9-TW2F2-4RHYD   #Server 2016 Standard
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY   #Server 2016 Standard KMS
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk CB7KF-BWN84-R7R2Y-793K2-8XDDG   #Server 2016 DataCenter
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk DBGBW-NPF86-BJVTX-K3WKJ-MTB6V   #Server 2012R2 Standard
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk N69G4-B89J2-4G8F4-WWYCC-J464C   #Server 2019 Standard KMS
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk TNK62-RXVTB-4P47B-2D623-4GF74   #Server 2019 Standard AVMA
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk H3RNG-8C32Q-Q8FRX-6TDXV-WMBMW   #Server 2019 DataCenter AVMA
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk WMDGN-G9PQG-XVVXX-R3X43-63DFG   #Server 2019 DataCenter KMS

cscript.exe $Env:Windir\system32\slmgr.vbs -ato
Test-NetConnection -ComputerName 'FSDEBSSA0666.vwf.vwfs-ad' -Port 1688 
Test-NetConnection -ComputerName 10.40.236.101 -Port 1688 

#Proxy Settings
(Get-ItemProperty -Path HKCU:"Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name AutoConfigURL).AutoConfigURL
Set-ItemProperty -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name AutoConfigURL -Value "http://fs-net.fs01.vwf.vwfs-ad:82/vwbank-prod.pac" 

#IE Dialog beim ersten Start ausschalten (Security Warnung)
Set-ItemProperty -Path "HKLM:Software\Microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -Value 1 -Type DWORD 

$DevicesWithProblems = Get-CimInstance -Class Win32_PnpEntity -ComputerName $IOPI_INT_All_HyperVServerNames -Namespace Root\CIMV2 | Where-Object {$_.ConfigManagerErrorCode -gt 0 } 
$DeviceListWithProblems = @()
foreach ($Device in $DevicesWithProblems) {
  $vendorID = ($device.DeviceID | Select-String -Pattern 'VEN_....' | Select-Object -expand Matches | Select-Object -expand Value) -replace 'VEN_',''
  $deviceID = ($device.DeviceID | Select-String -Pattern 'DEV_....' | Select-Object -expand Matches | Select-Object -expand Value) -replace 'DEV_',''
  $DeviceListWithProblems += [pscustomobject][ordered]@{
    'ComputerName' = $Device.PSComputerName
    'Name' = $Device.Name
    'HardwareID' = $Device.DeviceID
    'StatusCode' = $Device.ConfigManagerErrorCode
    'Description' =  switch ($($Device.ConfigManagerErrorCode)) {
      '1'       { 'This device is not configured correctly.' }
      '3'       { 'The driver for this device might be corrupted, or your system may be running low on memory or other resources.'}
      '10'      { 'This device cannot start.'}
      '12'      { 'This device cannot find enough free resources that it can use. If you want to use this device, you will need to disable one of the other devices on this system.'}
      '14'      { 'This device cannot work properly until you restart your computer.' }
      '16'      { 'Windows cannot identify all the resources this device uses.	' }
      '18'      { 'Reinstall the drivers for this device.' }
      '19'      { 'Windows cannot start this hardware device because its configuration information (in the registry) is incomplete or damaged.' }
      '21'      { 'Windows is removing this device.' }
      '22'      { 'This device is disabled.' }
      '24'      { 'This device is not present, is not working properly, or does not have all its drivers installed.' }
      '28'      { 'The drivers for this device are not installed.' }
      '29'      { 'This device is disabled because the firmware of the device did not give it the required resources.	' }
      '31'      { 'This device is not working properly because Windows cannot load the drivers required for this device.' }
      '32'      { 'A driver (service) for this device has been disabled. An alternate driver may be providing this functionality.	' }
      '33'      { 'Windows cannot determine which resources are required for this device.' }
      '35'      { 'Your computers system firmware does not include enough information to properly configure and use this device. To use this device, contact your computer manufacturer to obtain a firmware or BIOS update.	'}
      '36'      { 'This device is requesting a PCI interrupt but is configured for an ISA interrupt (or vice versa). Please use the computers system setup program to reconfigure the interrupt for this device.' }
      '37'      { 'Windows cannot initialize the device driver for this hardware.	' }
      '38'      { 'Windows cannot load the device driver for this hardware because a previous instance of the device driver is still in memory.	' }
      '39'      { 'Windows cannot load the device driver for this hardware. The driver may be corrupted or missing.' }
      '40'      { 'Windows cannot access this hardware because its service key information in the registry is missing or recorded incorrectly.' }
      '41'      { 'Windows successfully loaded the device driver for this hardware but cannot find the hardware device.	' }
      '42'      { 'Windows cannot load the device driver for this hardware because there is a duplicate device already running in the system.' }
      '43'      { 'Windows has stopped this device because it has reported problems.' }
      '44'      { 'An application or service has shut down this hardware device.	' }
      '45'      { 'Currently, this hardware device is not connected to the computer.	' }
      '46'      { 'Windows cannot gain access to this hardware device because the operating system is in the process of shutting down.	' }
      '47'      { 'Windows cannot use this hardware device because it has been prepared for safe removal, but it has not been removed from the computer.	' }
      '48'      { 'The software for this device has been blocked from starting because it is known to have problems with Windows. Contact the hardware vendor for a new driver.	' }
      '49'      { 'Windows cannot start new hardware devices because the system hive is too large (exceeds the Registry Size Limit).	' }
      '52'      { 'Windows cannot verify the digital signature for the drivers required for this device.' }
      default { 'anything else'}
    }
    'vendorID' = if ($vendorID.Length -gt 0) {$vendorID} Else {''}
    'deviceID' = if ($deviceID.Length -gt 0) {$deviceID} Else {''}
    'pcidatabaseUrl' = if ($deviceID.Length -gt 0) {"http://www.pcidatabase.com/search.php?device_search_str=$deviceID&device_search=Search"} Else {''}
  }
}
$DeviceListWithProblems

###############################################
$Server2012R2ImageIndexes  = @{'Windows Server 2012 R2 SERVERSTANDARDCORE'='1';'Windows Server 2012 R2 SERVERSTANDARD'='2';'Windows Server 2012 R2 SERVERDATACENTERCORE'='3';'Windows Server 2012 R2 SERVERDATACENTER'='4'}
$Server2016TP4ImageIndexes = @{'Windows Server 2016 Technical Preview 4 SERVERSTANDARDCORE'='1';'Windows Server 2016 Technical Preview 4 SERVERSTANDARD'='2';'Windows Server 2016 Technical Preview 4 SERVERDATACENTERCORE'='3';'Windows Server 2016 Technical Preview 4 SERVERDATACENTER'='4'}

#Getting licensing status
Get-CimInstance SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" | Where-Object licensestatus -eq 1

#Server Core Powershell as Default
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon' -Name Shell -Value 'PowerShell.exe -noexit -Command "$psversiontable; cd $env:userprofile"'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon' -Name Shell -Value 'cmd.exe'

([ADSI]"WinNT://$_/$localGroupName,group").Invoke('Add', "WinNT://$userDomain/$userName") 
([ADSI]'WinNT://./Administrators,group').Invoke('Add', "WinNT://$userDomain/$userName") 

Install-WindowsFeature -Vhd 'D:\VHD\SVR2012R2_Standard.vhdx' -Name 'Net-Framework-Core' -Source 'D:\Install\en_windows_server_2012_r2_x64_dvd_2707946\sources\sxs'

$null = New-Item -Path "$Env:HOMESHARE\Daten\WindowsPowerShell" -ItemType Directory -ErrorAction SilentlyContinue
Get-WindowsImage -Imagepath E:\Sources\install.wim
Install-WindowsFeature xyz -Source wim:e:\sources\install.wim:4

#Enable IIS in Windows 8.1
Enable-WindowsOptionalFeature -online -featurename IIS-WebServerRole

#Core <--> Full
Get-WindowsImage -ImagePath D:\sources\install.wim
Install-WindowsFeature Server-Gui-Mgmt-Infra,Server-Gui-Shell -Restart -Source wim:d:\sources\install.wim:4  #Core to Full
Uninstall-WindowsFeature Server-Gui-Mgmt-Infra,Server-Gui-Shell -Restart #Full to Core

$AdminGroupName = (Get-WMIObject Win32_Group -filter "LocalAccount=True AND SID='S-1-5-32-544'").Name
$LocalAdminName = (Get-CimInstance Win32_UserAccount -Filter "LocalAccount = 'true' AND SID Like 'S-1-5-21%-500'").Name

#Rename Local account
(Get-WmiObject Win32_UserAccount | Where-Object{$_.Name -eq $old}).Rename($new)
net.exe user $new /fullname:$newFullName
Rename-Item C:\Users\$old $new
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object{ $_.ProfileImagePath -eq "C:\Users\$old"} | Set-ItemProperty -Name ProfileImagePath -Value "C:\Users\$new"

#Off Shutdown Event Tracking
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Name 'ShutdownReasonOn' -Value 0x00000000

#disable ShutdownEventTracker
if ((Get-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability").ShutdownReasonOn -eq 0 ) {
  Set-ItemProperty -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name ShutdownReasonOn -Value 0 -Type DWORD
} else {
  New-ItemProperty -Type DWord -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -value "0"
}
(get-ItemProperty -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name ShutdownReasonOn).ShutdownReasonOn

#disable Authorized personnel only
Set-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticecaption -Value "Volkswagen Financial Services AG" -Type STRING   
Set-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticetext -Value "" -Type STRING
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system' -Name 'disablecad' -Value 1  
(Get-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticecaption).legalnoticecaption
(Get-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticetext).legalnoticetext

#Enable Remote Desktop 
$null = (Get-WmiObject -Class 'Win32_TerminalServiceSetting' -Namespace root\cimv2\terminalservices).SetAllowTsConnections(1)
$null = netsh.exe advfirewall firewall set rule group="Remote Desktop" new enable=yes
cscript.exe "$Env:WINDIR\System32\Scregedit.wsf" /ar 0    # Enable Remote Desktop
cscript.exe "$Env:WINDIR\System32\Scregedit.wsf" /cs 0    # Enable older Clients (not only for NLA)

New-NetFirewallRule -Enabled True -LocalPort 25565 -RemoteAddress any -displayName minecraft -Protocol tcp

#Create text file on the desktop for all users
$root = Split-Path $env:USERPROFILE
Resolve-Path $root\*\Desktop | ForEach-Object {
  $Path = Join-Path -Path $_ -ChildPath 'hello there.txt'
  'Here is some content...' | Out-File -FilePath $Path
  Write-Warning "Creating $Path"
}

Add-WindowsFeature Server-Gui-Mgmt-Infra -Restart
Add-WindowsFeature Server-GUI-Shell
Remove-WindowsFeature Server-Gui-Mgmt-Infra -Restart
Remove-WindowsFeature Server-GUI-Shell

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\TCPIP\Parameters' -Name 'SearchList' -Type String -Value 'pc-stagge.local'
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\ServerManager\Oobe' -Name 'DoNotOpenInitialConfigurationTasksAtLogon' -Value '1'
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\ServerManager\' -Name 'DoNotOpenServerManagerAtLogon' -Value '1'

ServerWerOptin.exe /disable  #Disable Error Reporting
ServerCeipOptin.exe /disable  #Disable Customer Experience Improvement Program 

(Get-WmiObject Win32_CDRomDrive).Drive | %{$a = mountvol.exe $_ /l;mountvol.exe $_ /d;$a = $a.Trim();mountvol.exe x: $a}

Set-ItemProperty -Path 'HKCU:\Console' -Name QuickEdit -Value 0
Set-ItemProperty -Path 'HKCU:\Console' -Name ScreenBufferSize -Value 32768500
Set-ItemProperty -Path 'HKCU:\Console' -Name WindowSize -Value 2949240
Set-ItemProperty -Path 'HKCU:\Console' -Name DisableUNCCheck -Value 1 

# Registry für IE ESC
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value '0'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value '0'

$user = [adsi]'WinNT://./Administrator'
$user.UserFlags.value = $user.UserFlags.value -bor 0x10000
$user.CommitChanges()
#Delete local User
([adsi]'WinNT://.').Delete('User','zz_acuser')

cscript.exe $Env:Windir\system32\slmgr.vbs -ipk 38JWW-M4Y6M-JR4J9-JDVHV-C8397   #Server 2008 R2 Enterprise RTM Technet Key
cscript.exe $Env:Windir\system32\slmgr.vbs -ipk WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY   #Server 2016 Standard
cscript.exe $Env:Windir\system32\slmgr.vbs -ato

Set-Item WSMan:\localhost\Client\TrustedHosts * -Force
Get-Item WSMan:\localhost\Client\TrustedHosts 
Restart-Service winrm -force

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Add-Computer  -DomainName 'pc-stagge.local' -OUPath 'OU=Server,OU=PC-Stagge,DC=Stagge,DC=local' -Credential $MyDomainAdminCredential

Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 0 

#Server Installation als VHD Boot
diskpart.exe  / Select disk / create partiontion primary / Format fs=ntfs label 'Data' quick / Assign letter=c
neue Console Shift+ F10 / c: / mkdir VHDs /Exit
List disk / List volume / select volume
create vdisk file="C:\VHDs\Server2012.vhd" maximum=69632 type=fixed
Select-Object vdisk file="C:\VHDs\Server20120.vhd" / Attach vdisk / Exit
weiter installieren und neue Partition auswählen
