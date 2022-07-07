#!/usr/bin/env bash

# ls -la /home/olaf/Documents/homelab/docker/*/backup*.sh
# chmod +x /home/olaf/Documents/homelab/docker/*/backup*.sh

# ls -la /var/docker/bitwarden
# sudo ln -s /home/olaf/Documents/homelab/docker/bitwarden/backup-vaultwarden.sh /etc/cron.daily/backup-vaultwarden
# ls -la /etc/cron.daily

export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WEEKDAY=$(date +%u)
DAYS=10

docker compose -f /home/olaf/Documents/homelab/docker/bitwarden/docker-compose.yml down

sqlite3 /var/docker/bitwarden/db.sqlite3 .dump | gzip -c  > "/media/backup/bs-docker-01/bitwarden/daily-bitwarden-db-$(date '+%Y%m%d-%H%M').dump.gz"

if [ $WEEKDAY -eq 1 ]; then   # immer Montags
    sqlite3 /var/docker/bitwarden/db.sqlite3 .dump | gzip -c  > "/media/backup/bs-docker-01/bitwarden/weekly-bitwarden-db-$(date '+%Y%m%d-%H%M').dump.gz"
    zip -r "/media/backup/bs-docker-01/bitwarden/weekly-bitwarden-$(date '+%Y%m%d-%H%M').zip" /var/docker/bitwarden 1> /dev/null
fi

OLD_BACKUPS=$(ls -1 /media/backup/bs-docker-01/bitwarden/daily-*.gz |wc -l)
if [ $OLD_BACKUPS -gt $DAYS ]; then
	find /media/backup/bs-docker-01/bitwarden -name "daily-*.gz" -daystart -mtime +$DAYS -delete
fi

docker compose -f /home/olaf/Documents/homelab/docker/bitwarden/docker-compose.yml up -d 

<<Restore
    zcat "/media/backup/bs-docker-01/bitwarden/daily-bitwarden-db-20220706-1409.dump.gz" | sqlite3 /var/docker/bitwarden/db.sqlite3
    unzip -d /var/docker/bitwarden/ "/media/backup/bs-docker-01/bitwarden/weekly-bitwarden-20220706-1432.zip"
Restore
