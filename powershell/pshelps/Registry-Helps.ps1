break
#New Key and Value
(New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search').SetValue('AllowCortana',0,'DWord')

#Convert PowerShell Path to Standard Path
Convert-Path HKLM:\SOFTWARE\Microsoft

Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\* | Select-Object pschildname

[System.Environment]::ExpandEnvironmentVariables('%username%')
[System.Environment]::ExpandEnvironmentVariables('%computername%')

$path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
$key = Get-Item -Path $path 
$key.GetValue('DevicePath', '', 'DoNotExpandEnvironmentNames')  
$key.GetValueKind('DevicePath')

Get-ChildItem Registry::
Get-ChildItem Registry::HKEY_CLASSES_ROOT
New-PSDrive HKCR Registry Registry::HKEY_CLASSES_ROOT
New-PSDrive HKU Registry HKEY_USERS

Set-ItemProperty -Path HKCU:\Software -Name testvalue -Value 12 -Type String | Binary | ExpandString | DWord | ExpandString | MultiString | QWord

#Load registry user hive
reg.exe /load HKU\Testuser c:\users\tom\ntuser.dat
Get-ChildItem Registry::HKEY_USERS\Testuser\Software

#Copy registry Hives
mkdir Registry::HKCU\Software\Testkey
Copy-Item -Path Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall -Destination Registry::HKCU\Software\Testkey -Recurse

#Determining Registry Value Data Type
$RegKey = Get-Item 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion'
$RegKey.GetValueKind('RegisteredOwner')
$RegKey.GetValueKind('DigitalProductID')

get-childitem 'REGISTRY::HKEY_CLASSES_ROOT\ClSID\*\ProgID'
get-childitem 'REGISTRY::HKEY_USERS'

#List all Registry Provider
Get-PSDrive -PSProvider registry

#Export Reg-Key to XML
Get-ChildItem 'HKCU:\Software\Microsoft\Active Setup' -Recurse | Export-Clixml -Path c:\fso\active.xml

#Change reg Value rekursive
$searchText = '\\s093j588\\'
$searchText1 = $searchText.Replace('\\','\')
$replaceText = '\staggeo\'

# NOTE: RemoteRegistry Service needs to run on target system!
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine','cs-web1')
$key = $reg.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
$key.GetSubKeyNames() | ForEach-Object {
  $subkey = $key.OpenSubKey($_)
  $i = @{}
  $i.Name = $subkey.GetValue('DisplayName')
  $i.Version = $subkey.GetValue('DisplayVersion')
  New-Object PSObject -Property $i
  $subkey.Close()
}
$key.Close()
$reg.Close()

#region Registry Permission
#Set Registry Permission
$Acl = Get-Acl 'HKLM:\SOFTWARE\Test'
#"FullControl,ReadKey,SetValue"
$AccessRule = New-Object System.Security.AccessControl.RegistryAccessRule("$Env:UserDomain\roehlico",'SetValue','ContainerInherit,ObjectInherit','none','Allow')
$Acl.SetAccessRule($AccessRule) 
$Acl | Set-Acl -Path 'HKLM:\SOFTWARE\Test'

$Acl = Get-Acl 'HKLM:\Software\Test'
#$me = [System.Security.Principal.NTAccount]"$env:userdomain\roehlico"
#$#acl.SetOwner($me)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule('Users','WriteKey','None','None','Deny')
$acl.RemoveAccessRule($rule)
Set-Acl 'HKLM:\Software\Test' $acl 
set-owner $(new-object security.principal.ntaccount 'cm\roehlico') 'HKLM:\Software\Test'

$Acl = Get-Acl "Registry::HKEY_USERS\$UserName"
#"FullControl,ReadKey,SetValue"
$AccessRule = New-Object System.Security.AccessControl.RegistryAccessRule("$Env:UserDomain\$UserName",'FullControl','ContainerInherit,ObjectInherit','none','Allow')
$Acl.SetAccessRule($AccessRule) 
$Acl | Set-Acl -Path "Registry::HKEY_USERS\$UserName"
#endregion Registry Permission
