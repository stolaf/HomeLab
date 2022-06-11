break

#Install OpenSSH Server on Windows Server  https://www.thomasmaurer.ch/2018/06/install-openssh-server-on-windows-server/
copy \\fsdebsgv4911\iopi_sources$\Install\Microsoft\OpenSSH  to C:\C:\Program Files\OpenSSH
cd C:\Program Files\OpenSSH
.\install-sshd.ps1
Start-Service -Name sshd
Set-Service sshd -StartupType Automatic
Start-Service -Name ssh-agent
Set-Service ssh-agent -StartupType Automatic

Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 # Install the OpenSSH Server
# Install the OpenSSHUtils helper module, which is needed to fix the ACL for ths host keys.
Install-Module -Force OpenSSHUtils

Start-Service ssh-agent
cd C:\Windows\System32\OpenSSH
.\ssh-keygen -A   # Generate Key
.\ssh-add ssh_host_ed25519_key  # Add Key

# Repair SSH Host Key Permissions
Repair-SshdHostKeyPermission -FilePath C:\Windows\System32\OpenSSH\ssh_host_ed25519_key

# Open firewall port, Consider to configure the Profile for the Firewall rule
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

#################################################
#enable-powershell-core-6-remoting-with-ssh-transport
#https://4sysops.com/archives/powershell-remoting-with-ssh-public-key-authentication/

Start-Process https://4sysops.com/archives/enable-powershell-core-6-remoting-with-ssh-transport/
powershell.exe -ExecutionPolicy Bypass -File "C:\Program Files\OpenSSH\install-sshd.ps1"
$env:Path="$env:Path;C:\Program Files\OpenSSH\"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $env:Path
Start-Service sshd
Set-Service sshd -StartupType Automatic

ssh-add <path to private key> #To add your private key to the ssh-agent, you have to enter this command
ssh-add -d ida-rsa #If you later want to remove the private key from the ssh-agent, you can do it with this command
ssh-add -D   #you can remove all private keys from the ssh-agen

Start-Process notepad C:\ProgramData\SSH\sshd_config
   Comment out:  Subsystem	sftp	sftp-server.exe
   Add:  Subsystem powershell C:/Program Files/PowerShell/6.1.0-preview.1/pwsh.exe" -sshs -NoLogo -NoProfile

New-NetFirewallRule -DisplayName 'SSH Inbound' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22
Restart-Service sshd

# In PowerShell 6 Admin Console
Enter-PSession -HostName <remote host> -UserName <user name on the remote computer>
Invoke-Command -HostName <remote hosts> -UserName <user name on the remote computer> -ScriptBlock {get-process}
Enter-PSsession -HostName <computer name>    #HostName parameter ensures that PowerShell will use SSH as the transport protocol
Enter-PSsession -HostName fsdebsy44417.mgmt.fsadm.vwfs-ad   #-UserName dkx8zb8adm:fs01
Enter-PSession -HostName <remote host> -UserName <user name on the remote host> -IdentityFilePath <path to private key>id_rsa

Invoke-Command -HostName localhost -UserName dkx8zb8adm:fs01 -ScriptBlock {get-process}
Enter-PSsession <computer name> -UserName <user name>:<domain name> ‑SSHTransport

$session = New-PSSession -HostName <computer name> -UserName <user name> -Session $session
Invoke-Command -Session $session -ScriptBlock {get-process}

ssh zz_acuser@fsdebsy44417.mgmt.fsadm.vwfs-ad
ssh <user name on the remote computer>@<remote host>
ssh -i <path to private key>id_rsa <user name on the remote host>@<remote host>


##############################################
Import-Module posh-ssh
Get-Command -Module posh-ssh

#Get-SSHTrustedHost | Remove-SSHTrustedHost

$user = 'root'
$credential = Get-Credential $user
$ComputerName = 'FSDEBSUL0716'

# Test SSH port
Test-NetConnection -ComputerName $ComputerName -Port 22 -InformationLevel Quiet 

$sshSession = New-SSHSession -ComputerName $ComputerName -Credential $credential 
Get-SSHSession -SessionId $sshSession.SessionId   #pipelining not supported
Invoke-SSHCommand -SessionId $sshSession.SessionId -Command 'uname -a'

$linuxCommand = 'uname -a; lsb_release -a;  cat /proc/cpuinfo | grep "model name" | uniq'
(Invoke-SSHCommand -SessionId $sshSession.SessionId  -Command $linuxCommand).output

# Download single file
$configFullName = '/etc/sysconfig/system-config-firewall' 
$configFileName = $configFullName.split('/')[$configFullName.split('/').count-1]
Get-SCPFile -ComputerName $ComputerName -Credential $credential -LocalFile "c:\Temp\$configFileName" -RemoteFile $configFullName 
Get-Content $configFileName

# Download directory (recursive)
Get-SCPFolder -ComputerName $ComputerName -Credential $credential -RemoteFolder '/etc/sysconfig/networking' -LocalFolder 'c:\Temp'

Get-SFTPContent -SessionId 0 -Path '/etc/sysconfig/system-config-firewall' 

#Upload File
Set-SCPFile -ComputerName $ComputerName -Credential $credential -LocalFile 'C:\Temp\CentOS-6.5-x86_64-bin-DVD2.iso' -RemotePath '/etc/sysconfig'

#Upload Folder
Set-SCPFolder $ComputerName -Credential $credential -LocalFolder 'C:\Temp' -RemoteFolder '/etc/sysconfig'

Get-SSHSession | Remove-SSHSession
