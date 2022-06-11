# DeviceManagement

https://gallery.technet.microsoft.com/Device-Management-7fad2388

```powershell
Import-Module DeviceManagement
Get-Command -Module devicemanagement
Get-Driver | Where-Object -Property Description -Like 'Microsoft*' | Format-Table * -AutoSize

Invoke-Command -ComputerName 'FSDEBSNE0402.mgmt.fsadm.vwfs-ad' -ScriptBlock {
    Import-Module DeviceManagement -force
    Get-Device | Where-Object DriverProvider -eq 'Emulex' | sort-object Name | Format-Table Name,DriverVersion
}


```

