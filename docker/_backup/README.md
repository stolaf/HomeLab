# Backup der Docker Volumes

## DBs
Anregungen geholt von:  
https://github.com/alaub81/backup_docker_scripts  
https://www.laub-home.de/wiki/Startseite  

# ls -la /home/olaf/Documents/homelab/docker/*/backup*.sh
chmod +x /home/olaf/Documents/homelab/docker/*/backup*.sh

## Regelmäßiger Backup
https://www.laub-home.de/wiki/Docker_MySQL_and_MariaDB_Backup_Script  

Will man nun das Script regelmäßig, zum Beispiel täglich ausführen, reicht es einen Symlink in das cron.daily Verzeichnis zu legen:
```
ln -s /usr/local/sbin/backup-docker-mysql.sh /etc/cron.daily/backup-docker-mysql
```

## Restore
https://www.laub-home.de/wiki/Docker_MySQL_and_MariaDB_Backup_Script  

### mysql/mariadb
$Container = 'guacamole_mysql'
$MYSQL_DATABASE = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_DATABASE' } | cut -d"=" -f2)
$MYSQL_PWD = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_ROOT_PASSWORD' } | cut -d"=" -f2)

zcat BACKUPFILE.sql.gz | docker exec -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE
cat /home/olaf/backup/mysql/guacamole_mysql-guacamole_db-20220617-1314.sql | docker exec -i -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE

## Test Guacamole (maria/mysql)
https://www.laub-home.de/wiki/Docker_MySQL_and_MariaDB_Backup_Script  

$Container = 'guacamole_mysql'
$MYSQL_DATABASE = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_DATABASE' } | cut -d"=" -f2)
$MYSQL_PWD = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_ROOT_PASSWORD' } | cut -d"=" -f2)

docker exec -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE -e 'SHOW DATABASES;'
docker exec -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE -e 'SHOW FULL TABLES;'
docker exec -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE -e 'SELECT * FROM guacamole_connection;'
docker exec -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE -e 'SELECT * FROM guacamole_connection_group;'

docker-compose -f /home/olaf/Documents/homelab/docker/guacamole/docker-compose.yml down
sudo rm -rf /var/docker/guacamole
ls -la /var/docker/guacamole
docker-compose -f /home/olaf/Documents/homelab/docker/guacamole/docker-compose.yml up -d

$Container = 'guacamole_mysql'
$MYSQL_DATABASE = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_DATABASE' } | cut -d"=" -f2)
$MYSQL_PWD = $(. docker exec $Container env | Where-Object { $_ -match 'MYSQL_ROOT_PASSWORD' } | cut -d"=" -f2)
cat /home/olaf/backup/mysql/guacamole_mysql-guacamole_db-20220617-1314.sql | docker exec -i -e "MYSQL_DATABASE=$MYSQL_DATABASE" -e "MYSQL_PWD=$MYSQL_PWD" $Container /usr/bin/mysql -u root $MYSQL_DATABASE

