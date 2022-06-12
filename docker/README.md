# Docker

## Links
https://hub.docker.com/
https://github.com/cbirkenbeul/docker-homelab

## Installation
```
curl -fsSL https://get.docker.com -o get-docker.sh  
sudo sh get-docker.sh  
sudo usermod -aG docker $USER  

sudo apt-get install libffi-dev libssl-dev -y  
sudo apt install python3-dev -y  
sudo apt-get install python3 python3-pip -y  
sudo pip3 install docker-compose  
```

## Lazydocker
ct: 03/2022 S.79
https://github.com/jesseduffield/lazydocker
X-Taste öffnet Kontextmenue

```
wget https://github.com/jesseduffield/lazydocker/releases/download/v0.12/lazydocker_0.12_Linux_x86_64.tar.gz
tar xf lazydocker_0.12_Linux_x86_64.tar.gz 
sudo mv lazydocker /usr/local/bin
lazydocker
```

## Trivy
Container auf Schwachstellen untersuchen
https://ct.de/y2pe
[[c't.Container.Images.mit.Trivy.auf.Sicherheitlücken.durchleuchten.pdf]]

``` Installation Debian
sudo apt-get install wget apt-transport-https gnupg lsb-release 
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add - 
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list 
sudo apt-get update 
sudo apt-get install trivy
```

docker run -it aquasec/trivy
trivy image python:3.4-alpine   # falls trivy über apt installiert
docker run --rm -v ${PWD}/cache:/root/.cache aquasec/trivy python:3.4-alpine

trivy image --severity HIGH,CRITICAL python:3.4-alpine
trivy image --severity MEDIUM,HIGH --exit-code 0 python:3.4-alpine
trivy image --severity CRITICAL --exit-code 1 python:3.4-alpine

trivy image adminer
trivy image --severity CRITICAL vaultwarden/server

## Kuma
Webdienste mit Kuma überwachen  c't 26/2021 S.164
[[c't.WebDienste.mit.Kuma.überwachen.pdf]]


## kasmweb
https://kasmweb.com/
https://kasmweb.com/docs/latest/install.html
https://kasmweb.com/docs/latest/guide/custom_images.html?utm_campaign=Dockerhub&utm_source=docker

```
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/ubuntu-bionic-desktop:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/desktop-deluxe:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password -e LAUNCH_URL=http://youtube.com kasmweb/chromium:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/remmina:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/vs-code:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/desktop:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/tor-browser:1.10.0-rolling
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/postman:1.10.0-rolling
```

## SCP Copy

scp -r ~/homelab/volumes/heimdall/config olaf@192.168.178.20:/var/docker/heimdall
scp -r ~/homelab/volumes/tvheadend/config olaf@192.168.178.20:/var/docker/tvheadend
scp -r ~/homelab/volumes/tvheadend/picons olaf@192.168.178.20:/var/docker/tvheadend
scp -r ~/homelab/volumes/tvheadend/recording olaf@192.168.178.20:/var/docker/tvheadend
chmod 777 /var/docker/tvheadend/picons
sudo chown -cR olaf:olaf /var/docker/tvheadend/picons

## Arbeiten mit Dockker

#### **Einige docker Befehle**
```bash 
    docker version
    docker ps                     #zeigt alle Container an
    docker run -p 80:80 nginx     #Mode mit Logausgabe
    docker run -d -p 80:80 nginx  #detach Mode
    docker ps                     #überprüfen ob Container läuft
    docker logs <id>              #logs im Container
    docker stop <id>              #beendet einen Container
    docker rm <id>                #entfernt einen beendeten Container
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)    # alle gestoppten Container entsorgen
    docker rmi $(docker images -aq)   # alle images entsorgen
```

#### **Arbeiten im Container, erste Tests**
```bash 
    docker run -d -p 80:80 --name test nginx
    docker exec -it test bash   #in den Container hineinspringen, wenn kein bash vorhanden dann sh
        cd /usr/share/nginx/html
        apt update
        apt install nano
        nano index.html
        exit
    docker stop d96b6e3f9cc4
    docker rmi nginx --force
    docker inspect traefik |grep -i version
```

#### **Arbeiten mit Volumes**
Parameter -v: Vor dem Doppelpunkt Pfad zur Datei bzw. Ordner, nach den Doppelpunkt das Ziel im Container
Volumes müssen als absoluter Pfad angegeben werden! Daher ${PWD}
```bash 
    echo "Container in der Praxis" > index.html
    docker run -d -p 80:80 -v ${PWD}/index.html:/usr/share/nginx/html/index.html --name testvolumes nginx
    http://192.168.178.32
```

#### **Arbeiten mit Images**
```bash 
    nano Dockerfile
        FROM debian:buster-slim
        RUN apt-get update && apt-get install iputils-ping
        CMD ping -c 4 heise.de
    
    docker build .
    docker run <id>
```

#### **Verwalten von Images**
```bash 
    docker images
    docker tag <id> simpleping:latest   #sprechenden Namen vergeben
    docker run simpleping
    docker build -t simpleping .    #Image gleich mit sprechenden Namen bauen
    docker image rm simpleping     #oder id
    docker image prune              #ungenutzte Images löschen
    docker image prune --all --force
    docker run --rm simpleping      #gestoppten Container sofort abräumen
```

#### **Docker Compose**
```bash 
    docker-compose version

    mkdir wordpress
    cd wordpress
    #in VSCode
    cat .\VMs\docker\wordpress\docker-compose.yml | ssh olaf@192.168.178.32 "cat >> ./wordpress/docker-compose.yml" 
   
   docker-compose up
   docker-compose up -d
   docker-compose -f docker-compose.yml docker-compose.dev.yml  #die Angaben in der letzten Datei ersetzen die zuvor angegeben Werte
   docker-compose down 
   docker-compose ps
   docker-compose exec <service> bash
   #z.B.
   docker-compose exec db bash
```

#### **mkdocs**
```bash 
    docker exec -it 074ff8555a8a sh 
    docker stop $(docker ps -aq)
    docker build .
    docker run -d -p 80:8080 4a69fd99a636
```