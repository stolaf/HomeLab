# ConfigManager
https://technet.microsoft.com/en-us/library/jj850181%28v=sc.20%29.aspx?f=255&MSPPError=-2147217396

```powershell
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -Force
Get-Command Get-* –module ConfigurationManager
cd P01:
Get-CMSite 
Get-CMManagementPoint
Get-CMDistributionPoint


$CMClientSettings = Get-CMClientSetting | Select-Object Name
foreach ($CMClientSetting in $CMClientSettings) {
    $xSettings = [Enum]::GetNames( [Microsoft.ConfigurationManagement.Cmdlets.ClientSettings.Commands.SettingType])
    foreach ($xsetting in $xsettings ) {
	        Get-CMClientSetting -Setting $xsetting -Name $CMClientSetting.Name | format-table
    }
}

Get-CMClientSetting -Setting MeteredNetwork -Name 'FSAG-SRV-Managed Devices'
Get-CMClientSetting -Setting MeteredNetwork -Name 'FSAG-SRV-Hardware Inventory'
Get-CMClientSetting -Name 'FSAG-SRV-Managed Devices'
```

