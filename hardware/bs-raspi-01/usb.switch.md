# USB Powerschalter

<https://github.com/darrylb123/usbrelay>  
<https://german.alibaba.com/product-detail/hw-343-5v-drive-free-usb-control-switch-2-way-relay-module-computer-control-switch-pc-intelligent-control-62576479376.html>  

## 2 Kanal 5V USB-Relay-2 HW-343

![alt text](Software/docker/raspi-02/pictures/2-Kanal-Relay.png "USB Relay")

``` bash
sudo apt-get install usbrelay  

sudo usbrelay 1_1=1  #Relay 1 ON
sudo usbrelay 1_1=0  #Relay 1 OFF

sudo usbrelay 1_2=1  #Relay 2 ON
sudo usbrelay 1_2=0  #Relay 2 OFF

sudo usbrelay HURTM_1=1  #Relay 1 ON
sudo usbrelay HURTM_1=0  #Relay 1 OFF
sudo usbrelay HURTM_2=1  #Relay 1 ON
sudo usbrelay HURTM_2=0  #Relay 1 OFF

ssh pi@192.168.178.3 usbrelay 1_1=1   # 3-D Drucker ON
ssh pi@192.168.178.3 usbrelay 1_1=0   # 3-D Drucker OFF
```  

Get Relay State: 0: aus 1: an
sudo usbrelay

