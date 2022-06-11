# MkDocker

MkDocs in Docker container. 

## Usage

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images -aq)
docker-compose -f docker-compose-dev.yml up
```


## Develop docs 
For development start with docker-compose:

### Dev Umgebung
```
docker-compose -f docker-compose-dev.yml up
```

Container starts an page is running on port 8080. You can live edit.


## Run in production

For production start with docker-compose 

```
docker-compose up -d
```

docker exec -it <id> sh
ls /usr/share/nginx/html

docker pull docker.pkg.github.com/stolaf/mkdocker/my-mkdocs:latest
docker run -p 80:8080 docker.pkg.github.com/stolaf/mkdocker/my-mkdocs:latest
docker-compose -f docker-compose-watchtower.yml up -d
docker-compose -f docker-compose-watchtower.yml down

docker run -it mcr.microsoft.com/powershell
Invoke-RestMethod -Method Get -Uri "https://192.168.178.15/redfish/v1/Systems/1" -SkipCertificateCheck -Headers @{Authorization = "Basic QURNSU46MTlJTCEhZmlkRHI0IzYx"}
