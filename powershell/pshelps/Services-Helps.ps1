break

#New Service
$sshdDesc = "SSH protocol based service to provide secure encrypted communications between two untrusted hosts over an insecure network."
New-Service -Name sshd -DisplayName "OpenSSH SSH Server" -BinaryPathName `"$sshdpath`" -Description $sshdDesc -StartupType Manual | Out-Null
sc.exe privs sshd SeAssignPrimaryTokenPrivilege/SeTcbPrivilege/SeBackupPrivilege/SeRestorePrivilege/SeImpersonatePrivilege

#how-to-run-a-powershell-script-as-a-windows-service
https://4sysops.com/archives/how-to-run-a-powershell-script-as-a-windows-service/
download NSSM https://nssm.cc/download
$nssm = (Get-Command nssm).Source
$serviceName = 'Polaris'
$powershell = (Get-Command powershell).Source
$scriptPath = 'C:/4sysops/Start-Polaris.ps1'
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
& $nssm install $serviceName $powershell $arguments
& $nssm status $serviceName
Start-Service $serviceName
Get-Service $serviceName

#ServiceProcess als eigenständigen Process laufen laufen
# sc.exe config <ServiceName> type= own   #Restart-Service

$wmiServices = Get-CimInstance -ClassName win32_service -Property Name,PathName   #as admin
Get-Service | Select-Object -Property *,@{Name = 'PathName'; Expression = { $serviceName = $_.Name; (@($wmiServices).where({ $_.Name -eq $serviceName })).PathName }}

$s = Get-CimInstance -Query "SELECT * FROM Win32_Service WHERE Name='Winmgmt'"
Get-CimAssociatedInstance -InputObject $s -Association Win32_DependentService
Get-CimClass -ClassName *Service* -Qualifier 'Association'

Get-CimInstance Win32_Service -Filter "state = 'running' AND Name='PSScriptwatcher'" -Property $P | Format-List 'name', 'startname', 'startmode', 'pathname', 'description'

@(Get-Service).Where({$_.Status -eq 'Running'})  #PS 4.0

# Delete Service
$service = Get-WmiObject -Class Win32_Service -Filter "Name='CcmExec'"
$service.delete()
sc.exe \\server delete 'MyService' 

#Starting Services Remotely
Set-Service -Name Spooler -Status Running -ComputerName Server12

#Change Service Account Password
$localaccount = '.\sample-de-admin-local'
$newpassword = 'secret@Passw0rd'
$service = Get-WmiObject Win32_Service -Filter 'Name='Spooler''
$service.Change($null,$null,$null,$null,$null,$null,$localaccount, $newpassword)

#Service RunAs ermittlen
Get-WmiObject -Class 'Win32_Service' | Where-Object {$_.StartName -match 'zz_acuser'}

#Stop Service with wait
$service = Get-Service -Name Spooler
$service.Stop()
$service.WaitForStatus('Stopped','00:00:02')  #wartet 2s
if ($service.Status -ne 'Stopped') { Write-Warning 'Something is fishy here...' }
$service

#refresh Service status
$svc = Get-Service -Name W3SVC
$Svc.Refresh()
$svc.WaitForStatus('Stopped')
$svc.WaitForStatus('Stopped','00:00:05')

#find services that have the same dependencies
Get-Service -RequiredServices rpcss

Set-Service -Name Spooler -Status 'Stopped' -ComputerName targetcomputer
Invoke-Command { Stop-Service -Name Spooler -Force } -ComputerName targetcomputer

Get-WmiObject -Class 'Win32_Service' | Where-Object {$_.StartMode -eq 'Auto'} | Where-Object {$_.State -eq 'Stopped'} | Start-Service -ErrorAction SilentlyContinue
Get-WmiObject win32_service -comp (Get-Content servers.txt) | Select-Object __server,name,startmode,state,status

([wmi]'Win32_Service.Name="Spooler"').ChangeStartMode('Automatic').ReturnValue
([wmi]'Win32_Service.Name="Spooler"').ChangeStartMode('Manual').ReturnValue
Get-Service spooler | Set-Service -StartupType Automatic
([wmi]'Win32_Service.Name="Spooler"').StartMode

#Get Service Exe Path
get-wmiobject -query "select PathName from win32_service where name='winrm'" | Select-Object PathName

$machine1 = Get-Service -ComputerName server1
$machine2 = Get-Service -ComputerName IP2
Compare-Object -ReferenceObject $machine1 -DifferenceObject $machine2 -Property Name,Status -passThru | Sort-Object Name | Select-Object Name, Status, MachineName

$own = Get-Service
$other = Get-Service -ComputerName gtlnmiwvm1098
Compare-Object $own $other -property Name, Status -PassThru | Sort-Object DisplayName | Select-Object MachineName, Status, DisplayName, Name | Format-Table -AutoSize

get-service winmgmt -ComputerName $ComputerName  | % { $_.DependentServices } | Where-Object {$_.Status -eq 'Running'} | Select-Object DisplayName,Name,MachineName

#Bug in Powershell 2.0 kann nicht direkt pipen an Stop-Service, aber so gehts
$svc = Get-Service -Name wuauserv -ComputerName Server1
Stop-Service -InputObject $svc

$Computername = '.'
$Service = 'winmgmt'
(Get-WmiObject win32_service -computername $computername -filter "name='$Service'").stopservice()
(Get-WmiObject win32_service -computername $computername -filter "name='$Service'").startservice()
(Get-WmiObject -Class 'win32_service' -filter "name='IBAHostConnector4'").StartMode 

(Get-WmiObject -computer $ComputerName Win32_Service -Filter "Name='$Service'").InvokeMethod('StopService',$null)
Start-Sleep -seconds 2
(Get-WmiObject -computer $computer Win32_Service -Filter "Name='$Service'").InvokeMethod('StartService',$null)

[System.Reflection.Assembly]::LoadWithPartialName('system.serviceprocess')
(new-Object System.ServiceProcess.ServiceController('$Service',"$ComputerName")).Start()
(new-Object System.ServiceProcess.ServiceController('$Service',"$ComputerName")).WaitForStatus('Running',(new-timespan -seconds 5))
(new-Object System.ServiceProcess.ServiceController('$Service',"$ComputerName")).Stop()
(new-Object System.ServiceProcess.ServiceController('$Service',"$ComputerName")).WaitForStatus('Stopped',(new-timespan -seconds 5))
[System.ServiceProcess.ServiceController]::GetServices("$ComputerName")

#Get Service as XML
$xml = Get-Service | where-Object{$_.Name -like 'b*'} | ConvertTo-Xml
$xml.Save("$Env:temp\service.xml")

#Service als HTML Seite
get-service | ConvertTo-Html -Title 'Get-Service' -Body '<H2>The result of get-service</H2> ' -Property Name,Status | foreach {if($_ -like '*<td>Running</td>*'){$_ -replace '<tr>', '<tr bgcolor=green>'}elseif($_ -like '*<td>Stopped</td>*'){$_ -replace '<tr>', '<tr bgcolor=red>'}else{$_}}   > $Env:temp\get-service.html

Start-Process $Env:temp\get-service.html

#Get Devices
[System.ServiceProcess.ServiceController]::GetDevices()
