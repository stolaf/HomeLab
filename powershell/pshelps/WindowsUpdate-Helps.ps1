break

#vorherige Updates in Recovery Console deinstallieren wenn der Server nicht mehr booten will
#https://wiki-prod.fs01.vwf.vwfs-ad/pages/viewpage.action?pageId=167355782
DISM /Image:C:\ /Cleanup-Image /revertpendingactions 


https://4sysops.com/archives/install-windows-updates-remotely-with-the-powershell/
Install-Module PSWindowsUpdate -MaximumVersion 1.5.2.6
Get-Command -Module PSWindowsUpdate
Write-Verbose "Create schedule service object"
$Scheduler = New-Object -ComObject Schedule.Service

#in Invoke-WUInstall           
$Task = $Scheduler.NewTask(0)
$RegistrationInfo = $Task.RegistrationInfo
$RegistrationInfo.Description = $TaskName
$RegistrationInfo.Author = $User.Name
$Settings = $Task.Settings
$Settings.Enabled = $True
$Settings.StartWhenAvailable = $True
$Settings.Hidden = $False
$Action = $Task.Actions.Create(0)
$Action.Path = "powershell"
$Action.Arguments = "-Command $Script"
        
$Task.Principal.RunLevel = 1

Invoke-WUInstall -ComputerName Test-1 -Script {Import-Module PSWindowsUpdate; Get-WUInstall -AcceptAll | Out-File C:\PSWindowsUpdate.log } -Confirm:$false -Verbose

$cim = New-CimSession -ComputerName Test-1
(Get-ScheduledTask -TaskPath "\" -CimSession $cim -TaskName PSWindowsUpdate).actions
Invoke-WUInstall -ComputerName Test-1,Test-2,Test-3,Test-4 -Script {Import-Module PSWindowsUpdate; Get-WUInstall -AcceptAll | Out-File C:\PSWindowsUpdate.log  } -Confirm:$false -Verbose

Invoke-Command -ComputerName Test-1,Test-2,Test-3 -ScriptBlock {
  Get-Item C:\PSWindowsUpdate.log | Select-String -Pattern "failed" -SimpleMatch | Select-Object -Property line 
} | Select-Object -Property Line,PSComputerName