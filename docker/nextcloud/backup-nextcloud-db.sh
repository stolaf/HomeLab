#!/usr/bin/env bash

# chmod +x /home/olaf/Documents/homelab/docker/nextcloud/*.sh
# bash /home/olaf/Documents/homelab/docker/nextcloud/backup-nextcloud-db.sh
# sudo ln -s /home/olaf/Documents/homelab/docker/nextcloud/backup-nextcloud-db.sh /etc/cron.daily/backup-nextcloud-db

export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BACKUPDIR=/media/backup/bs-docker-01/nextcloud
DAYS=10
TIMESTAMP=$(date +"%Y%m%d-%H%M")
WEEKDAY=$(date +%u)
CONTAINER=nextcloud-db
MYSQL_DATABASE=$(docker exec $CONTAINER env | grep MYSQL_DATABASE | cut -d"=" -f2)
MYSQL_PWD=$(docker exec $CONTAINER env | grep MYSQL_ROOT_PASSWORD | cut -d"=" -f2)

<<Restore
    # Restore Test:
    ls -la /var/docker/nextcloud/database
    sudo rm -rf /var/docker/nextcloud/database
    zcat "/media/backup/docker-01/nextcloud/nextcloud-db-202207051458.sql.gz" | docker exec -i $CONTAINER /usr/bin/mysql -u root --password=$MYSQL_PWD $MYSQL_DATABASE
Restore

echo -e "Start $TIMESTAMP Backup for Databases: \n"
if [ ! -d $BACKUPDIR ]; then
	mkdir -p $BACKUPDIR
fi

echo -e " create Backup for Database on Container:\n  * $MYSQL_DATABASE DB on $CONTAINER";
docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$MYSQL_PWD $CONTAINER /usr/bin/mysqldump -u root $MYSQL_DATABASE | gzip > "$BACKUPDIR/daily-$CONTAINER-$TIMESTAMP.sql.gz"

if [ $WEEKDAY -eq 1 ]; then   # immer Montags
    docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$MYSQL_PWD $CONTAINER /usr/bin/mysqldump -u root $MYSQL_DATABASE | gzip > "$BACKUPDIR/weekly-$CONTAINER-$TIMESTAMP.sql.gz"
fi

OLD_BACKUPS=$(ls -1 "$BACKUPDIR/daily-$CONTAINER*.gz" |wc -l)
if [ $OLD_BACKUPS -gt $DAYS ]; then
	find $BACKUPDIR -name "daily-$CONTAINER*.gz" -daystart -mtime +$DAYS -delete
fi

echo -e "\n$TIMESTAMP Backup for Databases completed\n" 
