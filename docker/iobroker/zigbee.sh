# ZigBee USB-Stick CC2531

https://www.zigbee2mqtt.io/information/supported_devices.html

https://haus-automatisierung.com/projekt/2018/04/28/projekt-xiaomi-ohne-cloud.html

# auf Proxmox Host
lsusb | grep Texas
sudo qm set 124 -usb0 host=0451:16a8

# in VM (usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B00193B0566-if00)
sudo ls -l /dev/serial/by-id
