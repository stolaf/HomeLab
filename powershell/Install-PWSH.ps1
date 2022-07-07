## Installation über DOTNET
# https://github.com/PowerShell/PowerShell/releases
# https://docs.microsoft.com/en-us/powershell/scripting/install/install-debian?view=powershell-7.2

start https://docs.microsoft.com/de-de/dotnet/core/install/linux-scripted-manual#scripted-install

<#
cat /etc/shells
chsh 
#>

if ($IsLinux) {
    wget https://dot.net/v1/dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh -c Current
    nano ~/.bashrc
    # export PATH=$PATH:$HOME/.dotnet
    # export DOTNET_ROOT=$HOME/.dotnet
    # export PATH="$PATH:/home/olaf/.dotnet/tools"
    . ~/.bashrc  # reload bashrc Settings

    sudo apt install dotnet-sdk-6.0
    dotnet tool install --global PowerShell
    dotnet tool uninstall --global PowerShell
    dotnet tool list --global

    apt search powershell
    sudo apt remove powershell-lts
    sudo apt-get install -f # Resolve missing dependencies and finish the install (if necessary)

    # Variante 3 (Ubuntu)
    # Download the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    sudo dpkg -i packages-microsoft-prod.deb  # Register the Microsoft repository GPG keys
    sudo apt-get install -y powershell
    sudo apt-get update

    wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.5/powershell_7.2.5-1.deb_amd64.deb
    sudo dpkg -i powershell_7.2.5-1.deb_amd64.deb
}

if ($IsWindows) {
    Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') }" 
    Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } –useMSI -EnablePSRemoting -Quiet"
}

<# Raspi
wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.2/powershell-7.1.2-linux-arm32.tar.gz
tar -xvf ./powershell-7.1.2-linux-arm32.tar.gz -C ~/powershell
#>