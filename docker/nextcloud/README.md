# NextCloud
Nextcloud ist wohl die am weitesten verbreitete Lösung um einen persönlichen Cloud Speicher anzulegen.

https://docs.nextcloud.com/server/latest/admin_manual/  

## Installation
Bei der Ersteinrichtung - 1. Aufruf der Website - einen neuen Benutzer ncadmin anlegen. DB-Einstellungen auf default lassen.  

![InitialSetup](/_attachments/Initialsetup.png))  

Wichtig, sonst funktioniert der Desktop Client nicht
sudo nano /var/docker/nextcloud/app/config/config.php
    'overwrite.cli.url' => 'https://nextcloud.stagge.it',
    'overwriteprotocol' => 'https',
    'trusted_domains' => 
    array (
        0 => '192.168.178.20',
        1 => 'nextcloud.stagge.it',
    ),
    'dbtype' => 'mysql',   # statt sqlite3

http://192.168.178.20:8082/?server=nextcloud-db&username=nextcloud&db=nextcloud  

## Update Container
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once nextcloud

## Problemlösungen
Neuinstalltion Nextcloud App in Version 24.0.2: Initial Setup mit Database Einrichtung funktioniert nicht: Das Datenverzeichnis /var/www/html/data kann nicht erstellt werden
--> Temporär den Container 22.2 installieren und das Initialsetup durchluafen lassen und dann aktuelle Version

## fulltextsearch
https://github.com/nextcloud/fulltextsearch/wiki  
https://www.c-rieger.de/volltextsuche-mit-nextcloud-20-elasticsearch-und-tessaract/  

## Kalender
https://www.schulferien.org/deutschland/ical/  
