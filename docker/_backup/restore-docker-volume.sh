# zuerst das richtige Datum der Restore Dateien wählen, 
# sollte im besten Fall das letzt Verfügbare Datum sein
# also den Timestamp (YYYYMMDD) setzen
TIMESTAMP=202206201707
# dann ins Verzeichniss wechseln
cd /media/backup/docker-01/volumes
# dann den restore anstoßen
for i in $(ls *$TIMESTAMP*); do 
    docker run --rm -v /media/backup/docker-01/volumes:/backup -v ${i%%-[0-9]*}:/data debian:stretch-slim bash -c "cd /data && /bin/tar -xzvf /backup/$i"
done

