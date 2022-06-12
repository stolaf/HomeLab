#!/bin/bash

# docker exec duplicati duplicati-cli backup "ssh://192.168.178.6:22//export/backup/duplicati/raspi-01?auth-username=olaf&auth-password=Maur"'!'"t"'!'"us2&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" /IOTstack/ --backup-name=raspi-01 --dbpath=/data/Duplicati/WFPPELDBPF.sqlite --encryption-module=aes --compression-module=zip --dblock-size=50mb --passphrase="Tr"'!'"n"'!'"dat#2" --disable-module=console-password-input

# docker exec duplicati duplicati-cli delete "ssh://192.168.178.6:22//export/backup/duplicati/raspi-01?auth-username=olaf&auth-password=Maur"'!'"t"'!'"us2&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" --version=3

docker exec duplicati mono /opt/duplicati/Duplicati.CommandLine.exe backup "ssh://192.168.178.6:22//export/backup/duplicati/raspi-01?auth-username=olaf&auth-password=Maur"'!'"t"'!'"us2&ssh-fingerprint=ssh-rsa%202048%202B%3A9C%3AD2%3A63%3A51%3AEE%3A9F%3AA8%3A1B%3A65%3AC3%3AA5%3AC1%3A99%3A15%3AED" /IOTstack/ --backup-name=raspi-01 --dbpath=/data/Duplicati/TTQSNNPQYC.sqlite --encryption-module=aes --compression-module=zip --dblock-size=50mb --passphrase="Tr"'!'"n"'!'"dat#2" --disable-module=console-password-input
