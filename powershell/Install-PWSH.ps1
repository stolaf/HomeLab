## Installation über DOTNET
start https://docs.microsoft.com/de-de/dotnet/core/install/linux-scripted-manual#scripted-install

if ($IsLinux) {
    wget https://dot.net/v1/dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh -c Current
    nano ~/.bashrc
    export PATH=$PATH:$HOME/.dotnet
    export DOTNET_ROOT=$HOME/.dotnet
    export PATH="$PATH:/home/olaf/.dotnet/tools"
        
    dotnet tool install --global PowerShell
    dotnet tool uninstall --global PowerShell
    dotnet tool list --global
}

if ($IsWindows) {
    Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } –useMSI -EnablePSRemoting -Quiet"
}

<# Raspi
wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.2/powershell-7.1.2-linux-arm32.tar.gz
tar -xvf ./powershell-7.1.2-linux-arm32.tar.gz -C ~/powershell
#>