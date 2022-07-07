#!/usr/bin/env bash

# chmod +x /home/olaf/Documents/homelab/docker/recipes/*.sh
# bash /home/olaf/Documents/homelab/docker/recipes/backup-recipes-db.sh
# sudo ln -s /home/olaf/Documents/homelab/docker/recipes/backup-recipes-db.sh /etc/cron.daily/backup-recipes-db
# ls -la /etc/cron.daily
# docker ps --format '{{.Names}}:{{.Image}}' | grep 'postgres'

export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BACKUPDIR=/media/backup/bs-docker-01/recipes
DAYS=10
TIMESTAMP=$(date +"%Y%m%d-%H%M")
WEEKDAY=$(date +%u)
CONTAINER=recipes_db
POSTGRES_USER=$(docker exec $CONTAINER env | grep POSTGRES_USER | cut -d"=" -f2)

<<Restore
    # Restore Test:
    cd /home/olaf/Documents/homelab/docker/recipes
    docker compose down
    sudo rm -rf /var/docker/recipes/postgresql/data
    sudo ls -la /var/docker/recipes/postgresql/data
    docker compose up -d
    docker exec $CONTAINER env
    zcat "/media/backup/docker-01/recipes/recipes_db-202207051554.sql.gz" | docker exec -i $CONTAINER psql -d djangodb -U djangouser -W
Restore

echo -e "Start $TIMESTAMP Backup for Databases: \n"
if [ ! -d $BACKUPDIR ]; then
	mkdir -p $BACKUPDIR
fi

echo -e " create Backup for Database on Container:\n  * $i";
docker exec $CONTAINER pg_dumpall -c -U $POSTGRES_USER | gzip > "$BACKUPDIR/daily-$CONTAINER-$TIMESTAMP.sql.gz"

if [ $WEEKDAY -eq 1 ]; then   # immer Montags
    docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$MYSQL_PWD $CONTAINER /usr/bin/mysqldump -u root $MYSQL_DATABASE | gzip > "$BACKUPDIR/weekly-$CONTAINER-$TIMESTAMP.sql.gz"
fi

OLD_BACKUPS=$(ls -1 "$BACKUPDIR/daily-$CONTAINER*.gz" |wc -l)
if [ $OLD_BACKUPS -gt $DAYS ]; then
    find $BACKUPDIR -name "daily-$CONTAINER*.gz" -daystart -mtime +$DAYS -delete
fi

echo -e "\n$TIMESTAMP Backup for Databases completed\n" 

