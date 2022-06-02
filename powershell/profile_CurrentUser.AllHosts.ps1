# Mein Powershell Profile CurrentUserAllHosts $Profile.CurrentUserAllHosts

function Install-myModule {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted      
    Install-Module -Name 'PSReadLine' -AllowPrerelease -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'z' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Terminal-Icons' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Posh-Git' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'ImportExcel' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Microsoft.Powershell.SecretManagement' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Microsoft.Powershell.SecretStore' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'SecretManagement.KeePass' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'PlatyPS' -Repository PSGallery -Scope CurrentUser -force
    Install-Module -Name 'Pester' -Repository PSGallery -Scope CurrentUser -force

    start-process https://github.com/junegunn/fzf
    sudo apt-get install fzf  #oder
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    Install-Module -Name 'PSFzf' -Repository PSGallery -Scope CurrentUser -force

    if ($IsWindows) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

        https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip      
    }

    if ($IsLinux) {
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
}

Write-Host "Profile Load CurrentUserAllHosts: $($Profile.CurrentUserAllHosts)" -ForegroundColor Yellow

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Import-Module -Name 'Terminal-Icons'
Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource History -Colors @{InlinePrediction = "$($PSStyle.Foreground.Black)$($PSStyle.Foreground.Cyan)" }
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar

$PSStyle.Formatting.TableHeader = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Green

Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

if ($IsLinux) {
    $env:PATH = "$($env:PATH):~/.dotnet"    # PATH in GROSSBUCHSTABEN!!!
}

if ($IsWindows) {
    
}

if ($IsCoreCLR) {
}

oh-my-posh init pwsh --config ~/.poshthemes/mytheme.omp.json | Invoke-Expression
# oh-my-posh init pwsh --config ~/.poshthemes/jandedobbeleer.omp.json | Invoke-Expression
