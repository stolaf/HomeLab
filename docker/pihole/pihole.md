# PiHole

[Doku](https://docs.pi-hole.net/)  
[Link](http://192.168.178.2:8089/admin/)  
ssh pi@192.168.178.2

## Installation (ohne Docker)

sudo apt update && sudo apt upgrade -y
apt dist-upgrade  
curl -sSL https://install.pi-hole.net | bash

### PiHole Commands StandAlone

ssh pi@192.168.178.2 pihole -a -p  #Change Password for Admin Interface  
ssh pi@192.168.178.2 pihole -v  
ssh pi@192.168.178.2 pihole -up   #Update PiHole SubSystem  
ssh pi@192.168.178.2 pihole -g # Update Gravity  
ssh pi@192.168.178.2 pihole -f  #flush PiHole Log  
ssh pi@192.168.178.2 pihole arpflush  
ssh pi@192.168.178.2 pihole -t # Tail : Live Logging  
ssh pi@192.168.178.2 pihole disable 5m  #  #5s: 5 Sek  
ssh pi@192.168.178.2 pihole -a email olaf.stagge@posteo.de  
ssh pi@192.168.178.2 pihole restartdns  
ssh pi@192.168.178.2 pihole -w foo.bar.com baz.com  # Whitelisting  
ssh pi@192.168.178.2 pihole -t  #Live Log Output

### PiHole Command Docker

ssh pi@192.168.178.2
ssh pi@192.168.178.2 docker ps
docker exec -it pihole pihole -a -p
docker exec -it pihole pihole -v
docker exec -it pihole pihole -g
docker exec -it pihole pihole -t

### Pihole BlackLists

ssh pi@192.168.178.2 pihole -b unifi-report.ubnt.com  
ssh pi@192.168.178.2 pihole -b fw-update.ubnt.com  
ssh pi@192.168.178.2 pihole -b ping.ui.com  
ssh pi@192.168.178.2 pihole -b powershellservice.com  

docker exec -it pihole pihole -b unifi-report.ubnt.com  
docker exec -it pihole pihole -b fw-update.ubnt.com  
docker exec -it pihole pihole -b ping.ui.com  
docker exec -it pihole pihole -b powershellservice.com  

## PiHole Whitelist  

[Github Script](https://github.com/anudeepND/whitelist)

### PiHole Blacklist über WebFrontend unter Group Management

``` html
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts  
https://dbl.oisd.nl/  
https://v.firebog.net/hosts/static/w3kbl.txt  
https://mirror1.malwaredomains.com/files/justdomains  
http://malwaredomains.lehigh.edu/files/immortal_domains.txt  
http://www.malwaredomainlist.com/hostslist/hosts.txt  
https://gitlab.com/zerodot1/coinblockerlists/raw/master/list.txt  
https://gitlab.com/zerodot1/coinblockerlists/raw/master/list_browser.txt  
https://gitlab.com/zerodot1/coinblockerlists/raw/master/list_optional.txt  
https://mirror.cedia.org.ec/malwaredomains/immortal_domains.txt  
https://mirror1.malwaredomains.com/files/justdomains  
https://raw.githubusercontent.com/dawsey21/lists/master/main-blacklist.txt  
https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/hosts.txt  
https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt  
https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt  
https://raw.githubusercontent.com/piwik/referrer-spam-blacklist/master/spammers.txt  
https://raw.githubusercontent.com/ultimate-hosts-blacklist/antipopads/master/clean.list  
https://raw.githubusercontent.com/yhonay/antipopads/master/hosts  
https://raw.githubusercontent.com/yous/youslist/master/hosts.txt  
https://www.malwaredomainlist.com/hostslist/hosts.txt  
https://github.com/hoshsadiq/adblock-nocoin-list/raw/master/hosts.txt  
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts  
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt  
https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/
https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt  
https://raw.githubusercontent.com/jerrimath/GalComm_Blocklist/master/Galcomm-Hosts-Formatted.txt  
https://justdomains.github.io/blocklists/lists/nocoin-justdomains.txt  
https://zerodot1.gitlab.io/CoinBlockerLists/list.txt  
https://zerodot1.gitlab.io/CoinBlockerLists/list_browser.txt  
https://zerodot1.gitlab.io/CoinBlockerLists/list_optional.txt  
https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser  
https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt  
http://mirror1.malwaredomains.com/files/justdomains  
https://raw.githubusercontent.com/jonschipp/mal-dnssearch/master/mandiant_apt1.dns  
https://raw.githubusercontent.com/Sekhan/TheGreatWall/master/TheGreatWall.txt  
https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter-domains-online.txt  
https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter-domains.txt  
https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter-hosts-online.txt  
https://raw.githubusercontent.com/KitsapCreator/pihole-blocklists/master/scam-spam.txt  
http://www.joewein.net/dl/bl/dom-bl.txt  
https://urlhaus.abuse.ch/downloads/hostfile/  
http://malwaredomains.lehigh.edu/files/justdomains  
https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/nocoin.txt  
https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/  
https://Locky-Ransomware-C2-Domain-Blocklist.txt  
https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/ 
https://CryptoWall-Ransomware-C2-Domain-blocklist.txt  
https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/  
https://TeslaCrypt-Ransomware-Payment-Sites-Domain-Blocklist.txt  
https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/  
https://TorrentLocker-Ransomware-C2-Domain-Blocklist.txt  
https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/  
https://TorrentLocker-Ransomware-Payment-Sites-Domain-Blocklist.txt  
https://raw.githubusercontent.com/anudeepND/blacklist/master/CoinMiner.txt  
```
