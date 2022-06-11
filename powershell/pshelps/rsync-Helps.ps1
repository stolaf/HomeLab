break

<#
siehe c't 3/2018 S.164ff
benutzt SSH und Verschlüsselung, auf entfernten rechnern wird der Delta Transfer Algorithmus verwendet
Grsync ist die graphische Variante

Der öffentliche Schlüssel (-/ .ssh/id_rsa.pub) gehört aufs Zielsystem und zwar in die Datei - /.ssh/ authorized keys.
Da hier mehrere solcher Schlüssel stehen dürfen, sollten Sie darauf achten, keine Einträge zu überschreiben. Am einfachsten gelingt das Hinzufügen mit dem Werkzeug ssh-copy-id, das den öffentlichen
Schlüssel transportiert und richtig einträgt:  ssh-copy-id -i - /.ssh/id_rsa.pub huhn@huhnix.org:
Da ein passwortloses SSH-Schlüsselpaar immer ein Risiko darstellt, ist es möglich, für bestimmte Keys einzelne Befehle zu erlauben. Dazu bearbeiten Sie die Datei - /.ssh/authorized_keys auf dem entfernten
Rechner, gehen zur Zeile mit dem gewünschten SSH-Schlüssel und tragen an den Anfang der Zeile (also vor ssh-rsa) das Kommando ein, zum Beispiel
command="rsync -avzP --delete .... Achten Sie darauf, dass sich zwischen Befehl und Schlüssel kein Zeilenumbruch befindet.
#>
rsync ~/Dokumente/* /media/backup/Dokeumnente   #sync auf selbem Rechner
rsync ~/Dokumente/* hej@hihnix.org:/media/backup/Dokumente    #wenn auf beiden Servern der UserName hej gleich ist kann dieser auch weggelassen werden

rsync -r   # rekursive
rsync -l   # auch logische Verknüpfungen
rsync -p   # auch Zugriffsrechte
rsync -t   # auch Zeitstempel
rsync -g   # auch Gruppenrechte
rsync -v   # Verbose
rsync -z   # Kompression
rsync -o   # auch Eigentümer (nur root)
rsync -a   # Archiv
rsync -av  ~/Dokumente hej@huhnix.org:/media/backup/   # rekursive, Links, Zugriffsrechte, Zeitstempel und andere Eigenschaften
# auf abschließenden / achten  wenn vorhanden dann wird nur der Inhalt des Ordners übertragen

rsync -av --progress hej@huhnix.org/pi.iso /Downloads/
--partial # Teilstücke bleiben erhalten
rsync -P  #kombiniert --progress --partial
rsync -av --progress --partial hej@huhnix.org/pi.iso /Downloads/

rsync -avP --bwlimit=30 hej@huhnix.org/pi.iso /Downloads/   # 30Kilobit / Sec

--stats   # statistische Werte im terminal anzeigen

rsync -avn --delete ~/Dokumente hej@huhnix.org  # -n startet einen Testlauf
rsync -avb --suffix=.bak --delete ~/Dokumente hej@huhnix.org:/media/backup  # -b Löschkandidaten eine .bak anhängen