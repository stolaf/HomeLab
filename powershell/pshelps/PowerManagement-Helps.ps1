Get-WmiObject -Namespace root\cimv2\power -Class win32_PowerPlan | Select-Object -Property ElementName, IsActive |Format-Table -Property * -AutoSize
Get-CimInstance -N root\cimv2\power -Class win32_PowerPlan | Select-Object ElementName, IsActive | Format-Table -a
Get-WmiObject -NS root\cimv2\power -Class win32_PowerPlan -Filter "IsActive = 'true'"

$p = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Energiesparmodus'"          
Invoke-CimMethod -InputObject $p -MethodName Activate

Add-Type -Assembly System.Windows.Forms
[System.Windows.Forms.SystemInformation]::PowerStatus

#Invoke Standby
&"$env:SystemRoot\System32\rundll32.exe" powrprof.dll,SetSuspendState Standby  #oder
Add-Type -AssemblyName System.Windows.Forms
$null = [System.Windows.Forms.Application]::SetSuspendState(0,0,0)

#Invoke Hibernate
&"$env:SystemRoot\System32\rundll32.exe" powrprof.dll,SetSuspendState 0,1,0

#Get ActiveScheme
((powercfg.exe -GETACTIVESCHEME) -match '(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}' ) | Select-Object *
$PowerActiveScheme = $matches[0]
powercfg.exe -query $PowerActiveScheme

#get Batteriestatus
(Get-WmiObject BatteryStatus -Namespace root\wmi).PowerOnline

#Get Reboots
[xml]$Startup_xml=@'
  <QueryList>
  <Query Id="0" Path="System">
  <Select Path="System">*[System[(EventID=6005)]]</Select>
  </Query>
  </QueryList>
'@

[xml]$ShutDown_xml=@'
  <QueryList>
  <Query Id="0" Path="System">
  <Select Path="System">*[System[(EventID=6006)]]</Select>
  </Query>
  </QueryList>
'@

Get-WinEvent -FilterXml $Startup_xml -MaxEvents 5
Get-WinEvent -FilterXml $ShutDown_xml -MaxEvents 5  #-ComputerName Server01,Server02
