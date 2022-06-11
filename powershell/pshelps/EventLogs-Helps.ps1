break

#https://4sysops.com/archives/search-the-event-log-with-the-get-winevent-powershell-cmdlet/
Get-WinEvent -ListLog *
Get-WinEvent -ListLog *powershell*
Get-WinEvent -LogName 'System'
Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational'
Get-WinEvent -LogName 'System' | Out-Host -Paging  #only console, not for ISE
Get-WinEvent -LogName 'System' -MaxEvents 20
Get-WinEvent -FilterHashTable @{LogName='System'}
Get-WinEvent -FilterHashTable @{LogName='System';ID='1020'}
Get-WinEvent -FilterHashTable @{LogName='System';ID='1','42'}
Get-WinEvent -FilterHashTable @{LogName='System';Level='2'}   # Level: LogAlways 0, Critical 1, Error 2, Warning 3, Informational 4, Verbose 5
Get-WinEvent -FilterHashtable @{LogName='system'} | Where-Object -FilterScript {($_.Level -eq 2) -or ($_.Level -eq 3)}
#Audit success or audit failure security events. Failure Audit = 4503599627370496; Success audit = 9007199254740992
Get-WinEvent -FilterHashtable @{LogName='Security';Keywords='4503599627370496'}
Get-WinEvent -FilterHashtable @{LogName='System'} | Where-Object -Property Message -Match 'the system has resumed'
$StartTime=Get-Date -Year 2017 -Month 1 -Day 1 -Hour 15 -Minute 30
$EndTime=Get-Date -Year 2017 -Month 2 -Day 15 -Hour 20 -Minute 00
Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$StartTime;EndTime=$EndTime}
Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$StartDate;Level='2';ID='10010'} -MaxEvents 5
Get-WinEvent -LogName System -MaxEvents 5 | Format-List
Get-WinEvent -FilterHashtable @{LogName='Security';Keywords='4503599627370496'} | Format-Table -Property RecordId,TimeCreated,ID,LevelDisplayName,Message
Get-WinEvent -FilterHashtable @{LogName='Security'} | Where-Object ‑Property RecordId -eq 810

#Finding Registered Event Sources
#Each Windows log file has a list of registered event sources. To find out which event sources are registered to which event log, you can directly query the Windows Registry.
#This will dump all registered sources for the 'System' event log:
$LogName = 'System'
$path = "HKLM:\System\CurrentControlSet\services\eventlog\$LogName"
Get-ChildItem -Path $path -Name 

Invoke-Command -ComputerName $ComputerName -Authentication Credssp -Credential $myAdminCredential -ScriptBlock {
 # wevtutil.exe export-log System "\\fsdebsgv4911\iopi_sources$\SupportCases\Hyper-V\Cluster\FSDEBSHE0370\EventLogs\%ComputerName%_System.evtx" /ow:true
#  wevtutil.exe export-log Application "\\fsdebsgv4911\iopi_sources$\SupportCases\Hyper-V\Cluster\FSDEBSHE0370\EventLogs\%ComputerName%_Application.evtx" /ow:true
  wevtutil.exe export-log "Microsoft-Windows-WMI-Activity/Operational" "\\fsdebsgv4911\iopi_sources$\SupportCases\Hyper-V\Cluster\FSDEBSHE0370\EventLogs\%ComputerName%_WMI.evtx" /ow:true
}

 
Get-EventLog -LogName System -EntryType Error -Newest 40 | Sort-Object -Property InstanceID, Message -Unique | Sort-Object -Property TimeWritten -Descending | Out-GridView
[System.Diagnostics.EventLog]::Exists('Application')
[System.Diagnostics.EventLog]::SourceExists('dcom')

Limit-EventLog -LogName System -MaximumSize (32MB) -OverflowAction OverwriteAsNeeded
Limit-EventLog -LogName Application -MaximumSize (32MB) -OverflowAction OverwriteAsNeeded
Limit-EventLog -LogName Security -MaximumSize (32MB) -OverflowAction OverwriteAsNeeded

wevtutil.exe sl 'Microsoft-Windows-WMI-Activity/Operational' /ms:33554432  #32MB Logsize
Show-EventLog

Clear-EventLog -LogName (Get-EventLog -List).log -WhatIf

Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
  $ID = 16949,16950
  Get-WinEvent -FilterHashtable @{logname='System'; id= $ID} -ErrorAction SilentlyContinue | Select-Object LogName,Message, Id, ProviderName,TimeCreated
} | Select-Object * -ExcludeProperty RunSpaceID | ft -AutoSize

Invoke-Command -ComputerName $IOPI_PK_All_HyperVServerNames -ScriptBlock { 
  $StartTime =[datetime]'03/07/2017 21:40'  #Month,Day,Year
  $EndTime = [datetime]'03/07/2017 21:59'
  Get-WinEvent -FilterHashtable @{logname='Microsoft-Windows-WMI-Activity/Operational';StartTime=$StartTime;EndTime=$EndTime} -ErrorAction SilentlyContinue | Select-Object LogName,Message, Id, ProviderName,TimeCreated
} | Select-Object * -ExcludeProperty RunSpaceID | ft -AutoSize

function Get-LogonFailure {
  param($ComputerName = $Env:COMPUTERNAME)
  try {
    Get-EventLog -ComputerName $ComputerName -LogName security -EntryType FailureAudit -InstanceId 4625 -ErrorAction Stop @PSBoundParameters |
    ForEach-Object {
      $user, $domain = $_.ReplacementStrings[5,6]
      $time = $_.TimeGenerated
      "Logon Failure: $domain\$user at $time"
    }
  } catch  {
    if ($_.CategoryInfo.Category -eq 'ObjectNotFound') {Write-Host 'No logon failures found.' -ForegroundColor Green} Else {Write-Warning "Error occured: $_"}
  }
}

#Backup Eventlog
$computers = 'cs-dc1','cs-dc2','cs-vmm','cs-svr1'
$logname = 'System'
$logs = Get-CimInstance win32_nteventlogfile -filter "logfilename = '$logname'" -ComputerName $computers
foreach ($log in $logs) {
  $file = '{0}_{1}_{2}.evtx' -f (Get-Date -f 'yyyyMMddhhmm'),$log.PSComputerName,$log.FileName.Replace(' ','')
  $backup = join-path 'c:\backup' $file
  $log | Invoke-CimMethod -Name BackupEventlog -Arguments @{ArchiveFileName=$backup}
}
$user = $myDomainAdminCredential.UserName; $pass = $myDomainAdminCredential.GetNetworkCredential().Password
invoke-command {net.exe use \\CS-HOST1\ipc$ /user:$Using:user $using:pass; Get-ChildItem c:\backup\*.evtx | move-item -Destination \\chi-fp01\it -Force -PassThru} -ComputerName $computers

clear-eventlog 'windows powershell','system','application' -comp $computers
    
Get-WinEvent -ComputerName rz-dc1 -FilterHashtable @{logname='security'; id=4757} | Where-Object { $_.message -like '*Matthew L*' -and $_.message -like '*secure-users*'}
iexplore.exe 'http://www.pavleck.net/powershell-cookbook/ch23.html'

# Bug in Powershell 3: Messages werden nicht ausgegeben
Start-Process powershell.exe -ArgumentList '-Version 2'  
$ServerNames = @('fsdebsne0111.mgmt.fsadm.vwfs-ad','fsdebsne0112.mgmt.fsadm.vwfs-ad','fsdebsne0121.mgmt.fsadm.vwfs-ad','fsdebsne0122.mgmt.fsadm.vwfs-ad','fsdebsne0131.mgmt.fsadm.vwfs-ad','fsdebsne0132.mgmt.fsadm.vwfs-ad','fsdebsne0141.mgmt.fsadm.vwfs-ad','fsdebsne0142.mgmt.fsadm.vwfs-ad')
$date = (get-date).AddDays(-5)
foreach ($ServerName in $ServerNames) {
  Get-WinEvent -ComputerName $ServerName -FilterHashTable @{logname='Microsoft-Windows-Hyper-V-Worker-Admin'; StartTime=$date; ID=18590 } -ErrorAction SilentlyContinue | Select-Object machineName,Id,Level,TimeCreated,Message
}

Get-EventLog Security | Group-Object EventID | Sort-Object Count -descending | Select-Object Count, Name | Format-Table -autosize
Get-WinEvent -LogName 'System' -FilterXPath '*[System/Execution[@ProcessID=428]]'
Get-EventLog -list
Get-Eventlog Application
Get-Eventlog Application -Newest 10
Get-EventLog -list | ForEach-Object { Get-EventLog $_.Log -newest 10 }
Get-EventLog Application -newest 1 | Format-List *
Get-EventLog Application | Where-Object { $_.eventID -eq 1033}
Get-WmiObject Win32_NTLogEvent -filter 'EventCode=1033 and Logfile="Application"'
Get-EventLog Application | Where-Object { $_.Source -eq 'Outlook' }
Get-Eventlog Application | Where-Object { $_.EntryType -eq 'error' }

Get-EventLog Application | Out-File $home\applog.txt; & "$home\applog.txt"
Get-Eventlog Application | Export-CliXML $home\applog.xml -Depth 2

New-EventLog -LogName LogonScripts -Source ClientScripts
Start-Process eventvwr.msc /computer=$Args
Write-EventLog LogonScripts -Source ClientScripts -Message 'Test Message' -EventId 1234 -EntryType Warning

#find System restore Points
Get-EventLog -LogName application -InstanceId 8194 |ForEach-Object {$i=1 |Select-Object Event,Application;$i.Event, $i.Application = $_.ReplacementStrings[1,0]; $i}

#And this will list the command lines that actually ran after creating the restore points:
Get-EventLog -LogName application -InstanceId 8194 | ForEach-Object {$i=1|Select-Object Event,Application; $i.Event, $i.Application = $_.ReplacementStrings[1,0]; $i} | Group-Object Application | Select-Object -ExpandProperty Name

#Save EventLogfile
#WMI provides a method to backup event log files as *.evt/*.evtx files. The code below creates backups of all available event logs: 
#By the way, you can read in the *.evt/*.evtx files created by this approach using Get-WinEvent -Path.
Get-WmiObject Win32_NTEventLogFile | `
ForEach-Object { 	
  $filename = "$home\" + $_.LogfileName + '.evtx'	
  Remove-Item $filename -ErrorAction SilentlyContinue	
  $_.BackupEventLog($filename).ReturnValue
}
	
#eventtriggers /create 
Get-WinEvent -ComputerName 'fsdebsne0303.mgmt.fsadm.vwfs-ad' -ListLog Microsoft-Windows-Hyper-V* | Select-Object -ExpandProperty LogName | % {
  wevtutil.exe export-log $_ "c:\temp\$_.evtx" /r:'fsdebsne0303.mgmt.fsadm.vwfs-ad' /ow:true
}

#List EventSource
(Get-WmiObject Win32_NTEventLogFile -Filter 'logfilename="application"').Sources

#Load EventLogFile
#if customers send in dumped event log files, there is an easy way to open them in PowerShell and analyze content: 
#Get-WinEvent! The -Path parameter will allow you to read in those binary dumps and display the content as an object.

#You should use this line to load c:\sample.evt and display message, source and time just for error events as Excel spread sheet:

#funktioniert erst ab Vista!
Get-WinEvent -Path c:\temp\app.evt | Where-Object { $_.Level -eq 2 } | 
Select-Object Message, TimeCreated, ProviderName, TimeCreated | 
Export-CSV $env:temp\list.csv -useCulture -Encoding UTF8 -NoTypeInformation; Invoke-Item $env:temp\list.csv

## Gets all Critical and Error events from the last 24 hours
$xml = @'
    <QueryList>
      <Query Id="0" Path="System">
        <Select Path="System">
            *[System[(Level=1  or Level=2) and
                TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]
        </Select>
      </Query>
    </QueryList>
'@
Get-WinEvent -FilterXml $xml

#Clear EventLog
Get-WinEvent Microsoft-Windows-WinRM/Operational

#There is no cmdlet to actually clear such event log, though. With this line, you can:
#Of course, you need Admin privileges to clear most event logs.

[System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog(' Microsoft-Windows-WinRM/Operational')

#Get Event from Yesterday
#Retrieve Yesterday's Error Events
#To retrieve all error events from a system log that occurred yesterday, here is how to calculate the start and stop times:

$end = Get-Date -Hour 0 -Minute 0 -Second 0
$start = $end.AddDays(-1)

Get-EventLog -LogName System -EntryType Error -Before $end -After $start
Get-EventLog System -Source Microsoft-Windows-Winlogon

#Get Reboots
$startUpID = 6005   #or 1074
$shutDownID = 6006
$numberOfDays = 10
$startingDate = (Get-Date -Hour 00 -Minute 00 -Second 00).adddays(-$numberOfDays)
Get-EventLog -LogName system -ComputerName 'fsdebsne0313.mgmt.fsadm.vwfs-ad' -source eventlog  | Where-Object {$_.eventID -eq  $startUpID -or $_.eventID -eq $shutDownID -and $_.TimeGenerated -ge $startingDate}

#Get BlueScreens
$EventID = 1001
$numberOfDays = 10
$startingDate = (Get-Date -Hour 00 -Minute 00 -Second 00).adddays(-$numberOfDays)
Get-EventLog -LogName system -ComputerName 'fsdebsne0314.mgmt.fsadm.vwfs-ad' -source BugCheck  | Where-Object {$_.eventID -eq $EventID -and $_.TimeGenerated -ge $startingDate}

#Get PowerOffs
Get-WinEvent -FilterHashtable @{logname='System'; id=6005}  |
ForEach-Object {
  $rv = New-Object PSObject | Select-Object Date, User, Action, process, Reason, ReasonCode, Comment
  $rv.Date = $_.TimeCreated
  $rv.User = $_.Properties[6].Value
  $rv.Process = $_.Properties[0].Value
  $rv.Action = $_.Properties[4].Value
  $rv.Reason = $_.Properties[2].Value
  $rv.ReasonCode = $_.Properties[3].Value
  $rv.Comment = $_.Properties[5].Value
  $rv
} | Select-Object Date, Action, Reason, User
