break

#https://github.com/PSKeePass/PoShKeePass/wiki/Getting-Started

& "C:\Program Files (x86)\KeePass\KeePass.exe"
Install-Module -Name PoShKeePass -Scope CurrentUser
Get-Module -Name PoShKeePass 

Import-Module PoShKeePass -Force
(Get-Module -Name PoShKeePass).ModuleBase
Get-Command -Module PoShKeePass #-ParameterName DatabaseProfileName

$DataBaseProfileName = 'dkx8zb8adm'
Get-KeePassDatabaseConfiguration | Remove-KeePassDatabaseConfiguration -Confirm:$false
New-KeePassDatabaseConfiguration -DatabaseProfileName $DataBaseProfileName  -DatabasePath "C:\Users\dkx8zb8adm\dkx8zb8adm.kdbx" -KeyPath "C:\Users\dkx8zb8adm\dkx8zb8adm.key" 

$DataBaseProfileName = 'ih-iopi'
Get-KeePassDatabaseConfiguration | Remove-KeePassDatabaseConfiguration -Confirm:$false
New-KeePassDatabaseConfiguration -DatabaseProfileName $DataBaseProfileName  -DatabasePath ".\Modules\IH-IOPI\Ressources\ih-iopi.kdbx" -KeyPath ".\Modules\IH-IOPI\Ressources\ih-iopi.key" 

Get-KeePassDatabaseConfiguration -DatabaseProfileName $DataBaseProfileName 
Get-KeePassEntry -AsPlainText -DatabaseProfileName $DataBaseProfileName 
$KeePassEntry = Get-KeePassEntry -DatabaseProfileName $DataBaseProfileName -KeePassEntryGroupPath "$DataBaseProfileName/General"  -Title "zz_acuser" -WithCredential
	
$KeePassCredential = New-Object System.Management.Automation.PSCredential($KeePassEntry.UserName,$KeePassEntry.password)

Update-KeePassEntry -KeePassEntry $KeePassEntry -DatabaseProfileName $DataBaseProfileName -KeePassEntryGroupPath "$DataBaseProfileName/prodDB" -Title 'New Test' -KeePassPassword $(New-KeePassPassword -upper -lower -digits -length 20) -Force

Get-KeePassEntry -KeePassEntryGroupPath 'dkx8zb8/prodDB' -AsPlainText -DatabaseProfileName SecretPasswords
New-KeePassDatabaseConfiguration -DatabaseProfileName 'KeyFileDB' -DatabasePath "C:\Users\dkx8zb8adm\dkx8zb8.kdbx" -KeyPath "C:\Users\dkx8zb8adm\dkx8zb8.key"

$zz_acuser = Get-KeePassEntry -DatabaseProfileName $DataBaseProfileName -UserName 'zz_acuser' -AsPlainText
$zz_acuser.Password

New-KeePassGroup -DatabaseProfileName $DataBaseProfileName -KeePassGroupName 'Olaf' -KeePassGroupParentPath 'dkx8zb8'
New-KeePassPassword -UpperCase -LowerCase -Digits -SpecialCharacters -Length 20 -SaveAs 'Basic Password'
$Password = New-KeePassPassword -UpperCase -LowerCase -Digits -UnderScore -Length 20  #-SaveAs 'Basic Password' 
$Password.ReadString()
New-KeePassPassword -PasswordProfileName 'Basic Password' 

New-KeePassEntry -DatabaseProfileName $DataBaseProfileName -KeePassEntryGroupPath 'dkx8zb8/General' -Title 'zz_acuser' -UserName 'zz_acuser' -KeePassPassword $(ConvertTo-SecureString -String '123456' -AsPlainText -Force)

$KeePassEntry = Get-KeePassEntry -DatabaseProfileName KeyFileDB -UserName 'olaf' 
Remove-KeePassEntry -DatabaseProfileName $DataBaseProfileName -KeePassEntry $KeePassEntry[0] -Force -NoRecycle
