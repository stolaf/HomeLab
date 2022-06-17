# This Script backups docker volumes to a backup directory

#Set the language
# export LANG="en_US.UTF-8"
#Load the Pathes
# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# set the variables

$BACKUPDIR = '/backup/volumes'  # Where to store the Backup files?
$BackupDays = 5  # How many Days should a backup be available?
$TimeStamp = Get-Date -format 'yyyyMMd-HHmm'   

Write-Output "Start $TIMESTAMP Backup for Volumes"
if (!(Test-Path -Path $BackupDir)) {
    $Null = New-Item -ItemType 'Directory' -Path $BackupDir -Force
}

# $Volumes = $(docker volume ls -q)
$Volumes = '/var/docker'

foreach ($i in $Volumes) {
    # $i = $Volumes 
    Write-Output "Create Backup vom Volume: $i"
	docker run --rm -v $BACKUPDIR:/backup -v $i:/data:ro -e TIMESTAMP=$TIMESTAMP -e i=$i ${MEMORYLIMIT} --name volumebackup alpine sh -c "cd /data && /bin/tar -czf /backup/$i-$TIMESTAMP.tar.gz ."
}

Get-ChildItem -Path $BackupDir -Filter '*.sql.gz' -Recurse | Where-Object {$_.CreationTime -lt $BackupDays} | Remove-Item -Force
Write-Output "$TIMESTAMP Backup for Volumes completed!"
