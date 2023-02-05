#Requires -Version 7

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$myProfile_CurrentUserAllHosts_Url = 'https://raw.githubusercontent.com/stolaf/homelab/main/pwsh/profile.CurrentUserAllHosts.ps1'
$myOhMyPoshTheme_Url = 'https://raw.githubusercontent.com/stolaf/homelab/main/pwsh/my.omp.json'


if (!(Get-Item -Path $($Profile.CurrentUserAllHosts))) {
    # rm /home/codespace/.config/powershell/profile.ps1 -f
    Invoke-WebRequest $myProfile_CurrentUserAllHosts_Url -OutFile $($Profile.CurrentUserAllHosts)
    # wget -O /home/codespace/.config/powershell/profile.ps1 https://raw.githubusercontent.com/stolaf/homelab/main/pwsh/profile.CurrentUserAllHosts.ps1
    # cat /home/codespace/.config/powershell/profile.ps1
}

function Install-PWSH {
    <#
        .SYNOPSIS
        Dient nur als Vorlage um PWSH und oh-my-posh zu installieren

        .DESCRIPTION
        Dient nur als Vorlage um PWSH und oh-my-posh zu installieren

        .EXAMPLE
        Install-PWSH
        oh-my-posh init pwsh --config "https://raw.githubusercontent.com/stolaf/homelab/main/pwsh/my.omp.json" | Invoke-Expression
    #>

    if ($IsLinux) {
        sudo apt-get update
        sudo apt-get install -y wget apt-transport-https software-properties-common  # Install pre-requisite packages.
        $lsb_release = $(lsb_release -is).ToLower()
        wget -q "https://packages.microsoft.com/config/$lsb_release/$(lsb_release -rs)/packages-microsoft-prod.deb"  
        sudo dpkg -i packages-microsoft-prod.deb   # Register the Microsoft repository GPG keys
        sudo apt-get update  # Update the list of packages after we added packages.microsoft.com
        sudo apt-get install -y powershell

        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh  
        sudo chmod +x /usr/local/bin/oh-my-posh
        
    }
    if ($IsWindows) {
        winget install Microsoft.PowerShell -s winget
        winget install JanDeDobbeleer.OhMyPosh  -s winget
    }
    oh-my-posh font install Meslo
}

function Install-OpenSSH {
    <#
        .SYNOPSIS
        Dient nur als Vorlage um OpenSSH zu installieren

        .DESCRIPTION
        Dient nur als Vorlage um OpenSSH zu installieren

        .EXAMPLE
        Install-OpenSSH
    #>

    Install-Module -Name 'Microsoft.PowerShell.RemotingTools' -force
    Import-Module -Name 'Microsoft.PowerShell.RemotingTools'

    if ($IsWindows) {
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        Set-Service -Name sshd -StartupType 'Automatic'
        Start-Service -Name sshd
        Enable-SSHRemoting -Verbose
        Restart-Service -Name sshd
    }

    if ($IsLinux) {
        Enable-SSHRemoting -Verbose 
        sudo service ssh restart
    }
}

function Install-Software {
    <#
        .SYNOPSIS
        Dient nur als Vorlage um meine verwendete Software zu installieren

        .DESCRIPTION
        Dient nur als Vorlage um meine verwendete Software zu installieren

        .EXAMPLE
        Install-Software
    #>

    if ($IsWindows) {
        $null = mkdir C:\Temp -ErrorAction SilentlyContinue

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
        winget install Devolutions.RemoteDesktopManagerFree
        #endregion Winget

        # Citrix Receiver
        Start-Process https://www.citrix.com/downloads/citrix-receiver/additional-client-software/hdx-realtime-media-engine-latest.html

        #KNX ETS 5 manuelle Installation
        Start-Process 'https://support.knx.org/hc/de/articles/360021434999-ETS-v5-7-6'

        #WISO Vermieter manuelle Installation
        Start-Process 'https://www.buhl.de/produkte/wiso-vermieter'   # Anmelden und Software downloaden

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

        #MS Ondrive aus Explorer entfernen bei Bedarf
        <#
            $Null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
            Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Force
            Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Force
        #>

        Set-Service beep -StartupType disabled
        Stop-Service beep
    }
}

function Install-myPWSH_Environment {
    <#
        .SYNOPSIS
        Konfiguriert meine persönlichen Powershell Einstellungen

        .DESCRIPTION
        Konfiguriert meine persönlichen Powershell Einstellungen

        .EXAMPLE
        Install-myPWSH_Environment
    #>
    
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted 
    Register-PackageSource -Name 'NuGet' -Location "http://www.nuget.org/api/v2" -ProviderName Nuget -Trusted -Force

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
    Install-Module -Name 'PSFzf' -Repository PSGallery -Scope CurrentUser -force

    if ($IsWindows) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

        # Module die nur unter Windows funktionieren
        Install-Module -Name 'NTFSSecurity' -Scope CurrentUser -Force

        #region FuzzySearch  https://github.com/junegunn/fzf/releases  exe File herunterladen und nach system32 kopieren
        Invoke-WebRequest 'https://github.com/junegunn/fzf/releases/download/0.30.0/fzf-0.30.0-windows_amd64.zip' -OutFile '~/Downloads/fzf.zip'
        Expand-Archive -Path "~/Downloads/fzf.zip" -DestinationPath "~/Downloads/fzf" -Force
        Copy-Item -Path '~/Downloads/fzf/fzf.exe' -Destination "$ENV:WINDIR\System32\fzf.exe" -force
        Remove-Item -Path '~/Downloads/fzf.zip' -force -EA 0
        Remove-Item -Path '~/Downloads/fzf' -Recurse -force -EA 0
        Install-Module -Name 'PSFzf' -Repository PSGallery -Scope CurrentUser -force
        #endregion FuzzySearch
    }
    if ($IsLinux) {
        sudo apt-get install sudo curl fzf unzip snapd -y

        # sudo snap install bw # funktioniert nicht mehr
        wget "https://vault.bitwarden.com/download/?app=cli&platform=linux"  -o bw-linux.zip  # Codespace: auf dem Desktop herunter laden und dann hochladen
        unzip bw-linux.zip
        chmod u+x bw
        sudo mv bw /usr/local/bin
        rm bw-linux.zip -f
     
        mkdir ~/.config/powershell -p
        mkdir /home/codespace/.config/powershell -p
        sudo apt autoremove
    }
    Update-module 
    Invoke-WebRequest $myProfile_CurrentUserAllHosts_Url -OutFile $($Profile.CurrentUserAllHosts)
}

function Install-VSCode {
    <#
        .SYNOPSIS
        Dient als Vorlage für meine persönlichen VSCode Einstellungen

        .DESCRIPTION
        Dient als Vorlage für meine persönlichen VSCode Einstellungen
        Extensions, Settings, Snippets etc. können über Profile export und importiert werden

        .EXAMPLE
        Install-VSCode
    #>
    
    git config --global user.email "olaf.stagge@posteo.de"
    git config --global user.name "olaf.stagge@posteo.de"
    git config --global --list   
    git config --local --list  #innterhalb des Repos

    if ($IsWindows) {
        $Null = New-Item -Path "$ENV:APPDATA\Code\User\Snippets\powershell.json" -ItemType File -ErrorAction SilentlyContinue
        # https://gist.github.com/rkeithhill/60eaccf1676cf08dfb6f
        # https://germanpowershell.com/visual-studio-code/
    }
}

function Unlock-My_PWSH_Environment {
    <#
        .SYNOPSIS
        Dient als Vorlage für meine persönliche Powershell Umgebung 

        .DESCRIPTION
       Dient als Vorlage für meine persönliche Powershell Umgebung 

        .EXAMPLE
        Unlock-My_PWSH_Environment
    #>
    

    # ls -la $HOME/.secretmanagement/localstore/
    # Unregister-SecretVault -Name SecretStore
    # Set-SecretStorePassword -NewPassword $newss
    # Reset-SecretStore -Force -PassThru   # wichtig wenn SecretStore rumzickt!!!
    Import-Module 'Microsoft.Powershell.SecretStore'
    Register-SecretVault -Name SecretStore -ModuleName 'Microsoft.Powershell.SecretStore' -DefaultVault -AllowClobber 
    # Get-SecretVault | Select-Object *
    # $ss = ConvertTo-SecureString -AsPlainText '19I...' -Force
    # Unlock-SecretStore -PasswordTimeout 0 -Password $ss
    Set-SecretStoreConfiguration -Scope CurrentUser -Authentication None -PasswordTimeout 0 -Confirm:$false # -Password $ss
    # Set-SecretStoreConfiguration -Scope CurrentUser -PasswordTimeout 3600 -Confirm:$false 
    # Get-SecretStoreConfiguration 
    # bw list items --search google --pretty
    # bw get item 86e639ad-425f-44e9-96ec-33aff0981243 --pretty
    # bw get password 86e639ad-425f-44e9-96ec-33aff0981243 
    # bw generate -lusn --length 20

    # Remove-Secret -Name 'myBitwarden' -Vault SecretStore
    if (!(Get-SecretVault -Name SecretStore -ErrorAction SilentlyContinue)) {
        Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
    }
    if (!(Get-Secret -Name 'myBitwarden' -Vault SecretStore -ErrorAction SilentlyContinue)) {
        Set-Secret -Name 'myBitwarden' -Vault SecretStore -Metadata @{Comment = 'myBitwarden Safe' } -Secret (Get-Credential -UserName 'olaf.stagge@posteo.de' -Message 'Input myBitwarden Password')
    }
    $myBitwarden = Get-Secret -Name 'myBitwarden' -Vault SecretStore 

    $Null = bw config server https://bitwarden.stagge.it
    $Null = bw login olaf.stagge@posteo.de $($myBitwarden.GetNetworkCredential().Password) --raw 
    $Token = bw unlock --raw $($myBitwarden.GetNetworkCredential().Password)
    $env:BW_SESSION = "$Token"

    return 

    # Das aktuelle ProfileScript bei Bedarf herunterladen : Geht leider nur mit GitLab
    $GitLab_Token = bw get item 084f6d89-93d8-40a0-bf55-17a5c1f1e947 --pretty | ConvertFrom-Json
    $PrivateToken = ($GitLab_Token.fields | Where-Object { $_.name -Match 'myCurl_Token' }).Value
    $Headers = @{'Private-Token' = $PrivateToken }

    $FileHash = Get-FileHash -Path $($Profile.CurrentUserAllHosts)
    $Uri = "https://github.com/stolaf/homelab/blob/main/pwsh/profile.CurrentUserAllHosts.ps1"
    $RestMethod = Invoke-RestMethod -Uri $Uri -SkipHttpErrorCheck
    if ($RestMethod.Message -notmatch '404') {
        if ($($RestMethod.content_sha256) -ne $($FileHash.Hash)) {
            # Download neueres ProfileScript
            Invoke-RestMethod -Headers $Headers -Uri $myProfile_CurrentUserAllHosts_Url -OutFile $($Profile.CurrentUserAllHosts)
            Write-Host ''
        }
    }
}

# Beim ersten Aufruf des Profils wird Install-myPWSH_Environment aufgerufen
if (!(Get-Module -Name 'Terminal-Icons' -ListAvailable -EA 0)) {
    Install-myPWSH_Environment
}

Import-Module -Name 'Terminal-Icons'
Import-Module -Name 'PSFzf' 
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

if ($PSVersiontable.PSVersion.ToString() -gt '7.2.6') {
    Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource HistoryAndPlugin -Colors @{InlinePrediction = "$($PSStyle.Foreground.Black)$($PSStyle.Foreground.Cyan)" }
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
}
$PSStyle.Formatting.TableHeader = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Green

# Set-Alias ll ls
# Set-Alias g git
# Set-Alias grep findstr

Unlock-My_PWSH_Environment
oh-my-posh init pwsh --config $myOhMyPoshTheme_Url  | Invoke-Expression

