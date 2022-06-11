# Microsoft.SecretManagement

#Security #pwsh

https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules

PowerShell SecretManagement supports the following secret data types:

-   byte\[\]
-   string
-   SecureString
-   PSCredentialE

Enter-PSSession DC01 -Credential (Get-Secret credmkadmin)

## Where secret stored on machine 
explorer "$ENV:USERPROFILE\AppData\Local\Microsoft\Powershell\secretmanagement"  
explorer "$ENV:LOCALAPPDATA\Microsoft\Powershell\secretmanagement"  
non windows under $Home:/.secretmanagement

## Einführung
https://github.com/johnthebrit/RandomStuff/blob/master/PowerShellStuff/PSSecretManagement.ps1

```
<#References
https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/
#>

#Install elevated
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -Scope AllUsers

#Common set of commands can use across vaults (where secrets are stored)
Get-Command -Module Microsoft.PowerShell.SecretManagement

#Commands to manage the Secret Store vault
Get-Command -Module Microsoft.PowerShell.SecretStore

#What vaults are registered
Get-SecretVault

#Can use the SecretStore as a vault
Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

#Store a secret in it
Set-Secret -Name Password1 -Secret "Pa55word"
#WILL HAVE TO ENTER A PASSWORD FIRST TIME SET SECRET for the secret store, this is to unlock the vault. Will be prompted if timed out
Get-SecretStoreConfiguration
$secureString = ConvertTo-SecureString "Password to the vault" -AsPlainText -Force
Unlock-SecretStore -Password $secureString
Set-SecretStoreConfiguration -Authentication None #don't require password to unlock. different from prompt

#Store for the files
#localstore is actual data
#secretvaultregistry has json file of configuration
Get-ChildItem $env:LOCALAPPDATA\Microsoft\PowerShell\secretmanagement
#Non windows under $HOME/.secretmanagement

Get-Secret -Name Password1 -AsPlainText
Set-Secret -Name Password1 -Secret "N3wPa55word"

#Useful later!!!
Set-Secret -Name DevSubID -Secret "YourSubID"
$AzSubID = Get-Secret -Name DevSubID -AsPlainText

#secrets can also be hash tables
Set-Secret -Name Password2 -Secret @{ username1 = "Pa55word1"; username2 = "N3verGue55"}
$creds = Get-Secret -Name Password2 -AsPlainText
$creds.username1

#Can set meta data for the SecretStore vault (note, other vaults may not support like Key Vault)
Set-SecretInfo Password1 -Metadata @{Environment = "Dev"}
Get-SecretInfo | Select-Object name, metadata


#Azure Key Vault
#Must be authenticated already with context set
$KVParams = @{ AZKVaultName = "SavillVaultRBAC"; SubscriptionId = $AzSubID}
Register-SecretVault -Module Az.KeyVault -Name KeyVaultStore -VaultParameters $KVParams

Get-SecretInfo -Vault KeyVaultStore
Get-Secret -Name Secret1 -AsPlainText #-vault if have same name over vaults


#Credential Manager (Windows Only) for current user
Install-Module -Name SecretManagement.JustinGrote.CredMan -Scope AllUsers -Force
Register-SecretVault -Module SecretManagement.JustinGrote.CredMan -Name CredManStore
Set-Secret -Name CredTest1 -Secret "WontShare" -Vault CredManStore #shows under credential manager as ps:<name>
Get-Secret -Name CredTest1 -AsPlainText

#See across all
Get-SecretInfo
```

## How to non-interactively create and configure a SecretStore

```
Install-Module -Name Microsoft.PowerShell.SecretStore -Repository PSGallery -Force
$password = Import-CliXml -Path $securePasswordPath

Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Password -PasswordTimeout 3600 -Interaction None -Password $password -Confirm:$false

Install-Module -Name Microsoft.PowerShell.SecretManagement -Repository PSGallery -Force
Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

Unlock-SecretStore -Password $password
```
## meine Experimente
$UserName = "$env:USERDOMAIN\$ENV:USERNAME"
Set-Secret -Name $UserName -Vault SecretStore -Secret (Get-Credential -UserName $UserName)
Set-Secret -Name Olaf -Secret 'Stagge' -Vault SecretStore -Metadata @{Geburtsdatum='19.08.1961'; Geschlecht='männlich'; Geburtsort='Wernigerode'}
Set-Secret MyAPIKey -Secret 'c6854da1-743d-4234-bdd0-3f9832185b01'

Get-SecretInfo -Vault SecretStore   # alle Secrets ausgeben
Get-SecretInfo -Vault SecretStore | Select-Object Name,Metadata
## Metadata

```
Set-Secret -Name foo -Secret fooSecret -Metadata @{purpose = "example"}
Set-SecretInfo bar -Metadata @{purpose = "showing the new cmdlet"}
Set-Secret -name secretMetadata -Secret @{ resource1 = "username1, subID1"; resource2 = "username, subID2"}
```

## CredMan

```
Uninstall-Module -Name SecretManagement.JustinGrote.CredMan
# Restart PSSession
Install-Module -Name SecretManagement.JustinGrote.CredMan -Repository PSGallery -Scope AllUsers

# Get-Secret -AsPlainText funktioniert derzeit nicht
```

## Keepass

https://github.com/JustinGrote/SecretManagement.KeePass

Um KeePass als Erweiterung zu verwenden, benötigen Sie nur die .kdbx-Datei. Sie müssen den Masterkey Password für jede neue PowerShell-Sitzung angeben.

```
Uninstall-Module -Name 'SecretManagement.KeePass'
# Restart PSSession
Install-Module -Name 'SecretManagement.KeePass' -Scope AllUsers -Repository PSGallery -Force
Import-Module -Name 'SecretManagement.KeePass' -Force
(Get-Module -Name 'SecretManagement.KeePass').ModuleBase
Get-Command -Module 'SecretManagement.KeePass'

Register-SecretVault -Name 'KeePass' -ModuleName SecretManagement.KeePass -VaultParameters @{
  Path = "$Env:USERPROFILE\Documents\keepass\myKeyPassWithMasterKeyOnly.kbdx"
  UseMasterPassword = $true
  #KeyPath= "path/to/my/keyfile.key"
  ShowFullTitle = $true
}

Set-SecretVaultDefault -Name KeePass
Set-Secret -Name TestSecret -Secret 'TestSecret' -Vault KeePass
Get-Secret -Name 'My secret entry 1' -VaultName 'KeePass'
```

## Azure KeyVault

```
Install-Module -Name Az.KeyVault -RequiredVersion 3.4.0

Register-SecretVault -Name AzKeyVault -ModuleName Az.KeyVault -VaultParameters @{
    AZKVaultName = 'myKeyVault'
    SubscriptionId = '79594fa7-977e-4f2b-86db-5d81c0766c57'
}
```

## Bitwarden
Version 0.1.1 eventuell derzeit nicht verwendbar!
choco install bitwarden-cli
https://github.com/Gaspack/SecretManagement.BitWarden
```
Find-Module -Name SecretManagement.BitWarden
Install-Module -Name SecretManagement.BitWarden -AllowClobber -Scope AllUsers -Force
Get-Command -module SecretManagement.BitWarden
Register-SecretVault -Name Bitwarden -ModuleName SecretManagement.BitWarden

```

## HashiCorp

```
Find-Module -Name SecretManagement.Hashicorp.Vault.KV -AllowPrerelease
```