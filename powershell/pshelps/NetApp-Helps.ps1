break

#OnCommand System Manager
start-process 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' -ArgumentList 'https://fsdebsgh2100/sysmgr/SysMgr.html#svm&svm=fsdebsgv2130'
start-process 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' -ArgumentList 'https://fsdebsgh2000/sysmgr/SysMgr.html#svm&svm=fsdebsgv2020'

start-process 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' -ArgumentList 'https://fsdebsgh3300/sysmgr/SysMgr.html'   # funktioniert ???
start-process 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' -ArgumentList 'https://fsdebsgh3400/sysmgr/SysMgr.html'   # funktioniert ???

start-process 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' -ArgumentList 'https://fsdebsgh2100/sysmgr/SysMgr.html#svm&svm=fsdebsgv2110'
start-process 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' -ArgumentList 'https://fsdebsgh2100/sysmgr/SysMgr.html#svm&svm=fsdebsgv2120'

Import-Module 'C:\Program Files (x86)\NetApp\NetApp PowerShell Toolkit\Modules\DataONTAP' -Force
Import-Module '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI' -Force
Import-Module CredentialManager

<# Hyper-V KONS/PROD
https://wiki-prod/display/HYP/Shares+-+Naming+and+Configuration 
https://wiki-prod/display/HYP/NetApp+Storage+Replacement
#>

<#
Witness Share P-IBA SQL P : \\fsdebsgv2201\witness_sql_p
Witness Share K-IBA SQL K : \\fsdebsgv2202\witness_sql_c
Witness Share I-IBA SQL P : \\fsdebsgv2203\witness_sql_i
Witness Share SQL P : \\fsdebsgv2205\witness_sql_fs01_p
Witness Share SQL K : \\fsdebsgv2206\witness_sql_fs01_c
Witness Share SQL I : \\fsdebsgv2207\witness_sql_fs01_i
Witness Share Hyper-V : \\fsdebsgv2208\witness_hyv_witness
#>

Import-Module 'C:\Program Files (x86)\NetApp\NetApp PowerShell Toolkit\Modules\DataONTAP' -Force
# Import-Module 'DataONTAP' -Force

<#
    start http://community.netapp.com/t5/Deutschland/NetApp-PowerShell-kann-Sachen-die-kann-nicht-mal-die-CLI-Teil-1/ba-p/92485
    http://community.netapp.com/t5/Deutschland/NetApp-PowerShell-kann-Sachen-die-kann-nicht-mal-die-CLI-Teil-2/ba-p/92507
    http://community.netapp.com/t5/Deutschland/NetApp-PowerShell-kann-Sachen-die-kann-nicht-mal-die-CLI-Teil-3/ba-p/92511
    http://community.netapp.com/t5/Deutschland/Andi-s-Link-Sammlung/ba-p/110147
    http://community.netapp.com/t5/Microsoft-Cloud-and-Virtualization-Discussions/bd-p/microsoft-cloud-and-virtualization-discussions/page/3
#>
break

Show-NcHelp 
Get-NcHelp -Category Cifs  # Cifs|Clone|Cluster|Disk|Exports|FC|Fcp|File|Igroup|Iscsi|Net|Nfs|Portset|Quota|Security|sis|Snapmirror|Storage|Volume
Get-NaToolkitVersion   # 3.3.0.65 corresponds to version 4.1 of the msi.
Get-Command -Module dataontap Get*
Get-Command -Module dataontap *vhdx*
Get-Command -Module dataontap *vmdk*
Get-Command -Module dataontap *session*
ConvertTo-NaVhdx -SourceVMDK /vol/vol2/cifs/VMDK/Monolithic/win2k8r2.vmdk -DestinationVhdx /vol/vol2/cifs/VHDX/win2k8r2.vhdx
New-NaVirtualDisk C:\Temp\File1.vhdx 10GB -vhdxSet-NaVirtualDiskSize X:\VM1.Vhdx +100g  #-35GB|+10%|-minimu

$NcCredential = Get-IOPI_StoredCredential -Target "dkx1s72415" -UserName 'dkx1s72415'
Connect-NcController -Name fsdebsgv2010b -HTTPS -Credential $NcCredential    #PK A06
Connect-NcController -Name fsdebsgv2110b -HTTPS -Credential $NcCredential    #PK C07

$NcCredential = Get-IOPI_StoredCredential -Target "dkx1s72618" -UserName 'dkx1s72618'
Connect-NcController -Name fsdebsgv2020b -HTTPS -Credential $NcCredential    #PK SQL A06
Connect-NcController -Name fsdebsgv2120b -HTTPS -Credential $NcCredential    #PK SQL C07
$NcCredential = Get-IOPI_StoredCredential -Target "mgmt\dkx1s72618" -UserName 'mgmt\dkx1s72618'
Connect-NcController -Name fsdebsgv2130b -HTTPS -Credential $NcCredential    #SCB CDC1
Connect-NcController -Name fsdebsgv5402b -HTTPS -Credential $NcCredential    #SCB CDC2

$NcCredential = Get-IOPI_StoredCredential -Target "mgmt\dkx1s72618" -UserName 'dkx1s72618'
Connect-NcController -Name fsdebsgv2140b -HTTPS -Credential $NcCredential    #PK SQL CDC1'
Connect-NcController -Name fsdebsgv5404b -HTTPS -Credential $NcCredential    #PK SQL CDC2'

$NcCredential = Get-IOPI_StoredCredential -Target "????" -UserName '???'  # Admin Zugriff nicht benötigt
Connect-NcController -Name fsdebsgv3208b  -HTTPS -Credential $NcCredential   #Witness B10
Connect-NcController -Name fsdebsgv2208b  -HTTPS -Credential $NcCredential   #Witness B10 neu  \\fsdebsgv2208\witness_hyv_witness 

$NcCredential = Get-IOPI_StoredCredential -Target "dkx1s69170" -UserName 'dkx1s69170'
Connect-NcController -Name fsdebsgv3310b -HTTPS -Credential $NcCredential    #IBA INT Neu C07
Connect-NcController -Name fsdebsgv3410b -HTTPS -Credential $NcCredential    #IBA INT Neu A06
Connect-NcController -Name fsdebsgv3320b -HTTPS -Credential $NcCredential    #SQL INT Neu C07
Connect-NcController -Name fsdebsgv3420b -HTTPS -Credential $NcCredential    #SQL INT Neu A06
$NcCredential =Get-Credential -UserName 'mgmt\dkx1s69170' -Message 'Credential' #
Connect-NcController -Name fsdebsgv3340b -HTTPS -Credential $NcCredential    #SQL nonPROD CDC1
Connect-NcController -Name fsdebsgv5602b -HTTPS -Credential $NcCredential    #SQL nonPROD CDC2
Connect-NcController -Name 10.33.19.50 -HTTPS -Credential $NcCredential

$NcCredential = Get-IOPI_StoredCredential -Target "dkx1s00048" -UserName 'dkx1s00048'
Connect-NcController -Name fsdebsgv1530b -HTTPS -Credential $NcCredential    #TFS A06
Connect-NcController -Name fsdebsgv1531b -HTTPS -Credential $NcCredential    #TFS C07

Connect-NcController -Name fsdebsgh3300 -HTTPS -Credential $NcCredential 
get-ncvol -name fsdebsgv3320_SQL_I | Select-Object * | Format-Table -AutoSize
Get-NcNode
Get-NcVol -VserverContext fsdebsgv3320
Get-NcVol -VserverContext fsdebsgv3320 | Format-Table -AutoSize
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match '1D6247FD-87BA-40EB-B866-29FBE6E07E23'
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match '1D6247FD-87BA-40EB-B866-29FBE6E07E23' | Select-Object *
Get-NcLock | Where-Object Path -Match '1D6247FD-87BA-40EB-B866-29FBE6E07E23' | Select-Object *
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match '1D6247FD-87BA-40EB-B866-29FBE6E07E23' | Select-Object *
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match '1D6247FD-87BA-40EB-B866-29FBE6E07E23' | Select-Object NcController,Node,Path
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match 'FSDEBSYDE50005' | Select-Object NcController,Node,Path
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match 'FSDEBSYDE50005' | Select-Object NcController,Node,Path
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match 'FSDEBSYDE50019' | Select-Object NcController,Node,Path
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match 'FSDEBSYDE50019' | Select-Object NcController,Node,Path,Share,ContinuouslyAvailable,HostingVolume
Get-NcCifsSession | Get-NcCifsSessionFile | Where-Object Path -Match 'FSDEBSYDE50019' | Select-Object NcController,Node,Path,Share,ContinuouslyAvailable,HostingVolume | Format-Table -AutoSize

#SMB Multichannel aktiv?
Get-NcCifsOption | select IsMultichannelEnabled
Get-NcCifsOption | select IsMultichann
set-NcCifsOption  -IsMultichannelEnabled $true 

Get-NcCifsSessionFile | Where-Object Path -Like 'FSDIBSY114411*' 
Get-NcSnapshot
Get-NcSnapshotPolicy

(get-NcFileDirectorySecurity -Path /fsdebsgv0460_SQL_I).Acls
Get-NcQtree -Qtree Share66178B83 | get-ncquota | Select-Object Quotatarget,DiskLimit
Get-NcQtree -Qtree Share2BC35C41 | Remove-NcQtree -Force

Get-NcVol | Select-Object Name,TotalSize,Aggregate
Get-NcVol -Name 'fsdebsgv3310_HyV_I' | Get-NcVolSize
(Get-NcVol -Name 'FSDEBSGV0430_HyV_I' | Get-NcVolSize).VolumeSize / 1GB
(Get-NcVol -Name 'FSDEBSGV0450_HyV_Prj' | Get-NcVolSize).VolumeSize / 1GB
Get-NcVolRoot
Get-NcSystemVersion | Select-Object *
Get-NcLicense 
Get-NaControllerError
Get-NcCifsSessionFile 
Close-NcCifsSessionFile
Get-NcCifsOption | Select-Object *

Get-NCVol -Name 'fsdebsgv3310_HyV_I' | select *
New-NcDirectory -Path '/fsdebsgv3310_HyV_I/Witness' -Permission 777 

Get-NCVol -Name 'fsdebsgv3340_HyV_I' | Select *
New-NcDirectory -Path '/vol/fsdebsgv5404_HyV_SQL/pCDC2SQLVMs' -Permission 777 
Add-NcCifsShare  -Name pCDC2SQLVMs -Path '/fsdebsgv5402_HyV_SQL/pCDC2SQLVMs' -ShareProperties @("continuously_available","browsable","oplocks") -Comment 'SQL PROD CDC2' 
Remove-NcCifsShare  -Name 'fsdebsgv2130_HyV_SC_1'

New-NcDirectory -Path '/vol/fsdebsgv3340_HyV_I/iCDC1SQLVMs' -Permission 777 
Add-NcCifsShare  -Name iCDC1SQLVMs -Path '/fsdebsgv3340_HyV_I/iCDC1SQLVMs' -ShareProperties @("continuously_available","browsable","oplocks") -Comment 'SQL nonPROD CDC1' 
Remove-NcCifsShare  -Name fsdebsgv2140_HyV_SQL_1

Get-NcCifsShare -Name 'dCDC2-SQLVMs' | Select ShareName, ShareProperties
Get-NcCifsShare | Format-Table -AutoSize
Get-NcCifsShare -Name 'pCDC1-SCBVMs' ##| Remove-NcCifsShare
Get-NcEfficiency -Volume 'FSDEBSGV0430_HyV_I'

$Share = 'iC07DMZ2u3VMs'
Get-NcCifsShareAcl -share $Share | Format-Table -a
Get-NcCifsShareAcl -Share 'scbC07Witness'  | Format-Table -a
Add-NcCifsShare -Name prjSRTemplates -Path /FSDEBSGV0550_project/prjSRTemplates -ShareProperties @('continuously_available','oplocks','browsable')
Add-NcCifsShare -Name prjGFTemplates -Path /FSDEBSGV0450_HyV_Prj/prjGFTemplates -ShareProperties @('continuously_available','oplocks','browsable')
Get-NcCifsShare -Name pkA06Library | Select-Object shareName,ShareProperties,Volume
Add-NcCifsShareAcl -Share $Share  -UserOrGroup 'mgmt\DKX1S39249' -Permission 'full_control'
Add-NcCifsShareAcl -Share $Share -UserOrGroup 'FS01\FS01-ADM-HyperV-Server-S-G' -Permission 'full_control'
Add-NcCifsShareAcl -Share prjGFDMZ1VMs  -UserOrGroup 'everyone' -Permission 'full_control'
Add-NcCifsShareAcl -Share iC07SQLVMs-1  -UserOrGroup 'mgmt\MGMT-ADM-IHIOPI-Server-S-L' -Permission 'full_control'
Add-NcCifsShareAcl -Share pCDC1SQLVMs  -UserOrGroup 'FS01\FS01-ADM-HyperV-Server-S-G' -Permission 'full_control'
Add-NcCifsShareAcl -Share C07TFSLibrary -UserOrGroup 't-fs01.vwfs-ad\FSDEBSNE0181$' -Permission 'full_control'
Add-NcCifsShareAcl -Share prjSRNexusVMs -UserOrGroup mgmt\DKX1S89912 -Permission 'full_control'
Add-NcCifsShareAcl -Share pCDC1SQLVMs -UserOrGroup 'mgmt\FSDEBSNE0171$' -Permission 'full_control'
Add-NcCifsShareAcl -Share prjSRNexusVMs -UserOrGroup mgmt\FSDEBSNE0162$ -Permission 'full_control'
Add-NcCifsShareAcl -Share scbA06TFSVMs -UserOrGroup mgmt\MGMT-ADM-IHIOPI-Server-S-L -Permission 'full_control'
Add-NcCifsShareAcl -Share prjSRNexusVMs -UserOrGroup mgmt\MGMT-ADM-ISBS-Server-S-L -Permission 'full_control'
Add-NcCifsShareAcl -Share pCDC1SQLVMs   -UserOrGroup "mgmt\dkx1s72618" -Permission 'full_control'
Add-NcCifsShareAcl -Share iSRDMZ2u3VMs -UserOrGroup 'MGMT\FSDEBSNE0156$' -Permission 'full_control'
Remove-NcCifsShareAcl -Share iCDC1SQLVMs -UserOrGroup 'mgmt\FSDEBSNE10412$'
Add-NcCifsShareAcl -Share prjGFWitness -UserOrGroup fs01\dkx8zb8adm -Permission 'full_control'

Add-NcCifsShareAcl -Share pGFDMZ1VMs -UserOrGroup mgmt\FSDEBSNE0221$ -Permission 'full_control'
Add-NcCifsShareAcl -Share iCDC1SQLVMs -UserOrGroup mgmt\dkx1s69170 -Permission 'full_control'
Add-NcCifsShareAcl -Share pCDC2SQLVMs -UserOrGroup 'mgmt\FSDEBSNE20522$' -Permission 'full_control'
Add-NcCifsShareAcl -Share pCDC2SQLVMs -UserOrGroup 'mgmt\dkx1s72618' -Permission 'full_control'

Add-NcCifsShareAcl -Share scbC07TFSVMs -UserOrGroup mgmt\MGMT-ADM-IHIOPI-Server-S-L -Permission 'full_control'
Add-NcCifsShareAcl -Share pGFDMZ1VMs -UserOrGroup mgmt\MGMT-ADM-ISBS-Server-S-L -Permission 'full_control'
Add-NcCifsShareAcl -Share pSRDMZ2u3VMs -UserOrGroup 'mgmt\FSDEBSNE0360$' -Permission 'full_control'
Add-NcCifsShareAcl -Share pSRDMZ1VMs -UserOrGroup 'mgmt\dkx1s67170' -Permission 'full_control'
Add-NcCifsShareAcl -Share pGFDMZ1VMs -UserOrGroup 'mgmt\dkx1s67170' -Permission 'full_control'

Get-NCFile -Path 'FSDEBSGV0430_HyV_I/iGFDMZ2u3VMs/Library/*'
Get-NCFile -Path 'FSDEBSGV0530_HyperV_I/iSRDMZ2u3VMs/FSDIBSY13521/Virtual Hard Disks/FSDIBSY13521_Disk_C.vhdx' | Remove-NcFile -Confirm:$False 
Get-NcVol -Name 'FSDEBSGV0530_HyperV_I' | Select-Object *
Get-NcVol -Name 'FSDEBSGV0430_HyV_I' | Get-Member -MemberType Property | ForEach-Object {Write-Host "$($_.Name)" -ForegroundColor Yellow;(Get-NcVol -Name 'FSDEBSGV0430_HyV_I').$($_.Name)}
Get-NcCifsSessionFile | Where-Object Path -Like '*FSDIBSY114411*' | Close-NcCifsSessionFile 
Close-NcCifsSessionFile -ConnectionId 1166107492 -Node FSDEBSGC0501  #funktioniert nicht
Close-NcCifsSessionFile -Node FSDEBSGC0501 -FileId 244710 #funktioniert nicht
vserver lock show -vserver FSDEBSGV0530 -path '/FSDEBSGV0530_HyperV_I//iSRDMZ1VMs/FSDIBSY11441-1/Virtual Hard Disks/FSDIBSY13521_Disk_C.vhdx' -instance
vserver lock break -lockid bd78345c-fcf6-4624-90a8-83d347f7e9f5

Get-NcFile -Path '/vol/FSDEBSGV0530_HyperV_I/iSRDMZ1VMs/FSDIBSY11441-1' | Select-Object *
Copy-NaHostFile -SourceFile '...' -DestinationFile '...'  #not for SMB, only BlockStorage
Copy-NaHostFile -?
Add-NcCifsShare -Name prjGFNexusVMs -Path /FSDEBSGV0450_HyV_Prj/prjGFNexusVMs -ShareProperties @('continuously_available','oplocks','browsable')
Get-NcCifsShareAcl -Share prjGFNexusVMs

Remove-NcCifsShareAcl -Share pGFDMZ2u3VMs -UserOrGroup mgmt\FSDEBSNE0324$

Add-Nccifsshare -Name prjSRBackup -Path /FSDEBSGV0550_project/prjSRBackup
Get-NcQuota -Target '/vol/fsdebsgv3420_SQL_I/Share052ECE41' | Select-Object * | Format-Table -AutoSize
Set-NcQuota -Path '/vol/fsdebsgv3420_SQL_I/Share052ECE41' -DiskLimit 11TB
Set-NcQuota -Path /vol/FSDEBSGV053_HyV_Prj/prjGFDMZ2u3VMs -DiskLimit 6.5TB
Disable-NcQuota -Volume FSDEBSGV0550_project
Enable-NcQuota -Volume FSDEBSGV0550_project
Get-NcJob
Get-NcQuota | Format-Table -a
Set-NcQuota -Path '/vol/FSDEBSGV0440_HyV_P/pGFDMZ1VMs' -DiskLimit 8TB   #Error Meldung ignorieren
Set-NcQuota -Path '/vol/FSDEBSGV0440_HyV_P/pGFDMZ2u3VMs' -DiskLimit 24TB
Set-NcQuota -Path '/vol/FSDEBSGV0540_HyV_P/pSRDMZ1VMs' -DiskLimit 8TB
Set-NcQuota -Path '/vol/FSDEBSGV0540_HyV_P/pSRDMZ2u3VMs' -DiskLimit 24TB
Set-NcQuota -Path '/vol/FSDEBSGV0530_HyperV_I/iSRDMZ1VMs' -DiskLimit 4TB
Set-NcQuota -Path '/vol/FSDEBSGV0530_HyperV_I/iSRDMZ2u3VMs' -DiskLimit 8TB
Set-NcQuota -Path '/vol/FSDEBSGV0430_HyV_I/iGFDMZ1VMs' -DiskLimit 4TB
Set-NcQuota -Path '/vol/FSDEBSGV0430_HyV_I/iGFDMZ2u3VMs' -DiskLimit 8TB

Disable-NcQuota -Volume FSDEBSGV0450_HyV_Prj
Get-NcJob
Enable-NcQuota -Volume fsdebsgv3420_SQL_I
Get-NcQuota | Format-Table -a

Read-NcDirectory 'FSDEBSGV0440_HyV_P/pGFDMZ2u3VMs/FSDEBSY12422.oljk'
(Get-NcFileDirectorySecurity -Path '/FSDEBSGV0440_HyV_P/pGFDMZ2u3VMs/FSDEBSY12422.oljk')
(Get-NcFileDirectorySecurity -Path '/FSDEBSGV0440_HyV_P/pGFDMZ2u3VMs/FSDEBSY12422.oljk').Acls
Get-NcFileDirectorySecurity -Path '/FSDEBSGV0440_HyV_P/pGFDMZ2u3VMs/FSDEBSY12422.oljk/FSDEBSY12422_Disk_C.vhdx'

