# poshkeepass
https://github.com/PSKeePass/PoShKeePass
https://github.com/PSKeePass/PoShKeePass/wiki/Getting-Started

! Module funktioniert derzeit nicht unter Core

```powershell
# Install-Module -Name PoShKeePass
Import-Module -Name PoShKeePass
Get-Command -Module PoshKeePass

#Supported Functions
(Get-Module PosHKeePass | Select-Object -exp ExportedCommands).Keys


#Create a database profile with the authentication type that uses a KeyFile:
New-KeePassDatabaseConfiguration -DatabaseProfileName 'KeyFileDB' -DatabasePath "C:\Users\olaf\Documents\keepass\KeyFile.kdbx" -KeyPath "C:\Users\olaf\Documents\keepass\KeyFile.key"

# Create a database profile with the authentication type that uses a KeyFile and MasterKey (aka Password):
New-KeePassDatabaseConfiguration -DatabaseProfileName 'KeyAndMasterKeyDB' -DatabasePath "C:\Users\olaf\Documents\keepass\KeyAndMaster.kdbx" -KeyPath "C:\Users\olaf\Documents\keepass\KeyAndMaster.keyx" -UseMasterKey

#Create a database profile with the authentication type that uses a KeyFile and a Windows Account:
New-KeePassDatabaseConfiguration -DatabaseProfileName 'KeyFileAndWindowsAccountDB' -DatabasePath "C:\Users\olaf\Documents\keepass\KeyFile.kdbx" -KeyPath "C:\Users\olaf\Documents\keepass\KeyFile.key" -UseNetworkAccount

#Create a database profile with the authentication type that uses a Windows Account:
New-KeePassDatabaseConfiguration -DatabaseProfileName 'WinDB' -DatabasePath "C:\Users\olaf\Documents\keepass\WindowsDB.kdbx" -UseNetworkAccount

Get-KeePassDatabaseConfiguration | Remove-KeePassDatabaseConfiguration -Confirm:$false


Get-KeePassEntry -AsPlainText -DatabaseProfileName WinDB
Get-KeePassEntry -AsPlainText -DatabaseProfileName KeyFileAndWindowsAccountDB
Get-KeePassEntry -AsPlainText -DatabaseProfileName KeyAndMasterKeyDB
Get-KeePassEntry -KeePassEntryGroupPath 'pskeepasstestdatabase/General' -AsPlainText -DatabaseProfileName KeyAndMasterKeyDB


```