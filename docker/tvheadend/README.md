# TVHeadend

https://tvheadend.readthedocs.io/en/latest/ 

admin | 19... 
ola | Mau...
Abmeldung in Chromium funktioniert manchmal nicht --> private Modus oder Edge Browser benutzen

User Administrator "VFZIZWFkZW5kLUhpZGUtQUJDYWJjMTIz"
User Kodi  "VFZIZWFkZW5kLUhpZGUtQUJDYWJjMTIz"

```Powershell
[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("VFZIZWFkZW5kLUhpZGUtQUJDYWJjMTIz"))
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("VFZIZWFkZW5kLUhpZGUtQUJDYWJjMTIz"))
```

start-process "\\192.168.178.25\data\videos\Anleitungen\TVHeadend\Julian-tvheadend.Erstkonfiguration.mp4"

## Sender Logos
https://www.google.com/search?q=vodafone+picons&oq=vodafone+picons&aqs=chrome..69i57j0i22i30l2.2527j0j1&sourceid=chrome&ie=UTF-8

https://smooth-ones.de/technik/iptv/tv-senderlogos/  
Unter Configuration/general/Base/Channel icon Path einbinden.  

User Administrator + Kodi

## Recording
sudo chmod -R 777 /var/docker/tvheadend/recordings

echo -n  "VFZIZWFkZW5kLUhpZGUtQUJDYWJjMTIz" | base64 -d ; echo -e '\n'
echo -n 'TVHeadend-Hide-SuperSecret' | base64