# Minecraft

```
docker run -d -v /media/docker/minecraft:/data -e VERSION=1.8.2 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server
docker run -d -v /media/docker/minecraft:/data -e VERSION=1.7.1 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server
docker run -d -e VERSION=1.7.1 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server
docker run -d -v /media/docker/minecraft:/data -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server

docker run -d -v /media/docker/minecraft:/data -e VERSION=1.8.2 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server

docker logs <container ID>

192.168.178.25:/export/data/docker /media/docker nfs rw 0 0

docker run -it -p 27015:27015/tcp -p 27015:27015/udp -e "AUTHKEY=7C7DD41AD21C143506F05D99F2B9AF26" -e "GAMEMODE=terrortown" -e "MAP=ttt_minecraft_b5" -e "WORKSHOP=729810983" -e "WORKSHOPDL=729810983" -v ./server.cfg:/opt/steam/garrysmod/cfgserver.cfg --name garrysmod  hackebein/garrysmod
```

```
docker run -d -v /media/docker/minecraft:/data -e VERSION=1.8.2 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server
docker run -d -v /media/docker/minecraft:/data -e VERSION=1.7.1 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server
docker run -d -e VERSION=1.7.1 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server
docker run -d -v /media/docker/minecraft:/data -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server

docker run -d -v /media/docker/minecraft:/data -e VERSION=1.8.2 -p 25565:25565 -e EULA=TRUE --name mc itzg/minecraft-server

docker logs <container ID>

192.168.178.25:/export/data/docker /media/docker nfs rw 0 0
```
