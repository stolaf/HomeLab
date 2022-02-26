Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Start-Process 'https://chocolatey.org/'

## Enable Choco Global Confirmation
Write-Host -ForegroundColor Cyan "Enabling global confirmation to streamline installs"
choco feature enable -n allowGlobalConfirmation
choco upgrade chocolatey

#Common Installations
'choco-upgrade-all-at-startup', 'brave', 'chromium', 'deepl', 'notepadplusplus', '7zip.install', 'treesizefree', 'greenshot', 'cpu-z', 'nextcloud-client', 'sysinternals', 'ccleaner' | Foreach-Object { choco install $_ }

#Olaf allgemein
'prusaslicer', 'obs-studio', 'etcher', 'crystaldiskinfo', 'putty.install', 'winscp.install', 'citrix-receiver', 'royalts', 'teamviewer', 'javaruntime', 'filezilla', 'powershell-core', 'openssh', 'skype', 'bitwarden' | Foreach-Object { choco install $_ }
'speedfan' | Foreach-Object { choco install $_ }

#Olaf Development
'azure-data-studio', 'dotnet-5.0-sdk', 'mqttfx', 'bitwarden-cli', 'arduino', 'python3', 'git', 'github-desktop', 'nodejs.install', 'vscode', 'vscode-powershell', 'vscode-csharp', 'vscode-icons', 'vscode-gitlens', 'vscode-docker', 'vscode-mssql', 'vscode-markdownlint' | Foreach-Object { choco install $_ }
'microsoft-windows-terminal'

#Office / Graphic
'foxitreader', 'libreoffice-fresh', 'thunderbird', 'gimp', 'inkscape', 'vlc' | Foreach-Object { choco install $_ }

#Update
choco outdated
choco upgrade all

#HP CLJM477 Scan
Start-Process 'https://support.hp.com/de-de/drivers/selfservice/hp-color-laserjet-pro-mfp-m477-series/7326560'

#KNX ETS 5 manuelle Installation
Start-Process 'https://www2.knx.org/lu-de/software/ets/herunterladen/index.php'

#WISO Vermieter manuelle Installation
Start-Process 'https://www.buhl.de/produkte/wiso-vermieter'

#Sebastian
choco install openoffice

#Cortana Bingsuche abschalten
New-NetFirewallRule -DisplayName "Block Cortana Outbound Traffic" -Direction Outbound -Program "C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe" -Action Block

#PowerShell
Import-Module -Name PowerShellGet -ErrorAction Stop
Import-Module -Name PackageManagement -ErrorAction Stop
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Get-PSRepository -Name "PSGallery"
Install-Module ISESteroids -Scope CurrentUser
mkdir "$ENV:APPDATA\ISESteroids\License"
$LicenceFile = "$ENV:APPDATA\ISESteroids\License\License.license"
'1hGEBGGRBgGXSs8BAQAAAwBAAE9sYWZfU3RhZ2dlI0ZyZWUjb2xhZi5zdGFnZ2VAaG90bWFpbC5kZSMyOC4wMy4yMDE0IDE2OjA0OjIzI2ZyZWUBBABAMnzJCwAAAFi2IOvllODrz7guIUnfNRZPvVlp5Qd0dIVr/mhEOx2kHDBqvygOgEs5RWH3xP4ST5L6WBLqQ/BRi7vjvLA8l9i1KQF7kIGSKFE7M7qgKvf3T7m/0qm1V5bR8RVYb4t2ScnvOvBbdX2NhZe4HB76orMUycatsqz8HHMq32hqfJFum7lQf6duiFdSDSGRizM0F2BZ/zmGlE7jDMGWO6wXdO7oljfIBPk7jYGAknbsAulGFrZtngVLUGrJMfjAuaI8lwGqqHJ21AUmgURMF1fZV6bY/mS87VKwVoH0dqgwn1h+clbRdmstC1kFA2TZzGEGeCERWaiKOEEtqboHzjvnW7RiNidU1CCbu/AqdpIRmOAHVkSj0auw/7IUQB1+G/c0BScFhtMtokMdRCjvogTo956stlkfn/ChXFsPVzmSUTHKdHd2yLLdte7noYp4ZYjA93jhk+Aeo+IE0ZyGpb0np2chYpgeKW8bRCehT1duH3M+oFu4iwuRskiExn1C6L11' | Out-File -FilePath $LicenceFile
Start-Steroids

Install-Module -Name 'PoshKeePass' -Scope CurrentUser
Install-Module -Name 'PowerShellLogging' -Scope CurrentUser
Install-Module -Name 'PSScriptAnalyzer' -Scope CurrentUser -Force
Install-Module -Name 'ImportExcel' -Scope CurrentUser -Force
Install-Module -Name 'PSWindowsUpdate' -Scope CurrentUser -Force
Install-Module -Name '7Zip4Powershell' -Scope CurrentUser -Force
Install-Module -Name 'Pester' -Scope CurrentUser -Force
Install-Module -Name 'PlatyPS' -Scope CurrentUser -Force
Install-Module -Name 'NTFSSecurity' -Scope CurrentUser -Force
Install-Module -Name 'oh-my-posh' -Scope CurrentUser 

Get-WindowsCapability -Online -Name rsat* | Add-WindowsCapability -Online
Get-WindowsCapability -Online -Name * | Where-Object { $_.State -match 'Installed' } | Select-Object -Property DisplayName, State
Get-WindowsCapability -Online -Name 'App.Support.QuickAssist*' | Remove-WindowsCapability -Online # RemoteAssistant
Get-WindowsCapability -Online -Name 'Hello.Face*' | Remove-WindowsCapability -Online   # Gesichtserkennung
Get-WindowsCapability -Online -Name 'Browser.InternetExplorer*' | Remove-WindowsCapability -Online   # IE11
Get-WindowsCapability -Online -Name 'Media.WindowsMediaPlayer*' | Remove-WindowsCapability -Online
Get-WindowsCapability -Online -Name 'OneCoreUAP.OneSync*' | Remove-WindowsCapability -Online  # Exchange Active Sync
Get-WindowsOptionalFeature -Online | Sort-Object FeatureName | Format-Table -AutoSize
Enable-WindowsOptionalFeature -Online -FeatureName 'HypervisorPlatform' -All
Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' -All
Enable-WindowsOptionalFeature -Online -FeatureName 'Containers' -All
Enable-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform' -All
Disable-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2'
Disable-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2Root'
Disable-WindowsOptionalFeature -Online -FeatureName 'WorkFolders-Client'
Disable-WindowsOptionalFeature -Online -FeatureName 'Internet-Explorer-Optional-amd64'

#letzte Powershell Core Version installieren,  funktioniert nicht!!!
# https://github.com/PowerShell/PowerShell/releases
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Preview"
Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -daily"

#MS Ondrive aus Explorer entfernen
$Null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Force
Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Force

git config --global user.email "olaf.stagge@posteo.de"
git config --global user.name "olaf.stagge@posteo.de"

Set-Service beep -StartupType disabled
Stop-Servie beep

$Null = New-Item -Path "$ENV:APPDATA\Code\User\Snippets\powershell.json" -ItemType File -ErrorAction SilentlyContinue
# https://gist.github.com/rkeithhill/60eaccf1676cf08dfb6f
# https://germanpowershell.com/visual-studio-code/

Copy-Item -Path '.\powershell\vscode\mypowershell.json' -Destination "$ENV:APPDATA\Code\User\Snippets\powershell.json" -Force
psedit "$ENV:APPDATA\Code\User\Snippets\powershell.json"

Copy-Item -Path '.\powershell\vscode\mysettings.json' -Destination "$ENV:USERPROFILE\AppData\Roaming\Code\User\settings.json" -Force
psedit "$ENV:USERPROFILE\AppData\Roaming\Code\User\settings.json"

copy-Item -Path '.\powershell\vscode\mykeybindings.json' -Destination "$ENV:USERPROFILE\AppData\Roaming\Code\User\keybindings.json" -Force
psedit "$ENV:USERPROFILE\AppData\Roaming\Code\User\keybindings.json"

copy-Item -Path '.\powershell\ise_profile.ps1' -Destination "$ENV:USERPROFILE\NextCloud\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1" -Force
psedit "$ENV:USERPROFILE\NextCloud\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1"


$Query = "CREATE TABLE NAMES (fullname VARCHAR(20) PRIMARY KEY, surname TEXT, givenname TEXT, BirthDate DATETIME)"
$DataSource = "C:\Names.SQLite"

Invoke-SqliteQuery -Query $Query -DataSource $DataSource

#https://newyear2006.wordpress.com/2020/06/01/windows-subsystem-fr-linux-wsl2-unter-windows-10-2004-per-kommandozeile-installieren/
#https://docs.microsoft.com/de-de/windows/wsl/install-win10
#https://docs.microsoft.com/de-de/windows/wsl/install-on-server
#Install WSL2
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Restart-Computer
Start-BitsTransfer https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi .\wsl_update_x64.msi
wsl  –set-default-version 2

Start-BitsTransfer 'http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/39d871ba-2d91-4a27-a78e-4c45a7b249e8?P1=1590686270&P2=402&P3=2&P4=L1kXMuTbGCiLPIYl8Dpy3XOBX2DgFV2VQF/r2X4CDU2H/rNVNdLksOKLNrZjJ0qk7mc6YaWEH3XqdlYjHcjoow==' –Destination Ubuntu.ZIP
Expand-Archive Ubuntu.ZIP   # Version enthält X64 und ARM64!
cd Ubuntu
Rename-Item .\Ubuntu_2004.2020.424.0_x64.appx ubuntu.zip
cd Ubuntu
.\ubuntu.exe

#Windows 11 Explorer Kontextmenue mit Shift+F10
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve  #oder
Get-Process explorer | Stop-Process

# Systemeigenschaften / Computerschutz aktivieren damit Checkpoints erstellt werden können

#Suche nur lokal
$Null = New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction Continue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord -force

# Telemetrie deaktivieren
Get-Service -Name 'DiagTrack' | Stop-Service | Set-Service -StartupType Disabled

# RegEx Match Strings
$matchPostalCodeUS = '\d{5}'                        # Matches 12345
$matchPostalCodePlus4US = '\d{5}-\d{4}'             # Matches 12345-6789
$matchPhoneUS = '\d{3}-\d{3}-\d{4}'                 # Matches 555-55-5555
$matchTaxpayerIdUS = '\d{3}-\d{2}-\d{4}'            # Matches 111-22-3333

$matchPostalCodeUK = '[A-Z]{2}\d[A-Z] \d[A-Z]{2}'   # Matches AA0A 1AA
$matchPhoneUK = '\(\d{3}\) \d{4} \d{4}'             # Matches (111) 2222 3333
$matchTaxpayerIdMatch = '\d{5} \d{5}'               # Matches 12345 67890

$matchDateYYYYMMDD = '\d{4}-\d{2}-\d{2}'            # Matches 2020-01-01
$matchTimeHHMMSS = '\d{2}:\d{2}:\d{2}'              # Matches 23:59:59
$matchTimeHHMMSSAMPM = '\d{2}:\d{2}:\d{2} [AP]M'    # Matches 12:59:59 PM



      