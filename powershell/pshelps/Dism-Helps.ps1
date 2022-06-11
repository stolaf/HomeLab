break

#Change Productkey (Going from Windows Server 2016 Eval to GA license)
dism /online /Set-Edition:ServerDataCenter /ProductKey:8......DD4 /AcceptEula  #And then after two reboots I log in and can verify that my license have been applied

#Add Treiber to VHDx Image  https://systemscenter.ru/waik.en/html/1a5ab0e4-8f9c-404f-a501-f53b796c1c3e.htm
Dism /image:V:\ /Add-Driver /driver:C:\drivers\mydriver.INF
Dism /image:V:\ /Add-Driver /driver:C:\drivers /recurse
Dism /image:V:\ /Add-Driver /driver:C:\drivers\mydriver.INF /ForceUnsigned
Dism /image:V:\ /Get-Drivers

#Mapping Install-WindowsFeature --> DISM InstallationName
#https://newyear2006.wordpress.com/2016/04/28/die-sache-mit-dem-installationsnamen-und-dem-featurenamen-bei-dism-bzw-powershell-servermanager-modul/
#https://newyear2006.wordpress.com/2016/01/25/unterschiede-zwischen-windows-funktionen-bzw-features-bei-der-installation/
#http://peter.hahndorf.eu/blog/WindowsFeatureViaCmd
#http://blog.ittoby.com/2012/11/installing-net-35-on-windows8server.html

$n=@()
Get-WindowsFeature * | % {$n+= New-Object -TypeName psobject -Property ([ordered]@{Name=$_.Name; InstallName=$_.AdditionalInfo.Item('InstallName')}) }
$n

$n | Where-Object {$_.Name -eq 'NET-Framework-Core'}
Install-WindowsFeature -Name NET-Framework-Core
Enable-WindowsOptionalFeature -Online -Featurename NetFx3 -All
Enable-WindowsOptionalFeature -Online -Featurename NetFx3 -All -LimitAccess -Source \\server\share\source\sxs


#DISM für IC Update nicht benutzen wegen W2K12R2 Bluescreen Problem!
function Update-IC_over_DISM { 
  param (
    $VMName = '*',
    $Notes = '*'
  )

  return

  if ($VMName -eq '*' -and $Notes -eq '*') { 
    $VMs = Hyper-V\Get-VM | Where-Object {$_.Name -notmatch 'POC|FSDEBSY13532|FSDEBSS' -and $_.Notes -notmatch 'SCCM|Linux|PROD' -and $_.IntegrationServicesState -eq 'Update required'}
  } ElseIf ($VMName -eq '*' -and $Notes -ne '*') {
    $VMs = Hyper-V\Get-VM | Where-Object {$_.Name -notmatch 'POC|FSDEBSY13532|FSDEBSS' -and $_.Notes -match $Notes -and $_.IntegrationServicesState -eq 'Update required'}
  } ElseIf ($VMName -ne '*' -and $Notes -eq '*') {
    $VMs = Hyper-V\Get-VM | Where-Object {$_.Name -match $VMName -and $_.IntegrationServicesState -eq 'Update required'}
  }

  $i = 0
  foreach ($VM in $VMs) {
    $i++
    $Notes = $($VM.Notes) -replace '#CLUSTER.*$','' -replace '\n',', '
    Write-Host "$($i.ToString('000'))/$($VMs.Count): Processing '$($VM.Name)' ($Notes)" -ForegroundColor Yellow

    $VMKVP = Get-IOPI_HyperV_VMKVP -VM $VM
    If ($VMKVP.OSVersion -like '5.2*') {continue}  #nicht für Server 2003

    $wasRunning = ($VM.State -eq [Microsoft.HyperV.PowerShell.VMState]::Running)
    if ($wasRunning) {
      Write-Host "`t Set SCOM MaintenanceTime for 30 Minutes" 
      $Null = Set-IOPI_SCOM2007_MaintenanceMode -ComputerName $($VM.Name) -Minutes 30 -Comment "Initiated by $Env:USERNAME on $(Get-Date) for IC Update" -Verbose
      Write-Host "`t Stop VM" 
      $Null = Hyper-V\Stop-VM -VM $VM -Force
    }
    if ($VM.HardDrives | Where-Object {$_.ControllerType -eq 'IDE'}){
      $VhdPath = ($VM.HardDrives | Where-Object {$_.ControllerType -eq 'IDE' -and $_.ControllerNumber -eq 0 -and $_.ControllerLocation -eq 0}).Path
    } else {
      $VhdPath = ($VM.HardDrives | Where-Object {$_.ControllerType -eq 'SCSI' -and $_.ControllerNumber -eq 0 -and $_.ControllerLocation -eq 0}).Path
    }
    Write-Host "`t Mount VHD $VHDPath"     
    $diskNo = (Mount-VHD -Path $VhdPath -Passthru).DiskNumber
    if ((Get-Disk $diskNo).OperationalStatus -eq 'Online') {
      $driveLetter = ''
      (Get-Disk $diskNo | Get-Partition | Get-Volume).DriveLetter | % {if (Test-Path -Path "$($_):\Windows") {$driveLetter = "$($_):"} }
      Write-Host "`t DriveLetter is $driveLetter" 
      if (Get-Item -Path "$driveLetter\Windows" -ErrorAction SilentlyContinue) {
        $ICPath8 = "$Env:WINDIR\vmguest\support\amd64\Windows6.2-HyperVIntegrationServices-x64.cab"
        $ICPath7 = "$Env:WINDIR\vmguest\support\amd64\Windows6.x-HyperVIntegrationServices-x64.cab"
        switch ($VMKVP.OSVersion) {
          {$_ -like '6.3*'} {Write-Host "`t Add Package $ICPath8"; $Null = Add-WindowsPackage -PackagePath $ICPath8 -Path ($driveLetter+'\')}
          {$_ -like '6.2*'} {Write-Host "`t Add Package $ICPath8"; $Null = Add-WindowsPackage -PackagePath $ICPath8 -Path ($driveLetter+'\')}
          {$_ -like '6.1*'} {Write-Host "`t Add Package $ICPath7"; $Null = Add-WindowsPackage -PackagePath $ICPath7 -Path ($driveLetter+'\')}
          Default {}
        }
      }
    } else {
      Write-Host "`t Disk was not ready($((Get-Disk $diskNo).OperationalStatus)): '$VhdPath'" -ForegroundColor Red
    }
    Write-Host "`t DisMount VHD $VHDPath" 
    $Null = Dismount-VHD -Path $VhdPath
    if ($wasRunning) {
      Write-Host "`t Start VM" 
      $Null = Hyper-V\Start-VM -VM $VM
    }
  }
}

#DISM Powershell Modul in Win81 und Server2012R2 enhalten, ansonsten WAIK installieren und nachladen:
Import-Module "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\$env:PROCESSOR_ARCHITECTURE\DISM"

Get-WindowsImage -ImagePath E:\image.wim
# Unmount the VHD file
Dism.exe /Unmount-Image /MountDir:"$MountDir" /Commit

Mount-WindowsImage -ImagePath C:\Win8\install.wim -Index 1 -Path C:\win8\mount
Add-WindowsPackage -Path C:\win8\mountdir -PackagePath C:\win8\updates
Dismount-WindowsImage -Path C:\win8\mountdir -Save

#Der Recurse-Parameter führt dann dazu, dass alle vorhandenen INF-Dateien hinzugefügt werden
Add-WindowsDriver -Path E:\mount -Driver E:\winpe\x64\network -Recurse -ForceUnsigned  #auch nicht von MS signierte Treiber
Get-WindowsDriver -Path E:\mount | Where-Object{$_.Driver -eq 'oem1.inf'} | Remove-WindowsDriver

#es können CAB- oder MSU-Dateien installiert werden
Add-WindowsPackage -Path E:\mount -PackagePath E:\langpacks\de-de\lp.cab -ScratchDirectory E:\Scratch
Get-WindowsPackage -Path E:\mount | Where-Object{$_.PackageName -like '*-InternetExplorer-*10*'} | Remove-WindowsPackage

#Spracheinstellung über DISM
Dism.exe /Image:E:\mount /Set-SKUIntlDefaults:de-DE

#Ein zusätzlicher Integritätscheck verbraucht zwar Zeit, stellt aber die Datenkonsistenz sicher und vermeidet somit spätere Fehler
Dismount-WindowsImage -Path E:\mount -Save -CheckIntegrity
