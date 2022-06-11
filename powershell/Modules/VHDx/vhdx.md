# VHDx

https://github.com/FriedrichWeinmann/VHDX/tree/master/VHDX

Install-Module VHDX

## New Disk
New-Vhdx -Path C:\temp\empty.vhdx
Get-ChildItem C:\Temp\ | New-Vhdx -Path 'C:\temp\sccm-content.vhdx'

## Adding content to existing disk
