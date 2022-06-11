break

Get-PSRepository -Name PSGallery | Select *
Register-PSRepository -Name 'FileShareRepository' -SourceLocation '\\fsdebsgv4911\iopi_sources$\PowerShell\PSRepository' -InstallationPolicy Trusted
Get-PSRepository -Name 'FileShareRepository' | Select *
Publish-Module -Name '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI' -Repository 'FileShareRepository' 
Find-Module -Repository 'FileShareRepository'
Get-Module -Name 'IH-IOPI' | Install-Module -Scope CurrentUser

# start https://blogs.msdn.microsoft.com/powershell/2016/04/04/dsc-resource-kit-update/?wt.mc_id=DX_59380
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Verbose -Force

$myProxyCredential = Get-Credential -Message 'Input Proxy Credential'
$null = netsh winhttp import proxy source=ie
$webclient = New-Object System.Net.WebClient
$webclient.Proxy.Credentials=$myProxyCredential

#proxy wieder entfernen sonst kein PS Remoting
netsh winhttp reset proxy  #as Admin
netsh winhttp show proxy

Register-PSRepository -Default #ab Powershell 5.1  PSGallery Repository registrieren 
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Get-PSRepository 
Get-PackageSource 
Save-Module -Name 'Visio' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'CredentialManager' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xDismFeature' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xMySql' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xStorage' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xWebDeploy' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xWinEventLog' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xWindowsUpdate' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xSmbShare' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xSystemSecurity' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xDSCDomainjoin' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xDSCFirewall' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xEventlog' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xFailOverCluster' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xFirefox' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xRobocopy' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xExchange' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xHyper-V' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xNetworking' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xPSDesiredStateConfiguration' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xSQLServer' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xWebAdministration' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xCertificate' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xComputerManagement' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xCredSSP' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xDhcpServer' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xDnsServer' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'x7Zip' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'xActiveDirectory' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'NTFSSecurity' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'ISESteroids' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name '7Zip4Powershell' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'CredentialManager' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'DeployImage' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'PowerShellLogging' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'PSWindowsUpdate' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'PSScriptAnalyzer' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'ImportExcel' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'Pscx' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'Add-HostFileEntry' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'Convert-WindowsImage' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'GitHubProvider' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'IconExport' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'LocalAccountManagement' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'NanoServerPackage' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'PSSQLite' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'SSH' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'UserProfile' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'vscode' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'VSTS' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'WakeOnLan' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery
Save-Module -Name 'WmiEvent' -Path '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\PowerShell\Modules' -Repository PSGallery

Install-PackageProvider PowerShellGet -MinimumVersion '2.8.5.201' -Force
Import-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Find-Module LocalAccounts
Find-Module -Repository PSGallery
Find-Module -Repository PSGallery -Name 'Visio'
Find-Package *
Install-Module -Name NTFSSecurity -Scope CurrentUser -Force

Find-Module -Tag DSCResourceKit 
Install-Module -Name xWebAdministration
Install-Module -Name xHyper-V -Scope CurrentUser -Verbose
Update-Module ISESteroids

Find-Package | Sort-Object -Property Name | Export-Csv -Delimiter ';' -NoTypeInformation -Path 'C:\Temp\Packages.csv'