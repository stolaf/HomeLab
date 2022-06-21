# BackupScript für influxdb Datenbanken in Docker

#Set the language
# export LANG="en_US.UTF-8"
#Load the Pathes
# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# set the variables

$BackupDir = '~/backup/influxdb'  # Where to store the Backup files?
$BackupDays = 5  # How many Days should a backup be available?
$TimeStamp = Get-Date -format 'yyyyMMd-HHmm'   

Write-Output "Start $TIMESTAMP Backup for Databases"
if (!(Test-Path -Path $BackupDir)) {
    $Null = New-Item -ItemType 'Directory' -Path $BackupDir -Force
}

$Containers = (docker ps --format '{{.Names}}:{{.Image}}' | Where-Object { $_ -match 'influxdb'} | cut -d":" -f1)

foreach ($Container in $Containers) {
    # $Container = $Containers[0]
	# Baustelle!!!
    Write-Output "Create Backup for influxdb Database on Container: $Container"
	# docker exec -e i=$i -e TIMESTAMP=$TIMESTAMP $i influx backup --compression gzip /backup/$i-$TIMESTAMP > /dev/null 2>&1 
	docker exec -e i=$Container -e TIMESTAMP=$TIMESTAMP $Container influx backup --compression gzip /backup/$Container-$TIMESTAMP > /dev/null 2>&1 
	docker exec -e i=$Container -e TIMESTAMP=$TIMESTAMP $Container influx backup --compression gzip > $BackupDir/$Container-InfluxDB-$TIMESTAMP.sql.gz
	docker exec $Container pg_dumpall -c -U $POSTGRES_USER | gzip > "$BACKUPDIR/$Container-$TIMESTAMP.sql.gz"
	docker exec $Container -i bash
}

Get-ChildItem -Path $BackupDir -Filter '*.sql.gz' -Recurse | Where-Object {$_.CreationTime -lt $BackupDays} | Remove-Item -Force
Write-Output "$TIMESTAMP : Backup for influxdb Databases completed!"
