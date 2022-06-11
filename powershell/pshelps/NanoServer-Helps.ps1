<#
 start http://blogs.technet.com/b/canitpro/archive/2015/10/06/step-by-step-installing-a-nano-server-in-my-test-domain.aspx
 start http://www.heise.de/ct/ausgabe/2016-5-Microsofts-Interpretation-von-Containern-3100561.html?wt_mc=print.ct.2016.05.122#zsdb-article-links
 start https://blogs.technet.microsoft.com/heyscriptingguy/2015/12/11/using-deployimage-and-windows-powershell-to-build-a-nano-server-part-5/

 Hyper-V on Nanoserver
 start https://blogs.msdn.microsoft.com/powershell/2017/02/17/managing-security-settings-on-nano-server-with-dsc/
 start http://blogs.msdn.com/b/virtual_pc_guy/archive/2015/09/08/running-hyper-v-on-nano-in-windows-server-2016-tp3.aspx
 start http://blogs.msdn.com/b/virtual_pc_guy/archive/2015/09/14/running-nano-from-windows-server-2016-tp3-on-hyper-v.aspx
 start https://technet.microsoft.com/en-us/library/mt126167.aspx   #Quick start
 start https://msdn.microsoft.com/en-us/library/mt126167.aspx
#>

#https://technet.microsoft.com/de-de/library/mt126167.aspx

Import-Module 'C:\Install\NanoServer\NanoServerImageGenerator'

$AdminPassword = Read-Host -AsSecureString -Prompt 'Input Admin Password'

New-NanoServerImage -MediaPath e: -BasePath .\Base -TargetPath 'C:\Install\VHD\FSDEBSNE0162.vhdx' -DeploymentType Host `
    -Edition Datacenter -Compute -Clustering -MaxSize 10GB -ComputerName 'FSDEBSNE0162' `
    -InterfaceNameOrIndex 4 -Ipv4Address '10.40.244.174' -Ipv4SubnetMask '255.255.255.192' -Ipv4Gateway '10.40.244.129' -Ipv4Dns '10.43.225.244','10.43.225.246' `
    -EnableRemoteManagementPort -AdministratorPassword $AdminPassword

bcdboot.exe g:\Windows

New-NanoServerImage -MediaPath e: -BasePath .\Base -TargetPath 'C:\Install\VHD\CS-Host2.vhdx' -DeploymentType Host `
    -Edition Datacenter -Compute -Clustering -MaxSize 4GB -ComputerName 'CS-HOST2' `
    -InterfaceNameOrIndex 4 -Ipv4Address '192.168.178.4' -Ipv4SubnetMask '255.255.255.0' -Ipv4Gateway '192.168.178.1' -Ipv4Dns '192.168.178.1' `
    -DriversPath 'C:\Install\Drivers' -OEMDrivers -Development -EnableRemoteManagementPort -AdministratorPassword $AdminPassword

Import-Module 'C:\Install\NanoServer\NanoServerImageGenerator.psm1'
Set-Location -Path 'C:\Install\NanoServer'
#https://channel9.msdn.com/Blogs/bfrank/DeployNanoServerAsVM?wt.mc_id=DX_59381
#als VM erstellen
New-NanoServerImage -MediaPath d: -BasePath .\base -TargetPath .\nano\meinnanoserver.vhdx -Language en-us -MaxSize 10GB -GuestDrivers -ComputerName MeinName
Enter-PSSession -VMName meinnano
netsh.exe interface ip set address 'ethernet 6' static 10.40.244.174 255.255.255.192 10.40.244.129
netsh.exe interface ip set address 'ethernet' static 10.40.175.75 255.255.255.192 10.40.175.65
netsh.exe interface ip set address 'ethernet 2' static 10.40.175.76 255.255.255.192 10.40.175.65
start-vhddeploy.ps1

netsh.exe interface ip add dns 'ethernet 6' 10.43.225.244 

tzutil.exe /s 'W. Europe Standard Time'
Set-Date -Adjust 9:00
Get-Date
exit
$sessionToDC = New-PSSession -ComputerName fab-dc01.cos.local -Credential (Get-Credential)
Enter-PSSession -Session $sessionToDC
djoin.exe /PROVISION /DOMAIN cos.local /MACHINE MainNano /savefile c:\Temp\meinnano.blob
Exit
Copy-Item -FromSession $sessionToDC c:\Temp\meinnano.blob -Destination C:\Temp -Force
$sessionToNano = New-PSSession -ComputerName 192.168.10.20 -Credential (Get-Credential)
Copy-Item -ToSession $sessionToNano -Path c:\Temp\meinnano.blob -Destination C:\ -Force
Enter-PSSession -Session $sessionToNano
djoin.exe /REQUESTODJ /LOADFILE c:\meinnano.blob /WINDOWSPATH C:\Windows /localos
shutdown.exe /r /t 10
.\New-NanoServerVHD.ps1 `
            -ServerISO 'C:\Install\en_windows_server_2016_technical_preview_4_x64_dvd_7258292.iso' `
            -DestVHD 'D:\Virtual Machines\NanoServerTest02\NanoTest02.vhdx' `
            -VHDFormat VHDX `
            -ComputerName NANOTEST02 `
            -AdministratorPassword $AdminPassword `
            -Packages 'Guest','IIS' `
            -IPAddress '10.40.244.145'


$VMName = 'NanoServerTest02'
$IP01 = '10.40.244.146'
$IP02 = '10.40.244.145'
$Credential = Get-Credential 'Administrator'
$NanoSession01 = New-PSSession -ComputerName $IP01 -Credential $Credential
$NanoSession02 = New-PSSession -ComputerName $IP02 -Credential $Credential
Enter-PSSession -Session $NanoSession02

Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock {New-Item -Path C:\Temp -ItemType Directory}
Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock {Remove-Item -Path C:\Temp }

Get-CimInstance win32_operatingsystem
Get-WindowsFeatures   #funktioniert nicht

Dism.exe /online /Get-Packages

Start-Process "http://$IP02"
