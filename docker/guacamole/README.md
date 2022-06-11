# Guacamole

Guacamole ist ein Webbasierter RDP und SSH Client. Hiermit ist es möglich ohne VPN oder offene Ports eine Verbindung in das eigene Netzwerk aufzubauen und verschiedene Arbeiten durchzuführen.

https://hub.docker.com/r/guacamole/guacamole

# Installation
Vor dem Starten ist es noch notwendig die Datenbank zu initialisieren. 

1. Dankenbank Initialisierungsdatei erstellen

````docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql````

2. Datenbank Container starten

````docker-compose up -d guacamole_mysql````

3. Datenbank initialisieren

````docker exec -i guacamole_mysql mysql -uroot -p{MYSQL_PASSWORD} guacamole_db < initdb.sql````  
````docker exec -i guacamole_mysql mysql -u root -p19IL... guacamole_db < initdb.sql````  
 

4. Datenbank Container stoppen

````docker-compose stop guacamole_mysql````

5. Guacamole komplett starten

````docker-compose up -d````

6. Anmelden initial mit guacadmin/guacadmin

## Links
https://www.youtube.com/watch?v=vMhjvGLeHrY  
https://github.com/MysticRyuujin/guac-install https://github.com/bigredthelogger/guacamole