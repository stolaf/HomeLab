
mein IOBroker: http://192.168.178.24:8081/login/index.html?href=%2F

# API-Key: @pro_olaf.stagge@posteo.de_d3b772d0-2d41-11e9-87c0-8f10246b2498

sudo su
apt-get update && apt-get upgrade -y
apt dist-upgrade
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y build-essential libavahi-compat-libdnssd-dev libudev-dev libpam0g-dev nodejs
npm install -g npm@4

sudo mkdir /opt/iobroker
sudo chmod 777 /opt/iobroker
cd /opt/iobroker
sudo npm install iobroker --unsafe-perm
sudo iobroker start
