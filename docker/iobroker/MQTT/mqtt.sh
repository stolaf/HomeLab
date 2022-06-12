#Tutorial von M.Kleine
https://haus-automatisierung.com/mqtt-kurs/Uecezbg6FMMfMyC6u/

#MQTT Desktop Client:
http://mqttfx.jensd.de/index.php/download

# Die Installation erfolgt auf der ioBroker VM.
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install vim wget git
sudo apt-get install mosquitto
cd ~
vi mosquitto_passwords
ostagge:Maur!t!us2
mosquitto_passwd -U mosquitto_passwords
cat mosquitto_passwords

sudo mv mosquitto_passwords /etc/mosquitto/
cd /etc/mosquitto/
sudo chown root:root mosquitto_passwords

cd conf.d/
sudo vi access.conf
allow_anonymous false
password_file /etc/mosquitto/mosquitto_passwords
sudo service mosquitto restart

sudo apt-get install mosquitto-clients

#Publishen
mosquitto_pub -h localhost -t /Bash/Test -m "Das ist ein Test" -u ostagge -P Maur!t!us2

#Abonnieren
mosquitto_sub -h localhost -t /shelly/0 -u ostagge -P Mau***
