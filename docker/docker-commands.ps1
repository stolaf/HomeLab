break

<#
Damit sich alle Container untereinander finden in verschiedenen Projektverzeichnissen muss man  
ein Dockernetzwerk einrichten und das in allen Compose-Dateien mit den Containeren verknüpfen
#>

docker compose -f ./adminer/docker-compose.yml up -d
docker compose -f ./adminer/docker-compose.yml down
docker compose -f ./adminer/docker-compose.yml start
docker compose -f ./adminer/docker-compose.yml stop
docker compose -f ./adminer/docker-compose.yml pull
docker compose -f ./adminer/docker-compose.yml build

docker compose -f ~/Documents/homelab/docker/influxdb_grafana/docker-compose.yml up 
docker compose -f ~/Documents/homelab/docker/influxdb_grafana/docker-compose.yml down

docker compose -f ~/Documents/homelab/docker/influxdb/docker-compose.yml up 
docker compose -f ~/Documents/homelab/docker/influxdb/docker-compose.yml down

docker logs -f traefik
docker stop $(docker ps -aq)
docker rmi $(docker images -aq) -f

#Auflisten aller verwendeten Ports  
docker container ls --format "table {{.Names}}\t{{.Ports}}" | Sort-object Ports

#Aufräumarbeiten  
docker rm $(docker ps -a -q -f ancestor=python)
docker rmi $(docker images python -f dangling=true -q)
docker rmi $(docker images -q)  -f

# Container auf ein anders System bringen ohne Internet
docker save meincontainer > save.tar.gz
docker load < save.tar.gz

# Container aktualisieren
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once 
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once nginx redis