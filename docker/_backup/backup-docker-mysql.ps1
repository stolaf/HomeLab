# BackupScript für mysql/mariadb Datenbanken in Docker

$BackupDir = '~/backup/mysql'  # Where to store the Backup files?
$BackupDays = 5  # How many Days should a backup be available?
$TimeStamp = Get-Date -format 'yyyyMMd-HHmm'   

$Containers = (docker ps --format '{{.Names}}:{{.Image}}' | Where-Object { $_ -match 'mysql|mariadb' } | cut -d":" -f1)

Write-Output "Start $TIMESTAMP Backup for Databases"
if (!(Test-Path -Path $BackupDir)) {
    $Null = New-Item -ItemType 'Directory' -Path $BackupDir -Force
}

foreach ($Container in $Containers) {
    # $Container = $Containers[1]
    $MYSQL_DATABASE = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_DATABASE' } | cut -d"=" -f2)
    $MYSQL_PWD = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_ROOT_PASSWORD' } | cut -d"=" -f2)
    Write-Output " create Backup for Database on Container: $MYSQL_DATABASE DB on $Container"

    . docker exec -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysqldump -u root $MYSQL_DATABASE > "$BackupDir/$Container-$MYSQL_DATABASE-$TIMESTAMP.sql"

    # . docker exec -it -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container sh
    # funktioniert nicht
    # . docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$MYSQL_PWD $Container /usr/bin/mysqldump -u root $MYSQL_DATABASE | gzip > "$BackupDir/$Container-$MYSQL_DATABASE-$TIMESTAMP.sql.gz"
}

Get-ChildItem -Path $BackupDir -Filter '*.sql.gz' -Recurse | Where-Object { $_.CreationTime -lt $BackupDays } | Remove-Item -Force

Write-Output "$TIMESTAMP Backup for mysql Databases completed!"

