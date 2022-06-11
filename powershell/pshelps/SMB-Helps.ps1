break

#SMB Multichannel abschalten
New-SmbMultichannelConstraint -ServerName "fsdebsgv3410" -InterfaceAlias "tNIC MGMT - VLAN 3093 SMB"
New-SmbMultichannelConstraint -ServerName "fsdebsgv3410.mgmt.fsadm.vwfs-ad" -InterfaceAlias "tNIC MGMT - VLAN 3093 SMB"

#https://4sysops.com/archives/managing-windows-file-shares-with-powershell/
New-SmbShare -Name Logs -Description "Log Files" -Path C:\Shares\Logs
Set-SmbShare -Name Logs -Description "Application Log Files" -Force
Grant-SmbShareAccess -Name Logs -AccountName corp\LogViewers -AccessRight Read
Grant-SmbShareAccess -Name Logs -AccountName corp\LogAdmins -AccessRight Change -Force
Revoke-SmbShareAccess -Name Logs -AccountName Everyone -Force
Block-SmbShareAccess -Name Logs -AccountName corp\AppUsers -Force   #deny Access
UnBlock-SmbShareAccess -Name Logs -AccountName corp\AppUsers -Force
Remove-SmbShare -Name Logs -Force

Set-SmbBandwidthLimit -Category Default -BytesPerSecond 100MB
Set-SmbBandwidthLimit -Category LiveMigration -BytesPerSecond 1GB