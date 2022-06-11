break

<#   SMI-S Loses Storage Credentials 

Der Fehler tritt ja auch nur sehr sporadisch auf und nur wenn die SMI-S VM neugestartet wurde.

In diesem Fall muss der identische lokale SMI-S User (cimuser) neu erstellt werden.
Also 
cimuser -d -u dkx123
cimuser -a - u dkx123
sims cimserver restart

Ggf. muss dann auch noch der SMI-S Provider im VMM gelöscht werden und neu hinzugefügt werden.

#>