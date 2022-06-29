# Guacamole

Guacamole ist ein Webbasierter RDP und SSH Client. Hiermit ist es möglich ohne VPN oder offene Ports eine Verbindung in das eigene Netzwerk aufzubauen und verschiedene Arbeiten durchzuführen.

## Links
https://www.youtube.com/watch?v=vMhjvGLeHrY  
https://github.com/MysticRyuujin/guac-install  
https://github.com/bigredthelogger/guacamole  
https://hub.docker.com/r/guacamole/guacamole  

## Installation
Vor dem Starten ist es noch notwendig die Datenbank zu initialisieren. 

````
sudo rm -rf /var/docker/guacamole

cd /home/olaf/Documents/homelab/docker/guacamole

# 1. Dankenbank Initialisierungsdatei erstellen falls erforderlich
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql

# 2. Datenbank Container starten
docker-compose up -d guacamole_mysql

# 3. Datenbank initialisieren
docker cp ./initdb.sql guacamole_mysql:/
docker exec -it guacamole_mysql sh
    mysql -u root -p$MYSQL_ROOT_PASSWORD guacamole_db < initdb.sql    # Warnmeldungen ignorieren

# 4. Datenbank Container stoppen
docker-compose stop guacamole_mysql

# 5. Guacamole komplett starten
docker-compose up -d

# 6. Anmelden initial mit guacadmin/guacadmin
````


## Troubleshooting
- bei Windows RDP Verbindungsproblemen: Serverzertitikat ignorieren  
- Connectionprobleme:  ```docker logs guacamole_guacd```