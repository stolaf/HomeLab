# Duplicati

Backup-Software mit Verschlüsselung, Kompression etc.

## Links
https://hub.docker.com/r/duplicati/duplicati  

https://www.duplicati.com/articles  
https://duplicati.readthedocs.io/en/latest  
https://github.com/duplicati  
https://forum.duplicati.com  

## Thunderbird Backup
Profilordner ermitteln: Thunderbird/Burger Menu/Hilfe/Informationen zur Fehlerbehebung  

## Commandline
https://duplicati.readthedocs.io/en/latest/04-using-duplicati-from-the-command-line  

Duplicati.CommandLine.exe <command> [storage-URL] [arguments] [advanced-options]

``` powershell
$NASPassword = "Mau..."  
$PassPhrase = "Tr..."  

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" backup "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "C:\Users\olaf\Documents" "C:\Users\olaf\AppData\Roaming\Thunderbird\Profiles\\" "C:\Users\olaf\.ssh\\" "C:\Users\olaf\.vscode\\" --backup-name=Documents --dbpath="C:\Users\olaf\AppData\Local\Duplicati\RJDYSTAZGC.sqlite" --encryption-module=aes --compression-module=zip --dblock-size=50mb --passphrase="$PassPhrase" --disable-module=console-password-input

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" restore "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "C:\Users\olaf\Documents" "C:\Users\olaf\AppData\Roaming\Thunderbird\Profiles\\" "C:\Users\olaf\.ssh\\" "C:\Users\olaf\.vscode\\" --backup-name=Documents --dbpath="C:\Users\olaf\AppData\Local\Duplicati\RJDYSTAZGC.sqlite" --encryption-module=aes --compression-module=zip --dblock-size=50mb --disable-module=console-password-input

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" restore "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "Abrechnungen Hans-Hoffmann-Weg 21.ods" 

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" find "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "Abrechnungen Hans-Hoffmann-Weg 21.ods"

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" find "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "id_rsa.pub"

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" help restore

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" restore "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "C:\Users\olaf\.ssh\*" 

. "C:\Program Files\Duplicati 2\Duplicati.CommandLine.exe" restore "ssh://192.168.178.6:22/export/backup/duplicati/pc-01?auth-username=olaf&auth-password=$NASPassword&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" "C:\Users\olaf\.ssh\id_rsa.pub" 

code ``` 
