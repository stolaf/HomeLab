<#
Backup Script für das homelab
Backup erfolgt über duplicati auf die Backup NAS
pwsh -NoProfile -File /home/pi/IOTstack/backup.ps1   
pwsh -NoProfile -File /home/pi/IOTstack/backup.ps1 >> /home/pi/IOTstack/backup-$(date +%Y-%m-%d-%H-%M-%S).log 2>&1

#>

push-location
Set-Location /home/pi/homelab
$Containers = docker ps --format "table {{.ID}};{{.Names}};{{.Image}};{{.State}};{{.Status}};{{.Size}};{{.Networks}};{{.Mounts}}" | ConvertFrom-Csv -Delimiter ';'

$Containers = $Containers | Where-Object { $_.NAMES -notmatch 'duplicati' }
foreach ($Container in $Containers) {
    Write-Output "Stop now Container $($Container.NAMES)"
    docker stop $($Container.'CONTAINER ID') >null 2>&1
}

<#
docker exec duplicati duplicati-cli help
echo "#!/bin/bash" >./backup.sh
echo "" >>./backup.sh
docker exec duplicati duplicati-cli backup "ssh://192.168.178.6:22//export/backup/duplicati/raspi-01?auth-username=olaf&auth-password=Maur"'!'"t"'!'"us2&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" /IOTstack/ --backup-name=raspi-01 --dbpath=/data/Duplicati/WFPPELDBPF.sqlite --encryption-module=aes --compression-module=zip --dblock-size=50mb --passphrase="Tr"'!'"n"'!'"dat#2" --disable-module=console-password-input
#>

bash /home/pi/homelab/backup.sh

docker-compose up -d

# $Containers = docker ps --all --format "table {{.ID}};{{.Names}};{{.Image}};{{.State}};{{.Status}};{{.Size}};{{.Networks}};{{.Mounts}}" | ConvertFrom-Csv -Delimiter ';'
# $Containers = $Containers | Where-Object {$_.NAMES -notmatch 'duplicati'}
# foreach ($Container in $Containers) {
#     Write-Output "Start now Container $($Container.NAMES)"
#     docker start $($Container.'CONTAINER ID')
# }

Pop-Location
