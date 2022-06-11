# Python

c't 5.2022: So.richten.Sie.Python.schnell.und.einfach.ein : [[So.richten.Sie.Python.schnell.und.einfach.ein.pdf]]
c't 5.2022:: Python Entwicklungsumgebungen: [[Python.Entwicklungsumgebungen.pdf]]

## Pip plötzlich verschwunden  
c't 09/2022 S. 179
Auch wir haben schon erlebt, dass  nach einem Update in Arch Linux in  virtuellen Umgebungen kein pip mehr zu  finden war. Die Fehlermeldung lautet  dann ModuleNotFoundError: No module named  
pip. Das lässt sich auch mit python -m pip  nicht umgehen.

Es gibt aber einen einfachen Weg, pip  wieder zu installieren: Aktivieren Sie zunächst das Virtualenv. Der Befehl 
python  -m ensurepip --default-pip 
nstalliert danach pip, ohne selbst pip dafür zu brauchen. Danach kann pip sich selbst aktualisieren: pip install -U pip. (pmk@ct.de)