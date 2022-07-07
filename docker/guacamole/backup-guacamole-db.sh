#!/usr/bin/env bash

# chmod +x /home/olaf/Documents/homelab/docker/guacamole/*.sh
# bash /home/olaf/Documents/homelab/docker/guacamole/backup-guacamole-db.sh
# sudo ln -s /home/olaf/Documents/homelab/docker/guacamole/backup-guacamole-db.sh /etc/cron.daily/backup-guacamole-db
# ls -la /etc/cron.daily
# docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb'

export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BACKUPDIR=/media/backup/bs-docker-01/guacamole
DAYS=10
TIMESTAMP=$(date +"%Y%m%d-%H%M")
WEEKDAY=$(date +%u)
CONTAINER=guacamole_mysql
MYSQL_DATABASE=$(docker exec $CONTAINER env | grep MYSQL_DATABASE | cut -d"=" -f2)
MYSQL_PWD=$(docker exec $CONTAINER env | grep MYSQL_ROOT_PASSWORD | cut -d"=" -f2)

<<Restore
    # Restore Test:
    cd /home/olaf/Documents/homelab/docker/guacamole
    docker compose down
    sudo rm -rf /var/docker/guacamole/mysql
    ls -la /var/docker/guacamole/mysql
    docker compose up -d
    zcat "/media/backup/docker-01/guacamole/guacamole_mysql-202207051540.sql.gz" | docker exec -i $CONTAINER /usr/bin/mysql -u root --password=$MYSQL_PWD $MYSQL_DATABASE
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
