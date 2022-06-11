break

#4 Ways to Transfer Files to a Linux Hyper-V Guest
# http://www.altaro.com/hyper-v/transfer-files-linux-hyper-v-guest/?utm_term=5%20Ways%20to%20Transfer%20Files%20to%20a%20Linux%20Hyper-V%20Guest&utm_campaign=Patching%20Hyper-V%20VMs%20using%20PS%20Direct%20and%20more&utm_content=email&utm_source=Act-On+Software&utm_medium=email&cm_mmc=Act-On%20Software-_-email-_-Patching%20Hyper-V%20VMs%20using%20PS%20Direct%20and%20more-_-5%20Ways%20to%20Transfer%20Files%20to%20a%20Linux%20Hyper-V%20Guest


#http://winscp.net/eng/docs/scripting
Write-Host "Kopiere alle Inventory Files nach /admhplvap09/home/hwinventory/$env:USERDNSDOMAIN"
@"
option batch continue
option confirm off
open sftp://hwinventory:<password>@172.20.6.23:22
put c:\temp\* /home/hwinventory/$env:USERDNSDOMAIN/
close
exit
"@ | Out-File "$env:TEMP\WinSCP_Script.txt" -Encoding 'UTF8' -Force
Start-Process -FilePath $TC_WinSCPProg -ArgumentList "/script=$env:TEMP\WinSCP_Script.txt" -Wait
Remove-Item -Path "$env:TEMP\WinSCP_Script.txt" -Force -ErrorAction SilentlyContinue


#http://winscp.net/eng/docs/scripting
Write-Host "Kopiere alle Inventory Files nach /admhplvap09/home/hwinventory/$env:USERDNSDOMAIN"
@"
  option batch continue
  option confirm off
  open sftp://hwinventory:<password>@172.20.6.23:22
  put \\esahpwvap96\Scripts\Powershell\Reports\Inventur\$env:USERDNSDOMAIN\* /home/hwinventory/$env:USERDNSDOMAIN/
  close
  exit
"@ | Out-File "$env:TEMP\WinSCP_Script.txt" -Encoding 'UTF8' -Force
Start-Process -FilePath $TC_WinSCPProg -ArgumentList "/script=$env:TEMP\WinSCP_Script.txt" -Wait
Remove-Item -Path "$env:TEMP\WinSCP_Script.txt" -Force -ErrorAction SilentlyContinue


<# GParted NTFS
cd /sbin
sudo mv ntfsresize ntfsresize.orig
sudo vi ntfsresize
i
#!/bin/bash
exec ntfsresize.orig --bad-sectors "$@"
Esc
:wq
 
sudo chmod 755 ntfsresize
exit
#>


