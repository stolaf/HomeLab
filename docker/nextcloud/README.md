# NextCloud
Nextcloud ist wohl die am weitesten verbreitete Lösung um einen persönlichen Cloud Speicher anzulegen.

## Installation
Bei der Ersteinrichtung - 1. Aufruf der Website - einen neuen Benutzer ncadmin anlegen. DB-Einstellungen auf default lassen (auch wenn SQLLite angezeigt wird :-))

Wichtig, sonst funktioniert der Desktop Client nicht
sudo nano /var/docker/nextcloud/app/config/config.php
    'overwrite.cli.url' => 'https://nextcloud.stagge.it',
    'overwriteprotocol' => 'https',

## fulltextsearch
https://github.com/nextcloud/fulltextsearch/wiki  
https://www.c-rieger.de/volltextsuche-mit-nextcloud-20-elasticsearch-und-tessaract/  


## Kalender
https://www.schulferien.org/deutschland/ical/  
