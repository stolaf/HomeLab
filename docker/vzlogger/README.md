# VZLogger Volkszähler

https://hub.docker.com/r/torstend/vzlogger
https://github.com/t3r/vzlogger-docker

https://hub.docker.com/r/treban/smartmeter-vzlogger
https://hub.docker.com/r/treban/smartmeter-vzlogger-rpi  


https://digitmind.net/aktuelllen-stromverbrauch-mithilfe-von-volkszaehler-in-iobroker-speichern/

evtl. wenn Access denied im Container: sudo chmod 666 /dev/ttyUSB0

docker run --read-only -v $PWD/vzlogger.conf:/etc/vzlogger.conf:ro -device=/dev/ttyUSB0  -p8080:8080 -t torstend/vzlogger --httpd --httpd-port 8080

docker run -i -t -v /media/docker/vzlogger:/cfg --device=/dev/ttyUSB0 treban/smartmeter-vzlogger-rpi
docker run -i -t -v ./vzlogger.conf:/cfg --device=/dev/ttyUSB0 treban/smartmeter-vzlogger-rpi

docker run -i -t -v $PWD/vzlogger.conf:/etc/vzlogger.conf:ro -p8080:8080 --device=/dev/ttyUSB0 -t torstend/vzlogger --httpd --httpd-port 8080

nano /media/docker/vzlogger/vzlogger.conf  

## Forum  
https://www.photovoltaikforum.com/board/5-datenlogger  
https://www.photovoltaikforum.com/board/131-volkszaehler-org  

https://wiki.volkszaehler.org/howto/raspberry_pi_image  
https://wiki.volkszaehler.org/software/middleware/einrichtung  

## Inbetriebnahme
cat /dev/ttyUSB0  : Hier müssten jetzt Daten reinkommen

## InfluxDB
https://github.com/volkszaehler/vzlogger/blob/master/etc/vzlogger.conf.InfluxDB