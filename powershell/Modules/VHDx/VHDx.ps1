#break

Install-Module VHDX

## New Disk
New-Vhdx -Path C:\temp\empty.vhdx
Get-ChildItem C:\Temp\ | New-Vhdx -Path 'C:\temp\sccm-content.vhdx'
Get-ChildItem C:\Temp\ | New-Vhdx -Path 'C:\sccm-content.vhdx' -Type Fixed -Size 5GB 

## Adding content to existing disk
# Add to root path of volume
Get-ChildItem C:\Temp | Add-VhdxContent -Path 'C:\temp\empty.vhdx'

# Add to a child folder
New-Vhdx -Path C:\temp\data.vhdx
Get-ChildItem C:\Scripts | Add-VhdxContent -Path 'c:\temp\data.vhdx' -SubPath "Scripts"
Remove-VhdxContent -Path 'c:\temp\data.vhdx' -SubPath Scripts -Content '*.*'
Remove-VhdxContent -Path 'c:\temp\data.vhdx' -SubPath Scripts -Content '*.txt'
Remove-VhdxContent -Path 'c:\disks\data.vhdx' -SubPath config\secrets -Content '*.txt'

#Mount
Mount-Vhdx -Path 'c:\temp\data.vhdx' -EnableException 
Dismount-Vhdx -Path 'c:\temp\data.vhdx'