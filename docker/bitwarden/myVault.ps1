Import-Module -Name Microsoft.PowerShell.SecretManagement
# Set-Secret -Name myBitwarden -Secret (Get-Credential -UserName 'olaf.stagge@posteo.de' -Message 'Input my Bitwarden Credential') -Vault CredMan
# Set-Secret -Name 'fs01\dkx8zb8' -Secret (Get-Credential -UserName 'fs01\dkx8zb8' -Message 'Input my fs01\dkx8zb8 Credential') -Vault CredMan
$myBitwarden = Get-Secret -Name myBitwarden -Vault CredMan
$dkx8zb8 = Get-Secret -Name 'fs01\dkx8zb8' -Vault CredMan

$BW_Session = bw login $($myBitwarden.UserName) $($myBitwarden.GetNetworkCredential().Password)
$BW_Session = $BW_Session | ForEach-Object {$_ | Where-Object {$_ -match 'env:'}}
$BW_Session = $BW_Session.TrimStart('> ')
Invoke-Expression -Command $BW_Session

bw get password 'fs01\dkx8zb8'
$dkx8zb8 = bw get item '2a41a816-6bc4-4d08-87c3-9fed7e5a83b7' | ConvertFrom-Json  # fs01\dkx8zb8
$dkx8zb8.login.username
$dkx8zb8.login.password


