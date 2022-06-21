# Start-Process https://www.laub-home.de/wiki/Docker_Postgres_Backup_Script  

$BackupDir = '/media/backup/docker-01/recipes'  
$BackupDays = 10  
$TimeStamp = Get-Date -format 'yyyyMMd-HHmm'   

Write-Output "Start $TIMESTAMP Backup for Databases"
if (!(Test-Path -Path $BackupDir)) { $Null = New-Item -ItemType 'Directory' -Path $BackupDir -Force }

#region backup database
# $Container = (docker ps --format '{{.Names}}:{{.Image}}' | Where-Object { $_ -match 'recipes_db' } | cut -d":" -f1)
$Container = 'recipes_db'

Write-Output "Create Backup for postgres Database on Container: $Container"
$POSTGRES_USER = $(docker exec $Container env | Where-Object { $_ -match 'POSTGRES_USER' }  | cut -d"=" -f2)
# docker exec $Container pg_dumpall -c -U $POSTGRES_USER | gzip > "$BACKUPDIR/$Container-$TIMESTAMP.sql.gz"
. docker exec $Container pg_dumpall -c -U $POSTGRES_USER > "$BACKUPDIR/$Container-$TIMESTAMP.sql"

Get-ChildItem -Path $BackupDir -Filter '*.sql*' -Recurse | Where-Object { $_.CreationTime -lt $BackupDays } | Remove-Item -Force
Write-Output "$TIMESTAMP Backup for postgres Databases completed!"
#endregion backup database

#region backup datafiles
/bin/tar -czf "$BackupDir/staticfiles-$TIMESTAMP.tar.gz" /var/docker/recipes/staticfiles
/bin/tar -czf "$BackupDir/mediafiles-$TIMESTAMP.tar.gz" /var/docker/recipes/mediafiles
# ls -la /var/docker/recipes/staticfiles
# ls -la /var/docker/recipes/mediafiles
# ls -la /media/backup/recipes/staticfiles
$BACKUPDIR = '/media/backup/docker-01/volumes'
$VOLUMES = $(docker volume ls -q)
$i = $VOLUMES[0]
docker run --rm -v "$($BACKUPDIR):/backup" -v $($i):/data:ro -e TIMESTAMP=$TIMESTAMP -e i=$i ${MEMORYLIMIT} --name volumebackup alpine sh -c "cd /data && /bin/tar -czf /backup/$i-$TIMESTAMP.tar.gz ."

rsync -av  /var/docker/recipes/staticfiles/ /media/backup/docker-01/volumes/
#endregion backup datafiles

break

#region restore
# sudo rm -rf /var/docker/recipes/staticfiles/* 
# sudo rm -rf /var/docker/recipes/mediafiles
sudo /bin/tar -xzvf /media/backup/docker-01/recipes/staticfiles-20220620-1410.tar.gz -C /var/docker/recipes/staticfiles
sudo /bin/gzip -dc /media/backup/docker-01/recipes/staticfiles-20220620-1410.tar.gz /var/docker/recipes/staticfiles
 
#endregion restore

#region Allgemeines
$Container = 'recipes_db'
$POSTGRES_USER = $(docker exec $Container env | Where-Object { $_ -match 'POSTGRES_USER' }  | cut -d"=" -f2)
$POSTGRESS_DATABASE = $(docker exec $Container env | Where-Object { $_ -match 'POSTGRES_DB' }  | cut -d"=" -f2)
$POSTGRESS_PW = $(docker exec $Container env | Where-Object { $_ -match 'POSTGRES_PASSWORD' }  | cut -d"=" -f2)
docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql --help
docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql -V   # version
docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql -U $POSTGRES_USER   #\q for Quit
docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql -U $POSTGRES_USER -d $POSTGRESS_DATABASE -c '\l'  # list Databases
docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql -U $POSTGRES_USER -d $POSTGRESS_DATABASE -c '\dt+' --pset pager=off  # list Table
docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql -U $POSTGRES_USER -d $POSTGRESS_DATABASE -c 'SELECT * FROM  django_admin_log'  

$Tables = docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$POSTGRESS_PW" $Container psql -U $POSTGRES_USER -d $POSTGRESS_DATABASE -c '\dt+' --pset pager=off --csv --field-separator=";" | ConvertFrom-Csv
foreach ($Table in $Tables) {
    # $Table = $Tables[1]
    Write-Host "Table: $($Table.Name)"
    docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$MYPOSTGRESS_PWD" $Container psql -U $POSTGRES_USER -d $POSTGRESS_DATABASE -c "SELECT * FROM $($Table.Name)" --pset pager=off
    docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" -e "POSTGRES_PASSWORD=$MYPOSTGRESS_PWD" $Container psql -U $POSTGRES_USER -d $POSTGRESS_DATABASE -c "SELECT * FROM cookbook_step" --pset pager=off
}

sudo ls -la /var/docker/recipes/postgresql/data
sudo rm -rf /var/docker/recipes
cd ~/Documents/homelab/docker/recipes
docker-compose down
docker-compose up -d

cat /home/olaf/backup/postgres/recipes_db-20220619-2054.sql | docker exec -it -e "POSTGRES_USER=$POSTGRES_USER" $Container psql -U $POSTGRESUSER # restore
cat /home/olaf/backup/postgres/recipes_db-20220619-2054.sql | docker exec -i recipes_db psql -U db_recipes
#endregion Allgemeines


