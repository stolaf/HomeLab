# Intel vPro
```powershell
#Default AMT Password is admin
Import-Module 'C:\Program Files\Intel Corporation\PowerShell\Modules\IntelvPro'
Import-Module 'D:\SCVMMLibrary\PowerShell\Modules\IntelvPro'
Get-Command -Module IntelvPro

$AMTCredential = Get-AmtCredential 'admin' 'Mau....'
$ComputerName = 'CS-HOST2AMT'
Get-AMTFirmwareVersion -ComputerName $ComputerName -Credential $AMTCredential
Get-AMTHardwareAsset -ComputerName $Computername -credential $AMTCredential
Get-AMTAlarmClock -ComputerName $Computername -credential $AMTCredential
Invoke-AMTPowerManagement $Computername -credential $AMTCredential -operation PowerOff
Invoke-AMTForceBoot $Computername -credential $AMTCredential -operation PowerOn -device HardDrive
Invoke-AMTSOL -ComputerName $ComputerName -Credential $AMTCredential
$AMTSession = New-AmtSession -ComputerName $ComputerName -Credential $AMTCredential

New-PSDrive -PSProvider AmtSystem -Name amt -Root \ -ComputerName CS-HOST3AMT -Credential $AMTCredential
Start-ISB_VNCViewerPlus -ComputerName 'CS-HOST2AMT'
. "${Env:ProgramFiles(x86)}\RealVNC\VNCViewerPlus\vncviewerplus.exe" $ComputerName -amtusername=admin

Write-AmtCredential
Get-AmtCredentialPath
```

