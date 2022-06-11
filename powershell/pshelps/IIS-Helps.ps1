#IIS Warm UP 
Import-Module WebAdministration
$webs = Get-WebApplication

Set-ItemProperty 'IIS:\Sites\Default Web Site' -name applicationDefaults.preloadEnabled -value True
foreach ($appPool in Get-ChildItem IIS:\AppPools\) {
    $appPool.startMode = 'AlwaysRunning'
    $appPool | Set-Item
}

# Applicationpool: Idle Time-out=0 setzen
Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{idletimeout='0'}

# Applicationpool maximum worker processes = 2 setzen
Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel -value @{maxProcesses=2}

#Mangage Website Bindings  https://4sysops.com/archives/manage-iis-website-bindings-in-powershell/
Get-Website -Name 'Default Web Site'
Get-WebBinding -Name 'Default Web Site'
Set-WebBinding -Name 'Default Web Site' -BindingInformation "*:80:" ‑PropertyName Port -Value 81
Get-WebBinding -Name 'Default Web Site'
New-WebBinding -Name 'Default Web Site' -Protocol http -Port 82
Get-WebBinding -Name 'Default Web Site'

$cert = Get-ChildItem cert:\localmachine\my
$cert
$bindingInfo = "IIS:\SSLBindings\*!445"
$cert | Set-Item -Path $bindingInfo
