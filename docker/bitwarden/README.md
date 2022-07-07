# Bitwarden_rs
Bitwarden_rs ist ein fork des beliebten Passwort Managers Bitwarden. Dieser Fork hat den Vorteil ohne schwere Microsoft SQL Server Instanz auzukommen.
Daher besteht dieser Service nur aus einem Container und nicht auf einer vielzahl.

https://hub.docker.com/r/vaultwarden/server  
https://github.com/dani-garcia/vaultwarden

http://192.168.178.20:8084


## Backup
https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault#restoring-backup-data  

## WICHTIG!
Bei Problemem mit Bitwarden: 
[Entwickler](https://github.com/dani-garcia/bitwarden_rs)

## CLI
https://docs.bitwarden.com/api
https://help.bitwarden.com/article/public-api

* https://bw.stagge.it/identity/connect/token
* https://bw.stagge.it/api
* https://bw.stagge.it/api/docs/

CLI in PS Console   https://vault.bitwarden.com/download/?app=cli&platform=windows
* [[https://help.bitwarden.com/article/cli/#generate]]
* bw config server https://bitwarden.stagge.it
* bw config server
* bw login olaf.stagge@posteo.de 19Vo...
* bw get fingerprint me
* bw login --apikey sulk-autism-thigh-encore-sanction
* $env:BW_SESSION="yLq8Y+B7eWPjHR3v3MqkGg+vS01O00aCveOnXFxNRgLeYzqJO2j4PRJvkyjG1sM17xkqUwd8QJcQvKUKqjXAYQ=="   #ändert sich nach jedem Login
* bw update
* bw status  -- > UserID: "7b0d90cf-14d6-4c37-8bff-27161c72debc"
* $env:BW_CLIENTID = "7b0d90cf-14d6-4c37-8bff-27161c72debc"
* bw --version
* bw list items
* bw unlock [password]
* bw generate -ulns --length 20
* bw generate -lusn --length 18
* bw get item github
* bw get username github
* bw get password github
* bw get item github | ConvertFrom-Json
* bw export --format json --output ./my_backup.json
* bw export --format csv --output ./my_backup.csv

