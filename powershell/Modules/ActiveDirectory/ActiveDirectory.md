# ActiveDirectory
#ActiveDirectory  #pwsh

## ACL
http://blogs.technet.com/b/heyscriptingguy/archive/2012/03/12/use-powershell-to-explore-active-directory-security.aspx
```powershell
(Get-ACL "AD:$((Get-ADComputer -Identity $ComputerName).distinguishedname)").Access
$dist = (Get-ADComputer -Identity $ComputerName).distinguishedname
dsacls.exe $dist /G mgmt\DKX1S67170:GA

```

## AD Replication
https://4sysops.com/archives/repadmin-vs-powershell-replication-cmdlets/
```powershell
Get-ADReplicationFailure -scope SITE -target Default-First-Site-Name | ft Server,FirstFailureTime, FailureClount, LastError, Partner -AUTO
Get-ADReplicationPartnerMetadata -Target * -Partition * | Select-Object Server,Partition,Partner,ConsecutiveReplicationFailures,LastReplicationSuccess,LastRepicationResult

#check AD Replication
repadmin.exe /replsummary
repadmin.exe /replsum * /bysrc /bydest /sort:delta
repadmin.exe /showrepl * /CSV

New-ADReplicationSiteLink CORPORATE-BRANCH1 -SitesIncluded CORPORATE,BRANCH1-OtherAttributes @{'options'=1}
Set-ADReplicationSiteLink CORPORATE-BRANCH1 -Cost 100 -ReplicationFrequencyInMinutes 15
Get-ADReplicationUpToDatenessVectorTable * | Sort-Object Partner,Server | Format-Table Partner,Server,UsnFilter
```

## ADSI
```powershell
#Active Directory users that actually have a mail address
$searcher = [ADSISearcher]"(&(sAMAccountType=$(0x30000000))(mail=*))"
#Active Directory users that actually have no mail address
$searcher = [ADSISearcher]"(&(sAMAccountType=$(0x30000000))(!(mail=*)))"
$searcher.FindAll() | ForEach-Object { $_.GetDirectoryEntry() } | Select-Object -Property sAMAccountName, name, mail 

$searcher = [ADSISearcher]'(&(objectClass=User)(objectCategory=person)(sAMAccountName=olaf*))'
$searcher.FindOne()
$searcher.FindAll()
$searcher.FindAll() | Select-Object -ExpandProperty Path

$searcher = [ADSISearcher]'(&(objectClass=User)(objectCategory=person)(sAMAccountName=*))' 
$searcher.SizeLimit = 10 # get 10 results max
$searcher.FindAll() | % { $_.GetDirectoryEntry() } | Select-Object -Property * | Out-GridView

$searcher = [ADSISearcher]'(&(objectClass=User)(objectCategory=person)(sAMAccountName=olaf*))' 
$searcher.PageSize = 1000 
$domain = New-Object System.DirectoryServices.DirectoryEntry('DC=cs-stagge,DC=local')
$searcher.SearchRoot = $domain 
$searcher.FindAll() | ForEach-Object { $_.GetDirectoryEntry() } | Select-Object -Property * 

$searcher = [ADSISearcher]"(&(objectClass=User)(objectCategory=person)(sAMAccountName=$env:username))"
$user = $searcher.FindOne().GetDirectoryEntry() 
$binarySID = $user.ObjectSid.Value
$stringSID = (New-Object System.Security.Principal.SecurityIdentifier($binarySID,0)).Value 
$stringSID

$SID = 'S-1-5-21-1626329789-3253543307-2341566918-93991'   
$account = [ADSI]"LDAP://$SID"
$account
$account.distinguishedName

function Disable-ADComputerAccount {
  <#
      .DESCRIPTION
      Disable Computer Account without AD Powershell Module

      .EXAMPLE
      Disable-ADComputerAccount -ComputerName 'FSDEBSNE0311' -Domain 't-fs01.vwfs-ad'
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)] [string] $ComputerName,
    [string] $Domain = $Null
  )
  
  $ldap = Get-ComputerDistinguishedName -ComputerName 'FSDEBSNE0311' -Domain 't-fs01.vwfs-ad'
  if ($ldap) {
    $Computer = [adsi]"LDAP://$ldap"
    $Computer.InvokeSet("AccountDisabled", $false)
    $Computer.SetInfo()
  }
}
```

## Allgemein
```powershell
#find DHCP Server
Get-ADObject -SearchBase 'cn=configuration,dc=iammred,dc=net' -Filter "objectclass -eq 'dhcpclass' -AND Name -ne 'dhcproot'" | Select-Object name

# Standardspeicherort neuer Computerobjekte im Active Directory festlegen
redircmp.exe 'OU=Organisation Unit, DC=domain, DC=tld'

Function Test-ADCredentials {
  Param($username, $password, $domain)
  Add-Type -AssemblyName System.DirectoryServices.AccountManagement
  $ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
  $pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ct, $domain)
  New-Object PSObject -Property @{
    UserName = $username;
    IsValid = $pc.ValidateCredentials($username, $password).ToString()
  }
}

function Get-ADObject {   
  # Get-ADObject -ObjectDN 'CN=DKX0RW0,OU=LocalAdmin,OU=Users,OU=Client,OU=DE,DC=fs01,DC=vwf,DC=vwfs-ad' 
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Supply object DN')][string]$ObjectDN
  )
  return ([adsi]"LDAP://$ObjectDN")
}

function Get-ADObjects{  
  #  
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Supply object class')][string]$class,
    [Parameter(Mandatory=$true,HelpMessage='Supply the domain DNS name')][string]$domainName,
    [string]$optionalFilter
  )
  $domainContext = New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList ('Domain', $domainName)
  $domain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($domainContext)
  $root = $domain.GetDirectoryEntry()
  $ds = [adsisearcher]$root
  $ds.Filter = "(&(objectCategory=$class)$optionalFilter)"

  return $ds.FindAll()
}

function Resolve-Sid{    
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Supply the SID of the object to resolve')][string]$sid
  )
  try{
    return (New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ($sid)).Translate([Security.Principal.NTAccount]).Value
  }catch{
    return $false
  }
}

```

## Delegation
```powershell
$HostDN =  'CN=FSDEBSNE0302,OU=Server,OU=I-SBA,DC=mgmt,DC=fsadm,DC=vwfs-ad'
Set-ADObject $HostDN -Add @{'msDS-AllowedToDelegateTo'='cifs/FSDEBSEA1100.mgmt.fsadm.vwfs-ad'}
Set-ADObject $HostDN -Add @{'msDS-AllowedToDelegateTo'='cifs/FSDEBSEA1100'}
Get-ADObject 'CN=FSDEBSNE0302,OU=Server,OU=I-SBA,DC=mgmt,DC=fsadm,DC=vwfs-ad' -Properties msDS-AllowedToDelegateTo | Select-Object -ExpandProperty msDS-AllowedToDelegateTo  #Kontrolle

#Kerberos Delegation
Get-ADComputer $Hostname1 | Set-ADObject -Add @{'msDS-AllowedToDelegateTo'="Microsoft Virtual System Migration Service/$Hostname2.$Domain", "cifs/$Hostname2.$Domain","Microsoft Virtual System Migration Service/$Hostname2", "cifs/$Hostname2"} 
Get-ADComputer $Hostname2 | Set-ADObject -Add @{'msDS-AllowedToDelegateTo'="Microsoft Virtual System Migration Service/$Hostname1.$Domain", "cifs/$Hostname1.$Domain","Microsoft Virtual System Migration Service/$Hostname1", "cifs/$Hostname1"}
Set-ADObject 'CN=FSDEBSNE0324,OU=Server,OU=I-SBA,DC=mgmt,DC=fsadm,DC=vwfs-ad' -Remove @{'msDS-AllowedToDelegateTo'='cifs/FSDEBSEA1104.mgmt.fsadm.vwfs-ad','cifs/FSDEBSEA1104','cifs/FSDEBSEA1102.mgmt.fsadm.vwfs-ad','cifs/FSDEBSEA1102'}
```

## GPO
```powershell
Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer -Key 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config' -Type DWord  -ValueName 'AnnounceFlags' -Value 5 
Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer -Key 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters' -Type String -ValueName 'NtpServer' -Value $TimeServer 
Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer -Key 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters' -Type String -ValueName 'Type' -Value 'NTP' 
New-GPLink -Name $GPOName -Target $TargetOU 

New-GPO -Name 'DisableRDP'
Set-GPPrefRegistryValue -Name DisableRDP -Key 'HKLM\System\CurrentControlSet\Control\Terminal Server' -ValueName fDenyTSConnections -Value 1 -Type Dword -Context computer -Action update
New-GPLink -Name DisableRDP -Target 'dc=acme-lab,dc=com'

Set-GPRegistryValue -Name 'TestGPO' -key 'HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop' -ValueName ScreenSaveTimeOut -Type String -value 900
Set-GPRegistryValue -Name 'TestGPO' -key 'HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop' -ValueName ScreenSaveActive -Type String -value 1
Set-GPRegistryValue -Name 'TestGPO' -key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ValueName NoDesktopCleanupWizard -Type Dword -value 1
Set-GPRegistryValue -Name 'TestGPO' -key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ValueName NoStartMenuMymusic -Type Dword -value 1
```

## Groups
```powershell
 Get-ADGroup -Identity 'FS01-ADM-IHIOPI-Server-S-G' -Server 'fs01.vwf.vwfs-ad' | Get-ADGroupMember -Recursive | Get-ADUser -Properties Description, DisplayName  | Select-Object -Property SamAccountName, DisplayName, GivenName, SurName
 
 function Get-GroupMember{    
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Supply the groups distinguishedName')][string]$GroupDN
  )
  return ([adsi]"LDAP://$GroupDN") | Select-Object -ExpandProperty member
}

function Add-GroupMember{    
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Supply the groups distinguishedName')][string]$GroupDN,
    [Parameter(Mandatory=$true,HelpMessage='Supply the DN of the object to add')][string]$MemberDN
  )
  $group = [adsi]"LDAP://$GroupDN"
  $user = [adsi]"LDAP://$MemberDN"
  return $group.Add($User.path)
}

function Remove-GroupMember{    
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Supply the groups distinguishedName')][string]$GroupDN,
    [Parameter(Mandatory=$true,HelpMessage='Supply the DN of the object to remove')][string]$MemberDN
  )
  $group = [adsi]"LDAP://$GroupDN"
  $user = [adsi]"LDAP://$MemberDN"
  return $group.Remove($User.path)
}

 #Verschachtelte AD-Gruppen mit LDAP-Filter abfragen
(member:1.2.840.113556.1.4.1941:=CN=dkx8zb8adm,OU=IH-IOPI,OU=Administrators, OU=Client,OU=DE,DC=fs01,DC=vwf,DC=vwfs-ad)
#nur Sicherheitsgruppen
(&(member:1.2.840.113556.1.4.1941:=CN=dkx8zb8adm,OU=IH-IOPI,OU=Administrators, OU=Client,OU=DE,DC=fs01,DC=vwf,DC=vwfs-ad)(groupType:1.2.840.113556.1.4.803:=2147483648))

function Get-ADNestedGroupMembers {
  <#
      .DESCRIPTION
      .SYNOPSIS
      .EXAMPLE
      Get-ADNestedGroupMembers -Server 'mgmt.fsadm.vwfs-ad' -Identity 'MGMT-ADM-IHIOPI-Server-S-L' | format-table -AutoSize
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)] $Server,
    [Parameter(Mandatory=$true)] $Identity 
  )

  $AllGroupMembers = @()
  Get-ADGroup -Identity $Identity -Server $Server -Properties memberof,members | Get-ADGroupMember | % {
    if ($_.objectClass -eq 'group') {
      $GroupName = $_.Name
      $ADUsers = Get-ADGroup -Identity $_.distinguishedName -Server $Server -Properties members | Get-ADGroupMember | Get-ADUser -Properties Description, DisplayName 
      $ADUsers | % { 
        $AllGroupMembers += New-Object PSObject -Property ([ordered]@{GroupName=$GroupName;SamAccountName=$_.SamAccountName;DisplayName=$_.DisplayName;GivenName=$_.GivenName;SurName=$_.SurName;Enabled=$_.Enabled})
      }
    }
    if ($_.objectClass -eq 'user') {
      $ADUsers = Get-ADUser $_ -Properties Description, DisplayName
      $ADUsers | % { 
        $AllGroupMembers += New-Object PSObject -Property ([ordered]@{GroupName='';SamAccountName=$_.SamAccountName;DisplayName=$_.DisplayName;GivenName=$_.GivenName;SurName=$_.SurName;Enabled=$_.Enabled})
      }
    }
  }
  $AllGroupMembers | Sort-Object -Property GroupName,SamAccountName
}

```

## Installation
```powershell
Install-WindowsFeature -Name 'AD-Domain-Services' -IncludeManagementTools
Install-ADDSDomainController -DomainName "pc-stagge.local"
Test-ADDSDomainController -Domainname 'cs-stagge' -SafeModeAdministratorPassword (read-host-prompt Kennwort -assecurestring)
Install-ADDSDomainController -Domainname cs-stagge.local -SafeModeAdministratorPassword (read-host -prompt Kennwort -assecurestring)

#DC herunterstufen
UnInstall-ADDSDomainController -LocalAdministratorPassword (read-host -prompt Kennwort -assecurestring)
```

## OU
```powershell
New-ADOrganizationalUnit -Server 'mgmt.fsadm.vwfs-ad' -Name 'Hyper-V' -Path "OU=Server,OU=IH-IOPI,DC=mgmt,DC=fsadm,DC=vwfs-ad" 
```

## User
```powershell
#Find Disabled User Accounts
Search-ADAccount -AccountDisabled -UsersOnly

#Users Photo
GET-ADUSER -filter * -properties ThumbnailPhoto | Where-Object { $_.ThumbnailPhoto -eq $NULL }
$Picture=[System.IO.File]::ReadAllBytes('C:\Photos\sean.jpg')
SET-ADUser SeanK -add @{thumbnailphoto=$Picture}
$User=GET-ADUser SeanK -properties thumbnailphoto
[System.Io.File]::WriteAllBytes('C:\Photos\Export.jpg', $User.Thumbnailphoto)

#Find User
$SAMAccountName = 'Olaf'
$searcher = [adsisearcher]"(&(objectClass=user)(samAccountName=*$SAMAccountName*))"
$searcher.SearchRoot = 'LDAP://OU=customer,DC=company,DC=com'
$searcher.PageSize = 999
$searcher.SearchScope = 'OneLevel'
$searcher.FindAll() | ForEach-Object { $_.GetDirectoryEntry() } | Select-Object -Property *

$DC='192.168.1.5'
$Cred=(Get-Credential)
$CommonParameters=@{'Server'=$DC;'Credential'=$Cred}
Get-ADUser -filter * @CommonParameters

#modify a custom attribute in Active Directory: -add, -replace, and -remove 
SET-ADUSER john.smith -replace @{info='John Smith is a Temporary Contractor'}
```