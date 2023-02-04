[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Install-PWSH {
    if ($IsLinux) {
        <#      Installation über DOTNET
        https://github.com/PowerShell/PowerShell/releases
        https://docs.microsoft.com/en-us/powershell/scripting/install/install-debian?view=powershell-7.2
    
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
        #>

        if ($(lsb_release -is) -Match 'Ubuntu') {
            sudo apt-get update
            sudo apt-get install -y wget apt-transport-https software-properties-common  # Install pre-requisite packages.
            wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb  # Download the Microsoft repository GPG keys
            sudo dpkg -i packages-microsoft-prod.deb   # Register the Microsoft repository GPG keys
            sudo apt-get update  # Update the list of packages after we added packages.microsoft.com
            sudo apt-get install -y powershell
            pwsh
        }
    }
    if ($IsWindows) {
        # Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') }" 
        # Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } –useMSI -EnablePSRemoting -Quiet"
        Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } –useMSI"
        winget install Microsoft.PowerShell
    }
}
function Install-OpenSSH {
    if ($IsWindows) {
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        Set-Service -Name sshd -StartupType 'Automatic'
        Start-Service -Name sshd
        Install-Module -Name Microsoft.PowerShell.RemotingTools	
        Import-Module -Name Microsoft.PowerShell.RemotingTools
        Enable-SSHRemoting -Verbose
        Restart-Service -Name sshd

        # Powershell Remoting
        Start-Process https://4sysops.com/archives/install-powershell-remoting-over-ssh/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+4sysops+%284sysops%29
    }

    if ($IsLinux) {
        Install-Module -Name 'Microsoft.PowerShell.RemotingTools'
        Enable-SSHRemoting -Verbose 
        sudo service ssh restart
    }
    Invoke-Command -HostName 192.168.178.20 -UserName olaf -ScriptBlock { Get-Process -Name pwsh }
}
function Install-Software {
    if ($IsWindows) {
        $null = mkdir C:\Temp -ErrorAction SilentlyContinue
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted 
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        #region Chocolatey 'https://chocolatey.org/'
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
        
        #region Winget
        winget install Brave.Brave
        winget install DeepL.DeepL
        winget install Notepad++.Notepad++
        winget install Greenshot.Greenshot
        winget install WinSCP.WinSCP
        winget install Balena.Etcher
        winget install 7zip.7zip
        winget install Bitwarden.Bitwarden
        winget install Citrix.Workspace
        winget install Microsoft.VisualStudioCode
        winget install Python.Python.3.12
        winget install Foxit.FoxitReader
        winget install PawelPsztyc.AdvancedRestClient
        winget install Mozilla.Thunderbird
        winget install VideoLAN.VLC
        winget install TheDocumentFoundation.LibreOffice
        winget install Nextcloud.NextcloudDesktop
        winget install TeamViewer.TeamViewer
        winget install Jabra.Direct
        winget install FreeCAD.FreeCAD
        winget install KDE.Kdenlive
        winget install Logitech.Options
        winget install Obsidian.Obsidian
        winget install Prusa3D.PrusaSlicer
        winget install WhatsApp.WhatsApp
        winget install GIMP.GIMP
        winget install JanDeDobbeleer.OhMyPosh
        winget install Microsoft.PowerToys
        # winget install RoyalApps.RoyalTS
        winget install Devolutions.RemoteDesktopManagerFree

        Start-Process https://www.citrix.com/downloads/citrix-receiver/additional-client-software/hdx-realtime-media-engine-latest.html

        #endregion Winget

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
    }
}
function Install-myPWSH_Environment {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Register-PackageSource -Name 'NuGet' -Location "http://www.nuget.org/api/v2" -ProviderName Nuget -Trusted

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
    Install-Module -Name 'PoshLog'
    Install-Module -Name 'PoShLog.Enrichers'

    if ($IsWindows) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

        # Invoke-WebRequest 'https://github.com/stolaf/homelab/blob/main/powershell/profile_CurrentUser.AllHosts.ps1' -OutFile $($profile.CurrentUserAllHosts)
        Invoke-WebRequest 'https://gitlab.stagge.it/stolaf/homelab/-/blob/main/powershell/profile_CurrentUser.AllHosts.ps1' -OutFile $($profile.CurrentUserAllHosts)

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

        Install-Module -Name 'NTFSSecurity' -Scope CurrentUser -Force
    }

    if ($IsLinux) {
        sudo snap install bw  # Bitwarden CLI
        bw config server https://bitwarden.stagge.it

        sudo apt-get install fzf  
        Install-Module -Name 'PSFzf' -Repository PSGallery -Scope CurrentUser -force
        
        wget https://github.com/stolaf/homelab/blob/main/powershell/profile_CurrentUser.AllHosts.ps1 -O /home/olaf/.config/powershell/profile.ps1

        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
        mkdir ~/.poshthemes
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
        unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
        chmod u+rw ~/.poshthemes/*.json
        Remove-Item ~/.poshthemes/themes.zip

        # In Terminal Meslo Font einstellen
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip -P ~/Downloads
        unzip ~/Downloads/Meslo.zip -d ~/.fonts
        sudo fc-cache -fv

        mkdir ~/.config/powershell
    }
}
function Install-VSCode {
    git config --global user.email "olaf.stagge@posteo.de"
    git config --global user.name "olaf.stagge@posteo.de"
    git config --global --list   
    git config --local --list  #innterhalb des Repos

    if ($IsWindows) {
        $Null = New-Item -Path "$ENV:APPDATA\Code\User\Snippets\powershell.json" -ItemType File -ErrorAction SilentlyContinue
        # https://gist.github.com/rkeithhill/60eaccf1676cf08dfb6f
        # https://germanpowershell.com/visual-studio-code/
    }

    <# Extensions
    - Powershell
    - vscode-icons
    - Remote SSH
    - Docker
    - GitLab Workflow
    - Go
    - Hexeditor
    - CodeSnap : Take beautiful screenshots of your code
    - Open in Default Browser
    - vscode-pdf
    - XML
    - YAML
    - Flux : InfluxDB 
    #>

}
function Unlock-My_PWSH_Environment {
    # ls -la $HOME/.secretmanagement/localstore/
    # update-module -verbose
    # Get-module -Name Microsoft.PowerShell.Secret* -list
    # Uninstall-Module Microsoft.PowerShell.SecretStore -Force
    # Install-Module -Name Microsoft.PowerShell.SecretStore -Repository PSGallery
    # Install-Module -Name Microsoft.PowerShell.SecretManagement -Repository PSGallery -Force
    # Get-Module -Name Microsoft.PowerShell.SecretStore
    # Unregister-SecretVault -Name SecretStore
    # Set-SecretStorePassword -NewPassword $newss
    # Reset-SecretStore -Force -PassThru   # wichtig wenn SecretStore rumzickt!!!
    Register-SecretVault -Name SecretStore -ModuleName Microsoft.Powershell.SecretStore -DefaultVault -AllowClobber 
    # Get-SecretVault | Select-Object *
    # $ss = ConvertTo-SecureString -AsPlainText '19I...' -Force
    # Unlock-SecretStore -PasswordTimeout 0 -Password $ss
    Set-SecretStoreConfiguration -Scope CurrentUser -Authentication None -PasswordTimeout 0 -Confirm:$false # -Password $ss
    # Set-SecretStoreConfiguration -Scope CurrentUser -PasswordTimeout 3600 -Confirm:$false 
    # Get-SecretStoreConfiguration 

    # Remove-Secret -Name 'myBitwarden' -Vault SecretStore
    if (!(Get-Secret -Name 'myBitwarden' -Vault SecretStore -ErrorAction SilentlyContinue)) {
        Set-Secret -Name 'myBitwarden' -Vault SecretStore -Metadata @{Comment = 'myBitwarden Safe' } -Secret (Get-Credential -UserName 'olaf.stagge@posteo.de' -Message 'Input myBitwarden Password')
    }
    $myBitwarden = Get-Secret -Name 'myBitwarden' -Vault SecretStore 

    $Null = bw config server https://bitwarden.stagge.it
    $Null = bw login olaf.stagge@posteo.de $($myBitwarden.GetNetworkCredential().Password) --raw 
    $Token = bw unlock --raw $($myBitwarden.GetNetworkCredential().Password)
    $env:BW_SESSION = "$Token"

    $FileHash = Get-FileHash -Path $($Profile.CurrentUserAllHosts)

    $GitLab_Token = bw get item 084f6d89-93d8-40a0-bf55-17a5c1f1e947 --pretty | ConvertFrom-Json
    $PrivateToken = ($GitLab_Token.fields | Where-Object { $_.name -Match 'myCurl_Token' }).Value
    $Headers = @{'Private-Token' = $PrivateToken }
    
    # Get ProfileScript File Information
    $RestMethod = Invoke-RestMethod -Headers $Headers -Uri "https://gitlab.stagge.it/api/v4/projects/2/repository/files/powershell%2Fprofile_CurrentUser.AllHosts.ps1?ref=main" -SkipHttpErrorCheck
    if ($RestMethod.Message -notmatch '404') {
        if ($($RestMethod.content_sha256) -ne $($FileHash.Hash)) {
            # Download newer ProfileScript
            Invoke-RestMethod -Headers $Headers -Uri "https://gitlab.stagge.it/api/v4/projects/2/repository/files/powershell%2Fprofile_CurrentUser.AllHosts.ps1/raw?ref=main" -OutFile $($Profile.CurrentUserAllHosts)
            Write-Host ''
        }
    }
}

Import-Module -Name 'Terminal-Icons'
if (Get-Module -Name 'PSFzf') { 
    Import-Module -Name 'PSFzf' 
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}
if ($PSVersiontable.PSVersion.ToString() -gt '7.2.6') {
    Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource HistoryAndPlugin -Colors @{InlinePrediction = "$($PSStyle.Foreground.Black)$($PSStyle.Foreground.Cyan)" }
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
}
$PSStyle.Formatting.TableHeader = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Green

# Set-Alias ll ls
# Set-Alias g git
# Set-Alias grep findstr

oh-my-posh init pwsh --config "https://raw.githubusercontent.com/stolaf/homelab/main/pwsh/my.omp.json" | Invoke-Expression
# code "$ENV:POSH_THEMES_PATH\my.omp.json"

# Unlock-My_PWSH_Environment

