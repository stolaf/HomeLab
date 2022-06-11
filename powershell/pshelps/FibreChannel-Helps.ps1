break

#WWNsgcm  auslesen
Get-InitiatorPort
Get-InitiatorPort | Select-Object -Property PortAddress | Format-Table -AutoSize

QLogic Fibrechannel Adapter Informationen
- Netapp Windows Host Utilities installieren
cd "C:\Program Files\NetApp\Windows Host Utilities\NetAppQCLI"
.\qaucli.exe -pr fc


& "C:\Program Files\NetApp\Windows Host Utilities\NetAppQCLI\qaucli.exe" -pr fc

#Volumes löschen: kann anhand der Serialnumber erfolgen
"c:\Program Files\ibm\sdddsm\datapath.exe" query device
