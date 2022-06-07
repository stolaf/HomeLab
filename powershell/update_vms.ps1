ssh.exe pi@192.168.178.2 sudo apt update && sudo apt upgrade -y

sudo apt update && sudo apt upgrade -y
if (Test-Path -Path '/var/run/reboot-required') {
    Write-Host "Reboot now Server"
    Start-Sleep -Seconds 2
    sudo reboot now
}

