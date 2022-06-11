break 

<# Automatisches Konvertieren von MBR-Bootfestplatten in GPT-Bootfestplatten in Windows, besonders auch für Hyper-V VMs
https://newyear2006.wordpress.com/2018/08/26/automatisches-konvertieren-von-mbr-bootfestplatten-in-gpt-bootfestplatten-in-windows-besonders-auch-fr-hyper-v-vms/
mit dem Tool MBR2GPT.EXE, in Server 2019 enthalten
Mount-WindowsImage -ImagePath D:\Sources\Boot.WIM -ReadOnly -Index 1 -Path C:\Temp
C:\Temp\Windows\System32\mbr2gpt.exe
Dismount-WindowsImage -Path C:\Temp -Discard
#>

#QEMU disk image utility 
# It is used for converting, creating and consistency checking of various virtual disk formats. It's compatible with Hyper-V, KVM, VMware, VirtualBox and Xen virtualization solutions.
# This build has been optimized for Windows Server (x64), including Windows Nano Server.
# https://cloudbase.it/qemu-img-windows/
# https://newyear2006.wordpress.com/2017/08/25/konvertieren-von-virtuellen-festplattenimages-in-vhd-oder-vhdx-zur-verwendung-in-hyper-v-oder-azure/
. "\\fsdebsgv4911\iopi_sources$\Install\Tools\qemu-img-win-x64-2_3_0\qemu-img.exe" -h   #Help
. "\\fsdebsgv4911\iopi_sources$\Install\Tools\qemu-img-win-x64-2_3_0\qemu-img.exe" convert .\W2K16-EN-DataCenter-SysPrep.vhdx -O qcow2 .\W2K16-EN-DataCenter-SysPrep.qcow2  #Work
. "\\fsdebsgv4911\iopi_sources$\Install\Tools\qemu-img-win-x64-2_3_0\qemu-img.exe" convert "\\FSDEBSY44139\Deployment\Images\ImageGroup1\W2K16-EN-DataCenter-SysPrep.vhdx" -O qcow2 \\FSDEBSY44139\Deployment\Images\ImageGroup1\W2K16-EN-DataCenter-SysPrep.qcow2
. "\\fsdebsgv4911\iopi_sources$\Install\Tools\qemu-img-win-x64-2_3_0\qemu-img.exe" info \\FSDEBSY44139\Deployment\Images\ImageGroup1\W2K16-EN-DataCenter-SysPrep.qcow2
. "\\fsdebsgv4911\iopi_sources$\Install\Tools\qemu-img-win-x64-2_3_0\qemu-img.exe" check \\FSDEBSY44139\Deployment\Images\ImageGroup1\W2K16-EN-DataCenter-SysPrep.qcow2

Resize-VHD -Path "\\fsdebsy44123\SCVMMLibrary\VHD\W2K12R2-EN-DataCenter-SCCM.vhdx" -SizeBytes 50GB
Convert-VHD -Path "\\fsdebsgv0430.mgmt.fsadm.vwfs-ad\iGFInstall\W2K16-EN-Standard-Gen2_BL_SV.vhdx" -DestinationPath "\\fsdebsy44123.mgmt.fsadm.vwfs-ad\SCVMMLibrary\VHD\W2K16-EN-Standard-Gen2_BL_SV_2018_02_27.vhdx" -VHDType Fixed

Mount-Vhd "\\fsdebsy44123\SCVMMLibrary\VHD\W2K12R2-EN-DataCenter-SCCM.vhdx" -passthru | Get-Disk | Get-Partition | Get-Volume
Resize-Partition -Driveletter G -size 60GB
Dismount-Vhd "\\fsdebsy44123\SCVMMLibrary\VHD\W2K12R2-EN-DataCenter-SCCM.vhdx"
Resize-Vhd "\\fsdebsy44123\SCVMMLibrary\VHD\W2K12R2-EN-DataCenter-SCCM.vhdx" -ToMinimumSize

# Microsoft Virtual Machine Converter 3.0
# start https://www.microsoft.com/en-us/download/details.aspx?id=42497
Import-Module -Name "$env:ProgramW6432\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1"

ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath 'C:\Temp\Nextcloud_Community_VM_PRODUCTION.vmdk' -DestinationLiteralPath 'd:\Hyper-V\VHDs' -VhdType FixedHardDisk -VhdFormat Vhdx
Get-ChildItem -Filter *.vmdk | ForEach-Object {ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath $_.Fullname -DestinationLiteralPath D:\Hyper-V\VHDs -VhdType FixedHardDisk -VhdFormat vhdx}

#########################
#Use robocopy in restartable mode --> very slow
#It is important that you do not use a trailing slash on the folder names! If you want to copy multiple files, just enter them with a space between each.
robocopy /z "C:\LocalVMs\Virtual Hard Disks" Z:\Backup server1.vhdx
robocopy /z SOURCE_FOLDER DESTINATION_FOLDER VHDX_FILENAME

<#
    Manually Copying a Hyper-V Disk the Safer Way
    Pros of the VSSADMIN method:

    It's completely safe to use, if you do it right.
    It's not entirely perfect, but some quiescing of data is done. The copied volume is still dirty, though.
    Faster when copying to a network destination than robocopy in restartable mode.
    Works for local disks and CSVs. Won't work for SMB 3 from the Hyper-V host side.
    Cons of the VSSADMIN method:

    Tough to remember (but this blog article should live for a long time, and that's what Favorites and Bookmarks are for)
    If you don't clean up, you could cause your system to have problems. For instance, you might prevent your actual backup software from running later on in the same evening.
    May not work at all if another VSS snapshot exists
    May have problems when third-party and hardware VSS providers are in use
#>

mklink /d C:\vssvolume \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy26\
xcopy "C:\vssvolume\LocalVMs\Virtual Hard Disks\server1.vhdx" Z:\Backup
rmdir C:\vssvolume
vssadmin delete shadows /shadow={e47b5da0-0ae1-415b-b604-e94ff1913586}


. '\\fsdebsgv4911\iopi_sources$\PowerShell\VHD\Convert-WindowsImage.ps1'
$WIMFileName = '\\fsdebsgv4911\iopi_sources$\Install\SCCM_WIM\FSAG-SRV-W2K12R2-STANDARD-DEFAULT-20151201 225247.wim'
Convert-WindowsImage -SourcePath $WIMFileName -Edition 'ServerStandard' -VHDPath 'C:\Temp\W2K12R2-EN-Standard-Gen2_WIM.vhdx' -VHDPartitionStyle GPT -VHDFormat VHDX -SizeBytes 12GB -VHDType Dynamic

New-VHD -Path D:\VMs\Disk2.vhdx -SizeBytes 10GB
New-VHD -Path D:\VMs\Disk2.vhdx -SizeBytes 10GB -Fixed
New-VHD -Path \\CS-HOST1\VM\VM1.VHDX -VHDType Dynamic -SizeBytes 127GB
Hyper-V\New-VM -Name VM1 -Path \\CS-HOST1\VM -Memory 1GB -VHDPath \\FS1\VMS\VM1.VHDX

#VHDX-Datei an SCSI-Controller
Hyper-V\Get-VM vWS2012R2-1 | Add-VMHardDiskDrive -ControllerType SCSI -ControllerNumber 0 -Path D:\VMs\Disk2.vhdx
#Shared VHDX-Datei an SCSI-Controller ab 2012 R2
Add-VMHardDiskDrive $VMName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path 'E:\Shared VHDX\Demo-FSC1\Demo-FSC1 Witness Disk.vhdx' -SupportPersistentReservations
Remove-VMHardDiskDrive -VMName vWS2012R2-1 -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0
Get-VMHardDiskDrive -VMName vWS2012R2-1 -ControllerType SCSI | Format-Table ControllerLocation -AutoSize
Get-VMHardDiskDrive -VMName vWS2012R2-1 -ControllerType SCSI | Format-Table Path, ControllerLocation -AutoSize

#VHDX-Datei an den IDE-Controller
Hyper-V\Get-VM vWS2012R2-1 | Hyper-V\Stop-VM 
Hyper-V\Get-VM vWS2012R2-1 | Add-VMHardDiskDrive -ControllerType IDE -ControllerNumber 0 -ControllerLocation 1 -Path D:\VMs\Disk2.vhdx 
Hyper-V\Get-VM vWS2012R2-1 | Hyper-V\Start-VM

#Initialize Disk
New-VHD -Path D:\temp\Install.vhdx -Dynamic -SizeBytes 1GB
Mount-VHD D:\tempDiskNumber\Install.vhdx
Get-Disk | Where-Object partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Disk2' -Confirm:$false

#Exchange Files in VM
New-VHD -Path c:\temp\MobileData.vhdx -Dynamic -SizeBytes 10GB | Select-Object Path | Mount-VHD
Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -AssignDriveLetter -MbrType IFS | Format-Volume -Confirm:$false | Select-Object DriveLetter | Format-Table -AutoSize
Copy-Item C:\ToVM -Destination E:\ -Recurse
Dismount-VHD C:\temp\MobileData.vhdx
Add-VMHardDiskDrive -VMName VMTest -Path C:\temp\MobileData.vhdx -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0
Remove-VMHardDiskDrive -VMName VMTest -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0

#increase VHD Size
Resize-VHD -Path '...' -ToMinimumSize
Hyper-V\Get-VM 'Test' | Select-Object -expand HardDrives | Get-Vhd
Hyper-V\Get-VM 'Test' | Select-Object -expand HardDrives | Get-Vhd
Hyper-V\Get-VM 'Test' | Select-Object -expand HardDrives | Select-Object -first 1 | resize-vhd -SizeBytes 20gb -passthru -whatif
Get-VHD (Hyper-V\Get-VM -Name 'FSDEBSY55573' | Get-VMHardDiskDrive).path | Where-Object Path -match 'D.vhdx' | Resize-VHD -SizeBytes 100GB

Hyper-V\Get-VM | Select-Object -expand harddrives | foreach {
  $vm = $_.VMName
  Get-VHD $_.path | Select-Object @{Name='VMName';Expression={$vm}},
  Path,VHDType,VHDFormat,Size,FileSize,FragmentationPercentage,
  @{Name='Utilization';Expression={($_.filesize/$_.size)*100}}
} | Out-GridView -Title 'VHD Report'

#Shrinking VHD   http://technet.microsoft.com/en-us/library/hh848535.aspx
Resize-VHD -Path c:\BaseVHDX.vhdx -SizeBytes 40GB
Resize-VHD -Path c:\BaseVHDX.vhdx -ToMinimumSize

#Shrinking a VHD in Windows 8 - fast!
Hyper-V\get-vm rz-mcs | Select-Object ID | get-vhd | Select-Object path
mount-vhd Test.VHDX -passthru | get-disk | get-partition | get-volume
resize-partition -driveletter S: -size 20GB
dismount-vhd Test.VHDX
resize-vhd Test.VHDX -ToMinimumSize
