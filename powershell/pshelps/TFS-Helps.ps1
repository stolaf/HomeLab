break

# Agenten auf DeployStager installieren:

# Agenten downloaden: http://tfs.t-fs01.vwfs-ad:8080/tfs/VWFSAG/IH-IOPI/_settings/agentqueues?queueId=2459&_a=agents
# auf Zielsystem nach "$HOME\Downloads" kopieren

# in Admin Powershell Console ausführen:

mkdir 'D:\VSTS_PSDeploy'
cd 'D:\VSTS_PSDeploy'
Add-Type -AssemblyName System.IO.Compression.FileSystem 
[System.IO.Compression.ZipFile]::ExtractToDirectory("$HOME\Downloads\vsts-agent-win-x64-2.144.2.zip", "$PWD")

.\config.cmd

http://tfs.t-fs01.vwfs-ad:8080/tfs/vwfsag 
Agent-Pool: Release-I-ENV-PSDeploy
Agent-Name: FSDEBSY44501_PSDeploy
Arbeitsordner: Enter
Als Dienst ausführen: J
Benutzerkonto: fs01\dkx1s62468