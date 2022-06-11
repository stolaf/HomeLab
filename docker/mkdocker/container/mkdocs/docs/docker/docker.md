# Docker auf Ubuntu 20.04 Server

- für produktiven Einsatz
- 16GB RAM, 60GB HDD

----
#### **Installation**
```bash
    ssh olaf@192.168.178.32
    sudo apt update && sudo apt upgrade -y

    #ohne Sudo
    mkdir .ssh
    cd .ssh
    touch authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    cat $env:USERPROFILE\.ssh\id_rsa.pub | ssh olaf@192.168.178.21 "cat >> .ssh/authorized_keys"

    sudo apt install curl htop nfs-common inxi python3-pip -y
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER  #aktueller User zur docker Gruppe hinzufügen um als normaler User docker Befehle ausführen zu können
    docker version

    https://docs.docker.com/compose/install/
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/dockercompose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo rm /usr/local/bin/docker-compose   #To uninstall Docker Compose if you installed using curl:
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    docker-compose version
```

#### **Einige docker Befehle**
```bash 
    docker version
    docker ps                     #zeigt alle Container an
    docker run -p 80:80 nginx     #detach Mode mit Logausgabe
    http://192.168.178.32
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
