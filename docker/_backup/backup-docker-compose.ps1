# This Script backups the docker compose project folder

$BackupDir = '~/backup/compose'  # Where to store the Backup files?
$BackupDays = 5  # How many Days should a backup be available?
$TimeStamp = Get-Date -format 'yyyyMMd-HHmm'   

Write-Output "Start $TIMESTAMP Backup for compose"
if (!(Test-Path -Path $BackupDir)) {
    $Null = New-Item -ItemType 'Directory' -Path $BackupDir -Force
}

$ALLCONTAINERS = $(docker ps --format '{{.Names}}')
$ALLPROJECTS = $(for $i in $ALLCONTAINER; do docker inspect --format '{{ index .Config.Labels "com.docker.compose.project.working_dir"}}' $i; done | sort -u)

foreach ($i in $ALLCONTAINERS) {
   docker inspect --format '{{ index .Config.Labels "com.docker.compose.project.working_dir"}}' $i
}
docker inspect --format '{{ index .Config.Labels "com.docker.compose.project.working_dir"}}' portainer

foreach ($i in $ALLPROJECTS) {
    # $i = $ALLPROJECTS[0]
    $PROJECTNAME = ${i##*/}
	echo -e " Backup von Compose Project:\n  * $PROJECTNAME";
    Write-Output "Backup von Compose Project: $PROJECTNAME"
	cd $i
    tar -czf $BACKUPDIR/$PROJECTNAME-$TIMESTAMP.tar.gz .
}

Write-Output "$TIMESTAMP Backup for Compose Projects completed!"