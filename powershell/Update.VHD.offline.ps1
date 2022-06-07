#https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/mount-and-modify-a-windows-image-using-dism
#https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/add-or-remove-packages-offline-using-dism

$VHDFile = "D:\Images\Server2019\17763.737.amd64fre.rs5_release_svc_refresh.190906-2324_server_serverdatacentereval_en-us_1.vhd"
$VHDFile = "D:\Images\Server2016\srv2016_datacenter.vhdx"
DISM.exe /Mount-image /imagefile:$VHDFile /Index:1 /MountDir:D:\Mount 
Get-ChildItem -Path "D:\Images\Server2016\ServiceStack" -Filter *.msu -recurse | Foreach-Object {
    Dism.exe /Image:D:\Mount /Add-Package /PackagePath:$($_.FullName)
}
Get-ChildItem -Path "D:\Images\Server2016\Updates" -Filter *.msu -recurse | Foreach-Object {
    Dism.exe /Image:D:\Mount /Add-Package /PackagePath:$($_.FullName)
}
Dism.exe /Image:D:\Mount /Add-Package /PackagePath:"D:\Images\Server2019.Updates\ServiceStack\windows10.0-kb4539571-x64_24d9621cc81434610770c25f5ba38082f8d12065.msu" /PackagePath:"D:\Images\Server2019.Updates\Updates\03.2020\windows10.0-kb4554354-x64_656e139a25ad6577ddabc2213268e7ceb82af165.msu" 
Dism.exe /Image:D:\Mount /cleanup-image /StartComponentCleanup /ResetBase #Optimierung des Images
Dism.exe /Image:D:\Mount /Get-Packages
Dism.exe /Image:D:\Mount /Get-Features
Dism.exe /Image:D:\Mount /Disable-Feature /FeatureName:SMB1Protocol
mkdir D:\Mount\Temp

Dism.exe /Image:D:\Mount /Get-Drivers #https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/add-and-remove-drivers-to-an-offline-windows-image
DISM.exe /Image:D:\Mount /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:D:\Images\Server2016\sources\sxs  #https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/deploy-net-framework-35-by-using-deployment-image-servicing-and-management--dism

# Dism.exe /Commit-Image /MountDir:D:\Mount /CheckIntegrity   #muss nicht sein
Dism.exe /Unmount-image /MountDir:D:\Mount /Commit

Dism.exe /get-ImageInfo /ImageFile:"D:\Images\Server2019\17763.737.amd64fre.rs5_release_svc_refresh.190906-2324_server_serverdatacentereval_en-us_1.vhd"

#https://www.windowspro.de/wolfgang-sommergut/angepasstes-image-windows-10-erstellen-powershell-hyper-v
Install-Module -Name WindowsImageTools
Import-Module WindowsImageTools
Get-Command -Module WindowsImageTools
dism /Get-WimInfo /wimFile:"X:\sources\install.wim"
Convert-WIM2VHD -Path D:\Images\Server2016\srv2016_standard_core.vhdx -SourcePath x:\Sources\install.wim -index 1 -Size 40GB -DiskLayout UEFI -Dynamic
Convert-WIM2VHD -Path D:\Images\Server2016\srv2016_standard.vhdx -SourcePath x:\Sources\install.wim -index 2 -Size 40GB -DiskLayout UEFI -Dynamic
Convert-WIM2VHD -Path D:\Images\Server2016\srv2016_datacenter_core.vhdx -SourcePath x:\Sources\install.wim -index 3 -Size 40GB -DiskLayout UEFI -Dynamic
Convert-WIM2VHD -Path D:\Images\Server2016\srv2016_datacenter.vhdx -SourcePath x:\Sources\install.wim -index 4 -Size 40GB -DiskLayout UEFI -Dynamic

Convert-WIM2VHD -Path D:\Images\Server2019\srv2019_standard_core.vhdx -SourcePath x:\Sources\install.wim -index 1 -Size 40GB -DiskLayout UEFI -Dynamic
Convert-WIM2VHD -Path D:\Images\Server2019\srv2019_standard.vhdx -SourcePath x:\Sources\install.wim -index 2 -Size 40GB -DiskLayout UEFI -Dynamic
Convert-WIM2VHD -Path D:\Images\Server2019\srv2019_datacenter_core.vhdx -SourcePath x:\Sources\install.wim -index 3 -Size 40GB -DiskLayout UEFI -Dynamic
Convert-WIM2VHD -Path D:\Images\Server2019\srv2019_datacenter.vhdx -SourcePath x:\Sources\install.wim -index 4 -Size 40GB -DiskLayout UEFI -Dynamic


$u = Start-WUScan  # win10/Server 2019
Install-WUUpdates -Updates $u

$ServerName = 'srv2019-03'
mkdir "D:\VMs\$ServerName" -ErrorAction SilentlyContinue
mkdir "D:\VMs\$ServerName\Virtual Hard Disks" -ErrorAction SilentlyContinue
Copy-Item -Path $VHDFile -Destination "D:\VMs\$ServerName\Virtual Hard Disks\$($ServerName)_Disk_C.vhdx"
New-VM -Path "D:\VMs\$ServerName" -Name $ServerName -MemoryStartupBytes 2048MB -SwitchName extern -Generation 2
Set-VM -Name $ServerName -ProcessorCount 2 
Add-VMHardDiskDrive -VMName $ServerName -Path "D:\VMs\$ServerName\Virtual Hard Disks\$($ServerName)_Disk_C.vhdx"