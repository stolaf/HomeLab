break

start-process "https://docs.microsoft.com/de-de/powershell/scripting/core-powershell/ssh-remoting-in-powershell-core?view=powershell-6"
start-process "https://github.com/PowerShell/Win32-OpenSSH/wiki/ssh.exe-examples"


ssh fs01\dkx8zb8adm@fsdebsy04434.mgmt.fsadm.vwfs-ad   #works
ssh fsdebsy04434.mgmt.fsadm.vwfs-ad       #works
ssh fsdebsy04434    #works

mklink /D c:\pwsh "C:\Program Files\PowerShell\6"
"C:\ProgramData\ssh\sshd_config"  -->
     PasswordAuthentication yes
     Subsystem    powershell c:\pwsh\pwsh.exe -sshs -NoLogo -NoProfile

Invoke-Command -HostName fsdebsy04434.mgmt.fsadm.vwfs-ad -UserName fs01\dkx8zb8adm -ScriptBlock {get-process} 
Invoke-Command -HostName fsdebsy04434 -UserName fs01\dkx8zb8adm -ScriptBlock {get-process}   
Invoke-Command -HostName fsdebsy04434 -UserName zz_acuser -ScriptBlock {get-process}   
Invoke-Command -HostName fsdebsy44191 -UserName zz_acuser -ScriptBlock {get-process}   
Enter-PSSession -HostName fsdebsy04434.mgmt.fsadm.vwfs-ad 