#!/usr/bin/env bash

# ls -la /home/olaf/Documents/homelab/docker/*/backup*.sh
# chmod +x /home/olaf/Documents/homelab/docker/*/backup*.sh

# ls -la /var/docker/heimdall/config
# sudo ln -s /home/olaf/Documents/homelab/docker/heimdall/backup-heimdall.sh /etc/cron.daily/backup-heimdall
# ls -la /etc/cron.daily

export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WEEKDAY=$(date +%u)
DAYS=10

docker compose -f /home/olaf/Documents/homelab/docker/heimdall/docker-compose.yml down

zip -r "/media/backup/bs-docker-01/heimdall/daily-heimdall-$(date '+%Y%m%d-%H%M').zip" /var/docker/heimdall/config 1> /dev/null

if [ $WEEKDAY -eq 1 ]; then   # immer Montags
    zip -r "/media/backup/bs-docker-01/heimdall/weekly-heimdall-$(date '+%Y%m%d-%H%M').zip" /var/docker/heimdall/config 1> /dev/null
fi

OLD_BACKUPS=$(ls -1 /media/backup/bs-docker-01/heimdall/daily*.gz |wc -l)
if [ $OLD_BACKUPS -gt $DAYS ]; then
	find /media/backup/bs-docker-01/heimdall -name "daily-*.gz" -daystart -mtime +$DAYS -delete
fi

docker compose -f /home/olaf/Documents/homelab/docker/heimdall/docker-compose.yml up -d 

<<Restore
   
Restore
