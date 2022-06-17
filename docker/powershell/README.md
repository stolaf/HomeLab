# Powershell

# Version 7.1.3
docker pull huiyifyj/pwsh
docker run -it huiyifyj/pwsh

docker build .
docker run -it c62723ad510b

## Microsoft
https://hub.docker.com/_/microsoft-powershell

# Version 7.2.4
docker run --rm -it --name powershell mcr.microsoft.com/powershell 

# Version 7.3.0-preview.4
docker run --rm -it --name powershell_preview mcr.microsoft.com/powershell:preview 

docker ps --format '{{.Names}}:{{.Image}}' | Sort-Object

# for latest
docker pull docker.pkg.github.com/badgerati/pode/pode:latest


