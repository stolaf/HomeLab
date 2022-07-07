<#
* Mein Powershell Profile CurrentUserAllHosts $Profile.CurrentUserAllHosts
#>

function Start-mySettings {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Register-PackageSource -Name 'NuGet' -Location "http://www.nuget.org/api/v2" -ProviderName Nuget -Trusted

    if ($IsWindows) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
        $null = mkdir C:\Temp -ErrorAction SilentlyContinue

        Invoke-WebRequest 'https://github.com/stolaf/homelab/blob/main/powershell/profile_CurrentUser.AllHosts.ps1' -OutFile $($profile.CurrentUserAllHosts)

        #region FuzzySearch  https://github.com/junegunn/fzf/releases  exe File herunterladen und nach system32 kopieren
        Invoke-WebRequest 'https://github.com/junegunn/fzf/releases/download/0.30.0/fzf-0.30.0-windows_amd64.zip' -OutFile '~/Downloads/fzf.zip'
        Expand-Archive -Path "~/Downloads/fzf.zip" -DestinationPath "~/Downloads/fzf" -Force
        Copy-Item -Path '~/Downloads/fzf/fzf.exe' -Destination "$ENV:WINDIR\System32\fzf.exe" -force
        Remove-Item -Path '~/Downloads/fzf.zip' -force -EA 0
        Remove-Item -Path '~/Downloads/fzf' -Recurse -force -EA 0
        Install-Module -Name 'PSFzf' -Repository PSGallery -Scope CurrentUser -force
        #endregion FuzzySearch

        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

        #region NerdFont Installation
        Invoke-WebRequest 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip' -OutFile '~/Downloads/Meslo.zip' 
        Expand-Archive -Path "~/Downloads/Meslo.zip" -DestinationPath "~/Downloads/Meslo" -Force
        Remove-Item -Path '~/Downloads/Meslo.zip' -force -EA 0
        Explorer '~/Downloads/Meslo'
        #endregion NerdFont Installation
        #region Chocolatey 'https://chocolatey.org/'
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco feature enable -n allowGlobalConfirmation  ## Enable Choco Global Confirmation
        choco upgrade chocolatey
        'brave', 'deepl', 'notepadplusplus', 'treesizefree', 'greenshot', 'nextcloud-client', 'ccleaner', '7zip.install' | Foreach-Object { choco install $_ }
        'microsoft-windows-terminal', 'keepass', 'git' | Foreach-Object { choco install $_ }
        'prusaslicer', 'obs-studio', 'etcher', 'putty.install', 'winscp.install', 'citrix-receiver', 'royalts', 'teamviewer', 'bitwarden' | Foreach-Object { choco install $_ }
        'dotnet-6.0-sdk', 'mqttfx', 'bitwarden-cli', 'python3', 'vscode', 'vscode-powershell', 'vscode-csharp', 'vscode-icons', 'vscode-gitlens', 'vscode-docker', 'vscode-mssql', 'vscode-markdownlint' | Foreach-Object { choco install $_ }
        'foxitreader', 'libreoffice-fresh', 'thunderbird', 'gimp', 'inkscape', 'vlc' | Foreach-Object { choco install $_ }

        choco outdated
        choco upgrade all
        #endregion Chocolatey 
        
        #KNX ETS 5 manuelle Installation
        Start-Process 'https://support.knx.org/hc/de/articles/360021434999-ETS-v5-7-6'

        #WISO Vermieter manuelle Installation
        Start-Process 'https://www.buhl.de/produkte/wiso-vermieter'   # Anmelden und Software downloaden

        #region Allgemeine Windows Einstellungen
        #Cortana Bingsuche abschalten
        New-NetFirewallRule -DisplayName "Block Cortana Outbound Traffic" -Direction Outbound -Program "C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe" -Action Block

        # Systemeigenschaften / Computerschutz aktivieren damit Checkpoints erstellt werden können
        
        #Suche nur lokal
        $Null = New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction Continue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord -force

        # Telemetrie deaktivieren
        Get-Service -Name 'DiagTrack' | Stop-Service | Set-Service -StartupType Disabled

        #Windows 11 Altes Explorer Kontextmenue mit Shift+F10
        reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve  #oder
        Get-Process explorer | Stop-Process

        # Get-WindowsCapability -Online -Name rsat* | Add-WindowsCapability -Online
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
        Enable-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform' -All   # --> Restart
        
        Disable-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2'
        Disable-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2Root'
        Disable-WindowsOptionalFeature -Online -FeatureName 'WorkFolders-Client'
        Disable-WindowsOptionalFeature -Online -FeatureName 'Internet-Explorer-Optional-amd64'

        # https://docs.microsoft.com/de-de/windows/wsl/install
        wsl.exe  –set-default-version 2

        #MS Ondrive aus Explorer entfernen
        $Null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Force
        Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Force

        Set-Service beep -StartupType disabled
        Stop-Service beep
        #endregion Allgemeine Windows Einstellungen

        Install-Module -Name 'NTFSSecurity' -Scope CurrentUser -Force
    }

    if ($IsLinux) {
        sudo apt-get install fzf  
        Install-Module -Name 'PSFzf' -Repository PSGallery -Scope CurrentUser -force
        
        wget https://github.com/stolaf/homelab/blob/main/powershell/profile_CurrentUser.AllHosts.ps1 -O /home/olaf/.config/powershell/profile.ps1

        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
        mkdir ~/.poshthemes
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
        unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
        chmod u+rw ~/.poshthemes/*.json
        rm ~/.poshthemes/themes.zip

        # In Terminal Meslo Font einstellen
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip -P ~/Downloads
        unzip ~/Downloads/Meslo.zip -d ~/.fonts
        sudo fc-cache -fv

        mkdir ~/.config/powershell
    }

    git config --global user.email "olaf.stagge@posteo.de"
    git config --global user.name "olaf.stagge@posteo.de"
    
    Install-Module -Name 'z' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'PSReadLine' -AllowPrerelease -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Terminal-Icons' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Posh-Git' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'ImportExcel' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Microsoft.Powershell.SecretManagement' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Microsoft.Powershell.SecretStore' -Repository PSGallery -Scope CurrentUser -force
    # Install-Module -Name 'SecretManagement.KeePass' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'PlatyPS' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Pester' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Selenium' -Repository PSGallery -Scope CurrentUser -force
    # v2.6.2 funktioniert derzeit nicht (14.06.2022), siehe https://github.com/Badgerati/Pode/issues/965
    Install-Module -Name 'Pode' -Repository PSGallery -Scope CurrentUser -RequiredVersion 2.5.2 -force  

    #region VSCode
    $Null = New-Item -Path "$ENV:APPDATA\Code\User\Snippets\powershell.json" -ItemType File -ErrorAction SilentlyContinue
    # https://gist.github.com/rkeithhill/60eaccf1676cf08dfb6f
    # https://germanpowershell.com/visual-studio-code/

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

    #endregion VSCode
}

Write-Host "Profile Load CurrentUserAllHosts: $($Profile.CurrentUserAllHosts)" -ForegroundColor Yellow
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Import-Module -Name 'Terminal-Icons'
Import-Module -Name 'PSFzf'
Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource HistoryAndPlugin -Colors @{InlinePrediction = "$($PSStyle.Foreground.Black)$($PSStyle.Foreground.Cyan)" }
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar

$PSStyle.Formatting.TableHeader = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Green

Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

if ($IsLinux) {
    wget https://dot.net/v1/dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh -channel LTS -c Current  # -Architecture arm
    nano /home/olaf/.bashrc
    # Append export PATH=$PATH:$HOME/.dotnet
    # Append export DOTNET_ROOT=$HOME/.dotnet
    # Append export PATH="$PATH:~/.dotnet/tools"
    source ~/.bashrc  # bash neu laden
    $env:PATH = "$($env:PATH):~/.dotnet"    # PATH in GROSSBUCHSTABEN!!!
    dotnet tool install --global PowerShell
}

if ($IsWindows) {
    
}

if ($IsCoreCLR) {
}

oh-my-posh init pwsh --config ~/.poshthemes/mytheme.omp.json | Invoke-Expression
# oh-my-posh init pwsh --config ~/.poshthemes/jandedobbeleer.omp.json | Invoke-Expression
