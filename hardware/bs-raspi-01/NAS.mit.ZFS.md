# NAS mit ZFS

<https://www.heise.de/tests/Massgeschneidertes-NAS-mit-freier-Software-4340098.html>  
<https://www.heise.de/ratgeber/Raspberry-Pi-4-Minimalistisches-NAS-mit-ZFS-Dateiverwaltung-selbst-bauen-4927272.html>


Raspberry Pi 4: Minimalistisches NAS mit ZFS-Dateiverwaltung selbst bauen
Für den privaten Datenschatz reicht ein Raspi-NAS. Ausgestattet mit Ubuntu Server, NFS und ZFS gestalten Sie Ihren sicheren Netzwerkspeicher in Eigenregie.

Ein NAS auf Basis eines Raspberry Pi ist im Handumdrehen betriebsbereit: Eine große MicroSD-Karte oder ein angestöpseltes USB-Laufwerk als Datenlager, dazu OpenMediaVault (OMV, Version 4 als Image, Version 5 als installierbares Paket) und schon kann man sich auf seinem Smartphone oder im Browser durch hunderte Menüs, Dialoge und Optionen schlängeln. Keine Frage, OMV ist eine gute gemachte Software und funktioniert prächtig – sofern man alles richtig konfiguriert. Sobald jedoch ein Tool, eine Konfiguration oder eine Funktion nicht von dessen Weboberfläche explizit unterstützt wird, benötigt OMV Handarbeit. Warum also nicht gleich ein minimalistisches, maßgeschneidertes Raspi-NAS mit den nötigsten Funktionen und einem sicherem Dateisystem von Hand selbst einrichten?

Dafür existieren etliche NAS-Distributionen auf OpenSource-Basis. Sie funktionieren, bieten jedoch selbst im Enterprise-Umfeld zu viele überflüssige Funktionen. Ein NAS für den heimischen Gebrauch auf Basis eines Raspberry Pi benötigt in der Regel noch weniger Funktionen. In unserem Projekt geht es nur um das Speichern von Daten an zentraler Stelle. Dafür braucht es lediglich eine handvoll Dienste: Ein sicheres lokales Dateisystem, ein Dienst für die Freigabe im Netz und vorzugsweise eine zuverlässige Backup-Lösung.

## Wahl des Dateisystems

Wer Daten speichert, der will sie hinterher korrekt lesen können. Das grenzt die Wahl des Dateisystems auf zwei Kandidaten ein. Denn nur die ZFS und btrfs garantieren Datenintegrität dank interner Checksummen. Unsere Wahl fällt auf ZFS, da es auf dem Rapberry Pi 4 mit 2, 4 oder vorzugsweise 8 GByte RAM läuft. Bei weniger als 8 GByte RAM läuft ZFS unter Umständen nicht optimal – so sollte man dann etwa keine Deduplizierung einsetzen.

## Hardware-Einkaufsliste

Unser NAS basiert auf einem Raspi 4 mit 8 GByte RAM. Ein USB-Typ-C-Netzteil, eine kleine MicroSD-Karte mit wenigstens 8 GByte sowie ein Cat5/Cat6-Netzwerkkabel vervollständigen das Basis-Gerät. Vorzugweise baut man den Raspberry Pi in ein gut belüftetes Gehäuse ein, etwa das Argon ONE.

n unserem Projekt dient das NAS als Speicher für diverse kleine Dokumentations- und Programmier-Projekte – eine überschaubare Datenmenge. Daher kommen hier lediglich zwei 240-GByte USB3-SSDs als ZFS-Spiegel zum Einsatz. Für erste Experimente mit ZFS mag man USB-Sticks verwenden, im Dauerbetrieb sind USB-Sticks zum Speichern wichtiger Daten jedoch wenig geeignet: Billige USB-Sticks nutzen gerne MLC Speicherzellen, die aber nur ein paar 10.000 Speicherzyklen vertragen, bevor sie ausfallen. Das ist also keine gute Idee bei einem Dateisystem, dass dauernd Daten schreibt. Auch ausrangierte 2.5"-Laufwerke aus alten Notebooks mit einem USB3-SATA-Konverter sind nicht die beste Wahl, da sie vor allem beim Einschalten deutlich mehr Strom benötigen als unsere externen SSDs.


## Spannungseinbrüchen per USV vorbeugen

Richtig konzipierte, professionelle NAS-Systeme stellen durch Batteriepufferung und definierte Schreibvorgänge sicher, dass die geschrieben Daten sicher auf den Datenträgern landen. Consumer-Hardware, und dazu gehören USB-Festplatten/SSDs, müssen um jeden Preis in Tests so schnell wie irgend möglich abschneiden. Daher tricksen sie gerne und melden "Daten sind geschrieben!" zurück, obwohl sie diese noch im Cache umsortieren und erst bei Gelegenheit wirklich wegschreiben. Gegen diesen gefährlichen Trick hilft eine Funktion namens "Write Barrier", bei der ein Datenträger so lange keine neuen Daten schreiben darf, bis die vorherigen tatsächlich auf dem physischen Datenträger gelandet sind. Natürlich gibt es Hersteller, die auch dies aus Performance- und Marketinggründen ignorieren. Zumindest ältere Versionen der Dateisysteme ext3/ext4, XFS und btrfs konnten dies erkennen und haben entsprechende Fehler in der /var/log/messages ausgegeben:

``` bash
ext3/ext4	JBD: barrier-based sync failed on <Gerät> - disabling barriers
XFS	Filesystem <Gerät> - Disabling barriers, trial barrier write failed
btrfs	btrfs: disabling barriers on dev <Gerät>
```

ZFS prüft die Write Barrier-Funktion offenbar nicht, die Entwickler gingen einfach nicht davon aus, dass jemand ZFS auf Bastel-Hardware einsetzt. Beim Raspberry Pi – weniger beim 4er, eher bei den Vorgängern – kann es durch Spannungseinbrüche (brown outs) oder wackelige USB-Verbindungen schon einmal dazu kommen, dass ein Datenträger plötzlich verschwindet oder sich selbst resettet. Ohne Write Barrier ist das bei ZFS ein echtes Problem. Daher sollten Sie bei jedem Raspberry-Pi-NAS mit ZFS unbedingt eine USV (Unterbrechungsfreie Stromversorgung) einsetzen und die USB-Verbindungen eventuell mit Heißkleber sichern – hässlich, aber die Daten danken es Ihnen.

## Einschaltstrom verteilen

Ein ähnliches Problem bildet das "Staggered Spin-up", oder vielmehr das Fehlen dieser Funktion beim Raspberry Pi. Über "Staggered Spin-up" starten große Drive-Enclosures (19"-Gehäuse mit etlichen Festplatten) Laufwerke nicht gleichzeitig, sondern im Abstand von wenigen Sekunden. Das verhindert einen zu großen Einschaltstrom, der zu Spannungseinbrüchen und damit undefiniertem Verhalten der Hardware führen kann. Alte Raspberry Pi mit der Stromversorgung über MicroUSB (laut Datenblättern diverser Hersteller bis maximal 1,8 A spezifiziert) haben Probleme mit mehreren USB-Laufwerken. Beim Raspberry Pi 4 wurde zumindest dieses Problem Dank der Stromversorgung via USB-Typ-C etwas entschärft.

Trotzdem: Beim Autor laufen Raspberry Pi 4-NAS oder -Cluster jeweils an umgebauten, kleinen APC Back-UPS CS 350 (gebraucht bei eBay ohne Akku für 20 Euro plus neuem 12V/7.2Ah-Akku für 15 Euro). Dort kann man mehrere Netzteile anschließen. Etwas mehr Erfahrung benötigt ein Umbau, bei dem der Spannungswandler von 12 auf 230V entfernt und durch einen DC/DC-Wandler auf 5,25V ersetzt wurde. Darüber lässt sich jeder Rapberry Pi direkt über seinen GPIO-Anschluss zeitversetzt mit Strom versorgen.

## Wahl des Betriebssystems

Als Betriebssystem für einen Raspberry Pi bietet sich naturgemäß an erster Stelle das Raspberry Pi OS (ehemals Raspbian) der Raspberry Pi Organisation in der 64-Bit-Ausgabe an. Es basiert auf Debian GNU/Linux 10 "Buster" und bringt bereits alle Pakete für ZFS im Repository mit. Beim von Sun Microsystems entwickelten ZFS handelt es sich um ein 128-Bit-Dateisystem. Aber: Das Zusammenspiel zwischen Betriebs- und Dateisystem funktionierte bei uns nicht.

Während ZFS bei FreeBSD fester Bestandteil des Betriebssystems und daher immer sauber integriert ist, müssen Sie ZFS unter GNU/Linux und damit auch unter Raspberry Pi OS nachinstallieren. Dazu gehört auch die "Solaris Porting Layer" (SPL), eine Software-Schnittstelle, die GNU/Linux benötigt, um ZFS-Code ausführen zu können. Da ZFS wie auch alle BSDs unter extrem einfachen und freien Lizenzen stehen, diese Freiheiten sich aber mit den Restriktionen der diversen GNU GPL-Versionen nicht vereinbaren lassen, darf ZFS rein rechtlich nicht mit einem GNU/Linux ausgeliefert werden. Normalwerweise würden Sie ZFS unter RaspberryPi OS so installieren:

``` bash
sudo apt-get install zfs-dkms spl
```

Die Installation übersetzt reichlich ZFS-Quellcode (dkms, Dynamic Kernel Module Support), was auf einem Raspberry Pi ein paar Minuten dauert. Während unserer ersten Gehversuche endete diese Aktion unter einem aktuellen 64-bittigen Raspberry Pi OS mit einer Fehlermeldung – ZFS ließ sich trotz mehrfacher Versuche einfach nicht installieren.

## Funktionierende Alternative: Ubuntu Server

Beim GNU/Linux-Distributor Canonical (oder der Virtualisierungesplattform Proxmox) sieht man hingegen kein Problem darin, ZFS mit dem Betriebssystem auszuliefern. Das gilt bei Canonical auch für den Ubuntu Server 20.04.1 für ARM mit Geschmacksrichtung "Raspberry". Letzteres ist wichtig, denn der normale Ubuntu Server für ARM (ein ISO-Image) läuft auf dem Raspberry Pi nicht. Für das NAS laden Sie die 64-Bit-Version von Ubuntu Server 20.04.1 LTS für den Raspberry Pi 4 herunter.

Es handelt sich dabei um ein xz-Archiv, das Sie in der Kommandozeile per

``` bash
cd ~/Downloads
xz --decompress ubuntu-20.04.1-preinstalled-server-arm64+raspi.img.xz
```

ausgepacken. Ein lsblk zeigt die eingesteckte MicroSD-Karte am PC an. Mit

``` bash
sudo dd if=ubuntu-20.04.1-preinstalled-server-arm64+raspi.img of=/dev/sdX bs=4M oflag=direct status=progress
```

schreibt dd das Image auf die MicroSD-Karte (/dev/sdX müssen Sie durch den korrekten Gerätenamen ersetzen). Wer sich nicht ins Terminalfenster traut, nutzt für das Schreiben des Images auf die MicroSD-Karte die Software Balena Etcher (Download). Nach erfolgreichem Flashen stecken Sie die MicroSD-Karte in den Raspi und starten diesen zunächst ohne die SSDs an dessen USB3-Ports. Ansonsten startet die Installation nicht.

Wer bislang Raspbian/Raspberry Pi OS eingesetzt hat, fragt sich, ob nicht die Datei /boot/ssh anzulegen ist, um einen SSH-Zugang zu erhalten. Die Antwort: Nein, der Ubuntu-Server ist von vornherein auf den Einsatz als "headless" Appliance im LAN mit standardmäßig aktiviertem SSH-Server ausgelegt.

Ebenfalls anders gestalten sich die Auswirkungen des massiv-parallelen Starts aller möglichen Dienste durch systemd: Sobald der Login-Prompt auf dem Bildschirm erscheint, dürfen Sie sich keinesfalls einloggen. Die SSH-Schlüssel wurden noch nicht generiert, sodass man durch ein zu frühes Login diesen Prozess stört. Erst rund zwei Minuten später erscheinen einige weitere Meldungen und damit ist der initiale Start von Ubuntu abgeschlossen. Mit anderen Init-Systemen wie SysV-Init, OpenRC, runit, S6, rc und so weiter gibt es dieses Problem nicht.

## Raspberry Pi im Netz finden

Dass das zukünftige Raspi-NAS standardmäßig auf SSH-Verbindungen wartet, ist praktisch. Für eine Kontaktaufnahme müssen Sie die IP-Adresse des Raspberry Pi kennen, die vom DHCP-Server im LAN vergeben wurde. Die Log-Meldungen des DHCP-Servers zeigen die IP-Adresse, es sollte die zuletzt vergebene sein. Alternativ finden Sie den Raspi mit dem Netzwerk-Scanner nmap. Damit suchen Sie im einfachsten Fall per Ping nach aktiven IP-Adressen:

``` bash
sudo nmap -sP 192.168.178.0/24
```

Wer seine Systeme im LAN kennt, erkennt mit dem nmap-Befehl direkt die IP des Raspberry Pi. Im Terminal können Sie dazu die nmap-Ausgabe mit Hilfe des etwas kryptischen awk nach MAC-Adressen der Raspberry Pi-Foundation (B8:27:EB:xx:xx:xx) oder beim Raspberry Pi 4 nach der Raspberry Pi Trading Ltd. (DC:A6:32:xx:xx:xx) durchsuchen:

``` bash
sudo nmap -sP 192.168.178.0/24 | awk '/^Nmap/{print}/DC:A6:32/{print}'
```

Der Befehl zeigt alle aktiven IP-Adresse an. Handelt es sich um einen Raspberry Pi 4, gibt das Tool unter der IP auch die MAC-Adresse aus.

## Basiskonfiguration

Haben Sie die IP-Adresse des zukünftigen Raspi-NAS ermittelt, loggen Sie sich dort per SHH ein. Während bei Raspbian/Raspberry Pi OS das Standard-Login "pi/raspberry" lautet, hört Ubuntu auf "ubuntu/ubuntu":

``` bash
ssh ubuntu@192.168.178.xxx
```

Ubuntu fragt beim ersten Login nach einem neuen Passwort. Normalerweise aktualisiert man nun das System, beim Ubuntu-Server muss man das automatische Update zumindest beim heimischen Einsatz zunächst abschalten – es ist auf den Einsatz auf Cloud-Systeme ausgerichtet:

``` bash
sudo /etc/init.d/unattended-upgrades stop
```

Das dauert ein paar Minuten, wobei es keinerlei Bildschirmausgaben gibt. Anschließend aktualisieren Sie System auf klassische Weise:

``` bash
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get autoremove
sudo apt-get clean
sync ; sudo shutdown -r now
```

autoremove entfernt nicht mehr benötigte Pakete. clean löscht die gerade heruntergeladenen Pakete nach erfolgter Installation und schafft so etwas mehr Platz. Der letzte Befehl startet den Raspberry Pi neu, da in der Regel neue Treiber und ein neuer Kernel installiert wurden. Erst nach erfolgreichem Neustart dürfen Sie endlich die SSDs an die USB3-Ports anschließen. Zuvor sollten Sie in einer weiteren SSH-Sitzung ein journalctl -f starten, um alle Meldungen des Systems mitverfolgen zu können.


## Werkzeuge für ZFS-Pools installieren

Die ZFS-Basis bringt Ubuntu bereits mit. Was fehlt, sind die Werkzeuge, um mit ZFS-Pools arbeiten zu können:

``` bash
sudo apt-get -y install zfsutils-linux
```

Ein zpool list sollte ohne Fehlermeldung anzeigen, dass (bislang) kein ZFS-Pool verfügbar ist ("no pools available").

Ein ZFS-Pool besteht immer aus einem oder mehreren VDEVs (Dateien, Laufwerke, Spiegel). Auf dem Raspberry Pi zeigt ein lsblk alle erkannten Laufwerke an.

In diesem Fall kennzeichnen sda und sdb zwei SSDs an den USB3-Schnittstellen, die den ZFS-Pool bilden sollen. Das mmcblk-Gerät stellt die MicroSD-Karte dar. Den ZFS-Pool richtet der folgende Befehl ein, wobei alle Daten auf den beiden SSDs ohne Nachfrage zerstört werden:

``` bash
sudo zpool create -f -o autoexpand=on -o ashift=12 zstorage mirror sda sdb
```

Mit create legt zpool einen ZFS-Pool an, -f (force) weist zpool an, eventuell bestehende Daten auf den SSDs zu ignorieren. Mit autoexpand=on lässt sich der ZFS-Pool später erweitern – bei ZFS ziehen Sie dazu einfach eine SSD ab, ersetzen diese durch eine größere und lassen ZFS die Laufwerke synchronisieren. Anschließend ersetzen Sie auch die andere (kleine) SSD durch eine größere und wiederholen die Synchronisation – fertig.

Das ashift=12 ist eigentlich unnötig, weist zpool aber explizit an, den Pool mit 4k-Sektoren (2^12) einzurichten, was den Pool auf modernen Laufwerken beschleunigt. Oft wird tank als Name für den ZFS-Pool verwendet – Sie können ihn frei wählen, im Beispiel hört er auf zstorage. Der ZFS-Pool wird anschließend im Root-Verzeichnis des Dateisystems unter eben diesem Namen eingehängt. mirror legt fest, dass die folgenden Geräte (VDEVs, hier sda und sdb) als ZFS-Spiegel einzurichten sind. Achtung! Lässt man mirror weg, legt ZFS ein Stripeset an, hängt beide Laufwerke also ohne Redundanz hintereinander.

Nach ein paar Sekunden ist der ZFS-Pool eingerichtet und betriebsbereit. Im Gegensatz zu einem RAID müssen Sie hier nichts partitionieren, formatieren und in die /etc/fstab einhängen. zpool status zeigt den aktuellen Status des Pools an. Allerdings nutzt man normalerweise diese oberste Ebene eines ZFS-Pools nicht, sondern legt darin "Datasets" an.

Ein Dataset ist vergleichbar mit einem Verzeichnis, verhält sich innerhalb des ZFS-Pools aber wie ein eigenes Dateisystem oder eine logische Einheit. Bei einem Dataset lassen sich unabhängig von anderen Datasets gewisse Parameter und Funktionen setzen – etwa Kompression, Deduplizierung et cetera. Wichtig: Ein Dataset kann – wenn nicht eingeschränkt – jeweils die gesamte Performance und den gesamten Platz des Pools nutzen. Hat ein ZFS-Pool 1 TByte Platz und vier Datasets, zeigt jedes Dataset jeweils 1 TByte freien Platz an. Der Platz im Pool wird so optimal genutzt. Einem Pool können Sie jederzeit ein weiteres VDEV (beispielsweise einen zusätzlichen Mirror) hinzufügen, dessen Platz ist im Pool sofort für alle Datasets verfügbar. Administratoren sollten diese Pool-Mechanik immer im Hinterkopf behalten.

## Datasets anlegen

Die Daten auf dem Raspberry Pi-NAS sollen innerhalb des eingerichteten ZFS-Pools in einem (oder mehreren) Dataset(s) liegen. Ein Dataset namens "datenlager" richtet der folgende Befehl ein:

``` bash
sudo zfs create zstorage/datenlager
zfs list
```

Der anschließende list-Befehl zeigt grundlegende Statistiken über alle Datasets. Weitere Datasets können Sie sowohl auf derselben als auch auf darunterliegenden Ebenen anlegen, etwa:

``` bash
sudo zfs create zstorage/datenlager/user
sudo zfs create zstorage/ISOs
```

Die Eigenschaften eines Datasets zeigt

``` bash
zfs get all zstorage/datenlager
```

an. Mit set lassen sich Eigenschaften ändern: Eine transparente Datenkompression ist beispielsweise immer empfehlenswert. Komprimierte Daten sind kleiner und werden schneller vom Laufwerk in den Speicher übertragen. Die CPU des Raspberry Pi 4 ist schnell genug, um diese Daten in Echtzeit auszupacken und ins Netzwerk zu schieben – im Endeffekt beschleunigt das sämtliche Lesevorgänge. Beim Schreiben prüft ZFS schnell, ob ein Datenblock um mindestens 12,5% eingedampft werden kann – und komprimiert diesen. Dafür stehen ein älterer lzjb (Lempel-Ziff, angepasst von Jeff Bonwick), gzip und lz4 zur Verfügung. Gerade letzterer kostet kaum Rechenzeit und sollte laut ZFS-Entwicklern auf jedes Dataset angewendet werden:

``` bash
sudo zfs set compression=lz4 zstorage/datenlager
```

Einmal aktiviert, komprimiert ZFS nun alle neuen Datenblöcke. Die bestehenden Daten bleiben unkomprimiert, solange Sie diese nicht umkopieren. Das nachträgliche Komprimieren von Hand wollen die ZFS-Entwickler irgendwann ermöglichen. Die Kompressionsrate eines Datasets zeigt

``` bash
zfs get compressratio zstorage/datenlager
```

Anfangs deutet "1.00x" als Wert auf keine Kompression hin, später wird dieser Wert größer und zeigt so den Kompressionsfaktor an.

## ZFS-Dataset im Netz freigeben

Ein NAS stellt Daten im Netz zur Verfügung, daher müssen Datasets auch als Freigaben im LAN erscheinen. Das geht auf einfache Weise durch das Unix-typische NFS (Network File System). Für eigentlich alle netzwerkfähigen Betriebssysteme gibt es dafür einen Client. Windows nutzt normalerweise CIFS/SMB, was für Linux und die BSDs über das Samba-Projekt realisiert wurde.

ZFS kann sich per "zfs set sharenfs=..." sogar um das Bereitstellen der Daten im Netz kümmern, wobei es genau genommen nur die vorhandenen Dienste – NFS und Samba – konfiguriert. Der Einfachheit halber wird hier NFS direkt verwendet. Geben Sie Datasets im Netz via Samba (CIFS/SMB) frei und nutzen dabei unterschiedliche Client-Betriebssysteme wie macOS, Windows, Linux und BSDs, erfordern die unterschiedliche Behandlung der Groß-/Kleinschreibung und die Rechte (ACLs) eine teilweise spezielle Konfiguration.

Zunächst installieren Sie dafür unter GNU/Linux den NFS-Kernel-Server:

``` bash
sudo apt-get -y install nfs-kernel-server
```

Die Datei /etc/exports muss nun für jede NFS-Freigabe einen Eintrag besitzen, der in etwa so aussieht:

``` bash
/zstorage/datenlager 192.168.0.0/24(rw,async,no_root_squash,no_subtree_check)
```

Die /etc/exports liest

``` bash
sudo exportfs -a
```

neu ein. Sowohl auf dem Raspberry Pi-NAS als auch auf anderen Rechnern im Netz zeigt

``` bash
showmount -e 192.168.0.4
```

nun alle Freigaben an. Ein clnt_create: RPC: Unable to receive deutet auf einen Fehler in der Konfiguration oder eine falsche IP-Adresse hin.

## ZFS-Dataset einhängen

Das ZFS-Dataset hängen Sie wie jede NFS-Freigabe im LAN über den mount-Befehl ins lokale Dateisystem ein. Dazu, wie auch auf dem Server, benötigt GNU/Linux ein paar NFS-Dateien wie lockd, statd, showmount, nfsstat, gssd, idmapd und mount.nfs. Die Installation von "nfs-kernel-server" auf dem NAS installiert das das Paket automatisch mit, auf einer Workstation erledigen Sie das von Hand:

``` bash
sudo apt-get install nfs-common
```

Anschließend benötigt NFS ein (leeres) Verzeichnis, in das Sie die NFS-Freigabe einhängen. Arbeitet nur ein Nutzer auf dem System, können Sie das Verzeichnis ins /home-Verzeichnis legen – wobei dort ein falsch eingetippter Löschbefehl auch schnell alle Daten auf dem NAS löschen könnte. Legen Sie "Mounts" daher besser in /mnt ab. Sollte das bei klassisch konfigurierten Unixen ein Problem sein, wenn diese das /mnt-Verzeichnis direkt für bestimmte Aufgaben verwenden, bildet das /srv-Verzeichnis eine Alternative. In diesem sammeln viele Administratoren beispielsweise alle für das Netzwerk relevanten Verzeichnisse. Das entsprechende Verzeichnis müssen Sie nur einmal anlegen, bei späteren Neustarts des Systems müssen Sie es – Stand jetzt – per mount-Befehl erneut einhängen:

``` bash
sudo mkdir -p /srv/nasberry.datenlager
sudo mount -t nfs 192.168.0.4:zstorage/datenlager /srv/nasberry.datenlager/
```

Das Verzeichnis muss natürlich nicht "nasberry.datenlager" heißen. Einfachere Namen wären "nas", "daten" oder "share". Den mount-Befehl bei jedem Start der Clients eingeben zu müssen, wird schnell lästig. Stellen Sie eine dauerhafte Verbindung her, indem Sie folgende Zeile in /etc/fstab ergänzen:

``` bash
192.168.0.4:/zstorage/datenlager /srv/nasberry.datenlager nfs rw,async 0 0
```

Neben dem Pfad zur Freigabe auf dem Server und dem lokalen Pfad zum Einhängen gibt nfs den Typ des Dateisystems an. rw,async spezifiziert die mount-Parameter und könnte unter Linux auch durch defaults ersetzt werden. Die erste Null gibt an, ob das Verzeichnis vom Backup-Programm dump gesichert werden soll – das soll hier nicht der Fall sein. Ebenso soll beim Systemstart keine Dateisystemprüfung erfolgen. Um den Eintrag auf seine Funktion zu überprüfen, liest ein

``` bash
sudo mount -a
```

die /etc/fstab neu ein und spuckt gegebenenfalls einen Fehler aus. Wenn Sie mit den BSDs, also auch FreeBSD und damit auch mit macOS auf das Raspi-NAS zugreifen möchten, müssen Sie eventuell die Read-/Write-Blockgröße von NFS verkleinern. Verbindet man sich mit einem GNU/Linux zum NAS, zeigt

``` bash
cat /proc/mounts
```

die Größe an (bei Devuan GNU/Linux 3.0 sind es rsize=131072,wsize=131072). Für BSDs und macOS kann man Werte ab 8192 ausprobieren und solange verdoppeln, bis die Performance einbricht:

``` bash
sudo mount -t nfs -o rsize=8192,wsize=8192 ...
```

Um als Benutzer auf dem Raspi-NAS schreiben zu können, müssen entsprechende Rechte für die freigegebenen Datasets vorhanden sein. Nach dem Anlegen gehören die Datasets root. Ein Benutzer kann hier nicht schreiben oder lesen. Erst das Ändern der Dateirechte samt aller Unterverzeichnisse (-R) erlaubt vollen Zugriff:

``` bash
sudo chown -R ubuntu:ubuntu /zstorage/datenlager
```

Genaugenommen hat der Benutzer "ubuntu" auf dem Ubuntu Server die UID 1000, die ein normaler Benutzer auf einer GNU/Linux-Workstation auch hat. Darum kann man auch mit anderen Benutzernamen schreibend auf das "Datenlager" zugreifen – solange die UID dieselbe ist.

Wenn Sie mit Windows auf das NAS zugreifen wollen, sollten Sie "Samba" auf dem Raspberry Pi-NAS installieren – und als Tipp einen Blick in die Samba-Konfigurationsdatei (smb.conf) von OMV werfen. Dort finden Sie viele wirklich gute Konfigurationstipps.

## Trojanern per Snapshot begegnen

Noch ein wichtiger Tipp in Sachen Sicherheit zum Schluss: Über das Paket zfs-auto-snapshot legt ZFS automatisch Snapshots an, womit Sie jederzeit zu einem vorherigen Datenstand zurückkehren können. Selbst nach dem Einschlag eines verschlüsselnden Erpressungstrojaners weist man ZFS einfach an, auf den letzten Snapshot vor dem Trojaner zurückzukehren und das Problem ist in Sekunden gelöst. ZFS kann über send/receive seine Daten wesentlich effizienter als beispielsweise rsync über das Netzwerk sichern. (mre)
