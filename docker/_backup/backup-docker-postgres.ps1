# BackupScript für postgres Datenbanken in Docker

#Set the language
# export LANG="en_US.UTF-8"
#Load the Pathes
# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# set the variables

$BackupDir = '~/backup/postgres'  # Where to store the Backup files?
$BackupDays = 5  # How many Days should a backup be available?
$TimeStamp = Get-Date -format 'yyyyMMd-HHmm'   

Write-Output "Start $TIMESTAMP Backup for Databases"
if (!(Test-Path -Path $BackupDir)) {
    $Null = New-Item -ItemType 'Directory' -Path $BackupDir -Force
}

$Containers = (docker ps --format '{{.Names}}:{{.Image}}' | Where-Object { $_ -match 'postgres'} | cut -d":" -f1)

foreach ($Container in $Containers) {
    Write-Output "Create Backup for postgres Database on Container: $Container"
    $POSTGRES_USER = $(docker exec $Container env | Where-Object {$_ -match 'POSTGRES_USER'}  | cut -d"=" -f2)
	docker exec $Container pg_dumpall -c -U $POSTGRES_USER | gzip > "$BACKUPDIR/$Container-$TIMESTAMP.sql.gz"
}

Get-ChildItem -Path $BackupDir -Filter '*.sql.gz' -Recurse | Where-Object {$_.CreationTime -lt $BackupDays} | Remove-Item -Force
Write-Output "$TIMESTAMP Backup for postgres Databases completed!"

