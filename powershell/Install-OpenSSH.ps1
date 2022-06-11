Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service -Name sshd
Install-Module -Name Microsoft.PowerShell.RemotingTools	
Import-Module -Name Microsoft.PowerShell.RemotingTools
Enable-SSHRemoting -Verbose
Restart-Service -Name sshd

# Powershell Remoting
start https://4sysops.com/archives/install-powershell-remoting-over-ssh/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+4sysops+%284sysops%29

if ($IsLinux) {
    Install-Module -Name 'Microsoft.PowerShell.RemotingTools'
    Enable-SSHRemoting -Verbose 
    sudo service ssh restart
}
Invoke-Command -HostName 192.168.178.20 -UserName olaf -ScriptBlock { Get-Process -Name pwsh }