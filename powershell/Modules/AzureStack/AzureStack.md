# AzureStack

## Module Installation
```powershell
Get-Module -Name 'Azure*' -ListAvailable | Uninstall-Module -Force -Verbose -ErrorAction Continue

Install-Module -Name 'Az.BootStrapper' -Force -AllowPrerelease
Install-AzProfile -Profile '2019-03-01-hybrid' -Force
Install-Module -Name AzureStack -RequiredVersion 2.0.2-preview -AllowPrerelease
Install-Module -Name 'AzS.Syndication.Admin' -AllowPrerelease -force
```

## MarketPlace
Script von Dennis im Git: Az-MPSyndication_Upload_to_AzS.ps1

```powershell
Import-AzsMarketplaceItem -RepositoryDir "D:\MP_Images\_Upload" -Verbose

```

