# DHCP
Migrate Existing DHCP Server to Windows Server 2012 
http://spiffy.sg/general/migrate-existing-dhcp-server-to-windows-server-2012-easily-with-powershell/

```powershell
Export-DhcpServer -ComputerName alter_DHCP_Server -Leases -File C:\system\dhcpexp.xml –verbose
Import-DhcpServer –ComputerName Neuer_DHCP_Server -Leases –File C:\system\dhcpexp.xml -BackupPath C:\dhcp\ –Verbose
```

