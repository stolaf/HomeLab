# Docker

## Links
https://4sysops.com/archives/configure-windows-server-2019-container-host-with-powershell/
https://4sysops.com/archives/using-docker-commands-to-manage-windows-server-2016-containers/

# Aufräumarbeiten per CLI
docker rm $(docker ps -a -q -f ancestor=python)
docker rmi $(docker images python -f dangling=true -q)
docker rmi $(docker images -q)  -f

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

## docker-compose
https://www.heise.de/ct/artikel/Docker-einrichten-unter-Linux-Windows-macOS-4309355.html#nav_installieren__1
apt install docker-compose-plugin
Auch das Updaten ist einfach – mit `apt upgrade` werden Docker und Docker-Compose auf den aktuellen Stand gebracht.

## Copy File from docker-01

``` bash
# Backup unter ~/Documents/Powershell/backup/docker
scp olaf@192.168.178.20:~/homelab/docker-compose.yml .\backup\docker-01\docker-compose.yml   #oder
scp olaf@192.168.178.20:~/homelab/docker-compose.yml ./backup/docker-01/docker-compose.yml
scp olaf@192.168.178.20:~/homelab/.env .\backup\docker-01\.env
```

## Dockerbefehle

docker logs -f traefik
docker stop $(docker ps -aq)
docker rmi $(docker images -aq) -f

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

