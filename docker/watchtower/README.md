# Watchtower

Watchtower ist eine Anwendung mit der du automatisiert deine Container anhand des Version-Tags aktualisieren kannst.
Mit dem Tag :latest wird der Container also immer auf die neuste Verison gezogen. 
ACHTUNG! Dies kann natürlich zu Problemem führen.

https://github.com/containrrr/watchtower  

# Container aktualisieren
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once portainer