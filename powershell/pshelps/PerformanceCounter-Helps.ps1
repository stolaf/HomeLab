break

#Hyper-V Perfmon Counter Set
PerfMon (individual 400 mb files)
Create data set:
Logman.exe create counter Perf-Counter-Log -cnf 0 -o "d:\perflogs\%computername%_Perflog.blg" -f bin -v mmddhhmm -max 400 -c "\LogicalDisk(*)\*" "\Memory\*" "\Network Interface(*)\*" "\Paging File(*)\*" "\PhysicalDisk(*)\*" "\Processor(*)\*" "\Process(*)\*" "\Server\*" "\System\*" "\Cluster CSV File System(*)\*" "\Cluster CSV Volume Manager(*)\*" "\Hyper-V Virtual Machine Health Summary \*" "\Hyper-V Hypervisor\* \Processor(_Total)\* \Hyper-V Hypervisor Logical Processor(*)\*" "\Hyper-V Hypervisor Root Virtual Processor (*)\*" "\Hyper-V Hypervisor Virtual Processor (_Total)\*" "\Hyper-V Hypervisor Partition(*)\*" "\Hyper-V Hypervisor Root Partition(*)\*" "\Hyper-V VM Vid Partition(*)\*" "\Hyper-V Virtual Switch(*)\*" "\Hyper-V Legacy Network Adapter(*)\*" "\Hyper-V Virtual Network Adapter(*)\*" "\Hyper-V Virtual Storage Device(*)\*" "\Hyper-V Virtual IDE Controller(*)\*" -si 00:00:01
 
#Start trace:
Logman.exe start Perf-Counter-Log
 
#Stop trace:
Logman.exe stop Perf-Counter-Log
 
#Delete data set:
Logman.exe delete Perf-Counter-Log 

###################################################################################################
typeperf "\Network Interface(HPE Ethernet 10Gb 2-port 530SFP+ Adapter  _84)\Packets Received Discarded"

Invoke-Command -ComputerName $IOPI_PK_HyperVServerNames -ScriptBlock {
   (Get-Counter -Counter "\Network Interface(HPE Ethernet 10Gb 2-port 530SFP+ Adapter*)\Packets Received Discarded" -SampleInterval 1 -MaxSamples 1).Countersamples
} | Sort-Object -Property PSComputerName


#PAL Counter, see psedit "\\fsdebsgv4911\iopi_sources$\PowerShell\Helps\PAL-Helps.ps1"

typeperf -?
typeperf "\\FSDEBSNE0251\Hyper-V HyperVisor Logical Processor(_Total)\% Total Run Time" -si 15
typeperf "\Hyper-V Virtual Network Adapter(FSDEBSY44482*)\bytes/sec" 

typeperf -cf "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PerfCounters.txt" -si 15 -f CSV -o "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PerfValues.csv"
#PerformanceCounter from PAL, alle 15sek, 5760 Samples = 1Tag
typeperf -cf "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PALCounters.txt" -si 15 -f CSV -o "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PALValues_FSDEBSNE0405.csv" -sc 5760 -y

[string[]]$Header = @('DateTime','FSDEBSNE0251','FSDEBSNE0252','FSDEBSNE0253','FSDEBSNE0254','FSDEBSNE0255','FSDEBSNE0256','FSDEBSNE0271','FSDEBSNE0272','FSDEBSNE0273','FSDEBSNE0274','FSDEBSNE0275','FSDEBSNE0276',
  'FSDEBSNE0351','FSDEBSNE0352','FSDEBSNE0353','FSDEBSNE0354','FSDEBSNE0355','FSDEBSNE0356','FSDEBSNE0357','FSDEBSNE0358','FSDEBSNE0359','FSDEBSNE0360',
'FSDEBSNE0371','FSDEBSNE0372','FSDEBSNE0373','FSDEBSNE0374','FSDEBSNE0375','FSDEBSNE0376','FSDEBSNE0377','FSDEBSNE0378','FSDEBSNE0379','FSDEBSNE0380')

$PerfValues = Import-Csv -Path "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PerfValues1.csv" -Delimiter ',' -Header $Header

[string[]]$Header = @('DateTime','\\FSDEBSNE0405\Hyper-V Hypervisor Virtual Processor(_Total)\% Guest Run Time','\\FSDEBSNE0405\Hyper-V Hypervisor Virtual Processor(FSDEBSY44482%)\% Guest Run Time')
$Headers = (Get-Content -Path "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PALValues_FSDEBSNE0405.csv" -TotalCount 1).Split(',') | Where-Object {$_ -Match 'FSDEBSY44482'}
foreach ($Header in $Headers) {
  Import-Csv -Path "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PALValues_FSDEBSNE0405.csv" -Delimiter ',' -Header $Headers[-1]
}
$PerfValues = Import-Csv -Path "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\PALValues_FSDEBSNE0405.csv" -Delimiter ',' -Header $Header

$PerfList = @()
foreach ($PerfValue in $PerfValues) {
  $PerfList += New-Object PSObject -Property ([ordered]@{
      DateTime =  "{0:G}" -f [DateTime]$PerfValue.DateTime
      FSDEBSNE0251 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0251)
      FSDEBSNE0252 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0252)
      FSDEBSNE0253 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0253)
      FSDEBSNE0254 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0254)
      FSDEBSNE0255 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0255)
      FSDEBSNE0256 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0256)
      FSDEBSNE0271 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0271)
      FSDEBSNE0272 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0272)
      FSDEBSNE0273 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0273)
      FSDEBSNE0274 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0274)
      FSDEBSNE0275 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0275)
      FSDEBSNE0276 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0276)
      FSDEBSNE0351 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0351)
      FSDEBSNE0352 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0352)
      FSDEBSNE0353 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0353)
      FSDEBSNE0354 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0354)
      FSDEBSNE0355 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0355)
      FSDEBSNE0356 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0356)
      FSDEBSNE0357 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0357)
      FSDEBSNE0358 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0358)
      FSDEBSNE0359 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0359)
      FSDEBSNE0360 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0360)
      FSDEBSNE0371 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0371)
      FSDEBSNE0372 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0372)
      FSDEBSNE0373 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0373)
      FSDEBSNE0374 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0374)
      FSDEBSNE0375 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0375)
      FSDEBSNE0376 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0376)
      FSDEBSNE0377 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0377)
      FSDEBSNE0378 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0378)
      FSDEBSNE0379 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0379)
      FSDEBSNE0380 = '{0:N1}' -f ([double]$PerfValue.FSDEBSNE0380)
  })
}

$PerfList | Export-Csv -Path '\\fsdebsgv4911\iopi_sources$\Reports\HyperV_Servers\PerfMon\HyperV-PerfValues.csv' -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Append

#Hyper-V Switch Performance Counter
$VMSwitch = Get-VMSwitch -Name 'LS-P-DMZ23_IBA_FW2-BS-DE-NoTeam'  #61f93127-b71c-4e29-94f8-9ac48f43180e 
Get-VMSwitch -Id '61f93127-b71c-4e29-94f8-9ac48f43180e'
$VM = Hyper-V\Get-VM -Name 'FSDEBSY12624'
$VM | Get-VMNetworkAdapter | Select-Object SwitchName,SwitchId,Adapterid #a8a14ca2-0f58-4a8b-b023-c008ab3114d5
$VM.Id   #8837f286-363b-4b44-995d-9d9a7d15408f 
Hyper-V\Get-VM -Id '4c2e07c0-778a-415d-ba1a-08d9cc0d8577'

$CounterSamplesReceived = (Get-Counter -Counter "\Hyper-V Virtual Switch Port($($VMSwitch.Id)*)\Bytes Received/sec" -SampleInterval 1 -MaxSamples 10).Countersamples
$CounterSamplesSent = (Get-Counter -Counter '\Hyper-V Virtual Switch Port(61f93127-b71c-4e29-94f8-9ac48f43180e_8837f286-363b-4b44-995d-9d9a7d15408f)\Bytes Sent/sec' -SampleInterval 1 -MaxSamples 10).Countersamples

$CounterSamplesReceived | Select-Object Timestamp,@{Name='Counter';Expression={$_.Path.Split('\')[-1]}},@{Name='MB/Sek';Expression={($_.CookedValue/1MB).ToString('##.##')}} | Format-Table -AutoSize
$CounterSamplesSent | Select-Object Timestamp,@{Name='Counter';Expression={$_.Path.Split('\')[-1]}},@{Name='MB/Sek';Expression={($_.CookedValue/1MB).ToString('##.##')}} | Format-Table -AutoSize

Get-Counter -Counter '\Hyper-V Virtual Switch Port(61f93127-b71c-4e29-94f8-9ac48f43180e_*)\Bytes Received/sec' | Where-Object Countersamples -like '*a8a14ca2-0f58-4a8b-b023-c008ab3114d5*'
Get-Counter -Counter '\Hyper-V Virtual Switch Processor(*)\Number of VMQs'


Get-Counter -Counter "\Hyper-V Virtual Switch Port($SwitchId*)\Bytes Received/sec" -SampleInterval 1 | Select-Object Timestamp,@{Name='Counter';Expression={$Counter.Path.Split('\')[-1]}},@{Name='MB/Sek';Expression={($_.CookedValue/1MB).ToString('##.##')}} 


(Get-Counter -Counter "\Hyper-V Virtual Switch Port($SwitchId*)\Bytes Received/sec" -SampleInterval 1).CounterSamples | 
Where-Object CookedValue | Select-Object *
# Select-Object Timestamp,@{Name='Counter';Expression={$_.Path.Split('\')[-1]}},@{Name='MB/Sek';Expression={($_.CookedValue/1MB).ToString('##.##')}} 

Get-Counter -Counter "\Hyper-V Virtual Switch Port($($VMSwitch.Id)*)\Bytes Received/sec" -SampleInterval 1


#PipelineVariable was introduced in Windows PowerShell 4.0.
Get-Counter -ListSet 'LogicalDisk','SQLServer:Buffer Manager','SQLServer:Memory Manager' -PipelineVariable CounterCategory | 
Select-Object -ExpandProperty Counter -PipelineVariable CounterName |
Where-Object {$CounterName -match '(sec/Transfer|Avg. Disk Queue Length|Buffer Cache|CheckPoint|Target Server|Total)'} | 
Select-Object   @{E={$CounterCategory.CounterSetName};N='CounterSetName'}, @{E={$CounterCategory.Description};N='Description'}, @{E={$CounterName};N='Counter'}
  
Get-Counter -ListSet 'LogicalDisk' -PipelineVariable CounterCategory | Select-Object -ExpandProperty Counter -PipelineVariable CounterName |
Where-Object {$CounterName -match '(sec/Transfer|Avg. Disk Queue Length|Buffer Cache|CheckPoint|Target Server|Total)'} |
Select-Object   @{E={$CounterCategory.CounterSetName};N='CounterSetName'}, @{E={$CounterCategory.Description};N='Description'}, @{E={$CounterName};N='Counter'}

#number of IIS current client connections
Get-Counter -Counter 'web service(_total)\current connections' -ComputerName server1
#number of connections for a specified website of three front end servers of a SharePoint Farm
Get-Counter -Counter 'web service(sharepoint - myportal80)\current connections' -ComputerName fe1,fe2,fe3

#To find available counters
Get-Counter -ListSet 'Network Adapter' | Select-Object -ExpandProperty PathsWithInstances | Sort-Object
#To view the statistics for a particular card: This records thirty seconds of data by using the default sampling interval
$test = Get-Counter -Counter '\Network Adapter(Qualcomm Atheros AR5007 802.11b_g WiFi Adapter)\Bytes Total/sec' -MaxSamples 30
#To get the total traffic,use Measure-Object. The -Sum property of the output holds the traffic level
$test.CounterSamples | Measure-Object cookedvalue -Sum

get-counter -listset memory
get-counter -listset memory* | Select-Object -ExpandProperty Counter
get-counter -ListSet hyper-v* -ComputerName chi-hvr2.globomantics.local
get-counter -ListSet hyper-v* -ComputerName chi-hvr2.globomantics.local | Select-Object Countersetname
get-counter 'hyper-v virtual machine health summary\*' -ComputerName chi-hvr2.globomantics.local

$bytesread = '\Network Interface(*)\Bytes Received/sec'
$byteswrite = '\Network Interface(*)\Bytes Sent/sec' 
$bytesread | get-counter -maxsamples 10
$byteswrite | get-counter -maxsamples 10
$bytesread | get-counter -maxsamples 10 -ComputerName bwga014a, bwga015a, bwga024a, bwga025a -SampleInterval 60 

Get-Counter '\Network Interface(*)\Bytes Received/sec','\Network Interface(*)\Bytes Sent/sec' -SampleInterval 10
#http://www.altaro.com/hyper-v/hyper-v-performance-counters-and-powershell-part-2/
$hv = 'FSDEBSNE0322.mgmt.fsadm.vwfs-ad'
get-counter -list 'hyper-v dynamic memory vm' -ComputerName $hv

get-counter 'Hyper-v Dynamic Memory VM(FSDEBSY12622)\Guest Visible Physical Memory' -computername $hv
get-counter 'Hyper-v Dynamic Memory VM(*)\Guest Visible Physical Memory' -comp $hv
get-counter 'Hyper-v Dynamic Memory VM(FSDEBSY44471)\*' -computername $hv

get-counter 'Hyper-v Dynamic Memory VM(*)\current pressure' -computername $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,InstanceName,CookedValue,@{Name='Counter';Expression={$_.Path.Split('\')[-1]}}

get-counter 'Hyper-v Dynamic Memory VM(*)\*' -computername $hv |
Select-Object -expandproperty CounterSamples | Select-Object Timestamp,InstanceName,CookedValue,@{Name='Counter';Expression={$_.Path.Split('\')[-1]}} | Sort-Object Counter,InstanceName | Format-Table -GroupBy Counter -Property TimeStamp,InstanceName,CookedValue
get-counter 'Hyper-V Virtual Network Adapter(FSDEBSY12622*)\bytes/sec' -ComputerName $hv -SampleInterval 5 -MaxSamples 2
Start-Job { 
  get-counter 'Hyper-V Virtual Network Adapter(FSDEBSY12622*)\bytes/sec' -ComputerName $hv -SampleInterval 5 -MaxSamples 24 |
  Select-Object -expandproperty CounterSamples | Select-Object Timestamp,CookedValue, @{Name='VM';Expression={ $_.instancename.split('_')[0]}}, @{Name='Counter';Expression={$_.Path.Split('\')[-1]}} | 
  Export-Csv -Path C:\Temp\HVNicPerf1.csv -Delimiter ';' -NoTypeInformation
} -Name NicPerfData

get-counter 'Hyper-V Virtual Network Adapter(FSDEBSY12622*)\bytes/sec' -ComputerName $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,@{Name='CookedValue';Expression={($_.CookedValue/1MB).ToString('##.##')}}, @{Name='VM';Expression={ $_.instancename.split('_')[0]}}, @{Name='Counter';Expression={'MB/sec'}} 
get-counter 'Hyper-V Virtual Network Adapter(FSDEBSY12622*)\Bytes Sent/sec' -ComputerName $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,@{Name='CookedValue';Expression={($_.CookedValue/1MB).ToString('##.##')}}, @{Name='VM';Expression={ $_.instancename.split('_')[0]}}, @{Name='Counter';Expression={'MB/sec'}} 
get-counter 'Hyper-V Virtual Network Adapter(FSDEBSY12622*)\Bytes Received/sec' -ComputerName $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,@{Name='CookedValue';Expression={($_.CookedValue/1MB).ToString('##.##')}}, @{Name='VM';Expression={ $_.instancename.split('_')[0]}}, @{Name='Counter';Expression={'MB/sec'}} 
get-counter 'Hyper-V Virtual Storage Device(*FSDEBSY12622*)\Write Operations/Sec' -ComputerName $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,@{Name='CookedValue';Expression={$_.CookedValue}},@{Name='Counter';Expression={'Write Operations/Sec'}} 
get-counter 'Hyper-V Virtual Storage Device(*FSDEBSY12622*)\Read Operations/Sec'  -ComputerName $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,@{Name='CookedValue';Expression={$_.CookedValue}},@{Name='Counter';Expression={'Read Operations/Sec'}} 
get-counter 'Hyper-V Virtual Storage Device(*FSDEBSY12622*)\Error Count' -ComputerName $hv | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,@{Name='CookedValue';Expression={$_.CookedValue}},@{Name='Counter';Expression={'Read Operations/Sec'}} 

get-counter -list hyper-v* -ComputerName $hv | Select-Object -expand pathsWithInstances | Where-Object {$_ -match 'fsdebsy*'}
get-counter -list hyper-v* -ComputerName $hv | Select-Object -expand pathsWithInstances | Where-Object {$_ -match 'FSDEBSY12622'}
get-counter -list 'hyper-v Virtual Network Adapter*' -ComputerName $hv | Select-Object -expand pathsWithInstances | Where-Object {$_ -match 'FSDEBSY12622'}

$vm='FSDEBSY12622*'
$ctrs="\Hyper-V Dynamic Memory VM($vm)\Physical Memory",
"\Hyper-V Dynamic Memory VM($vm)\Average Pressure",
"\Hyper-V Dynamic Memory VM($vm)\Current Pressure",
"\Hyper-V Dynamic Memory VM($vm)\Smart Paging Working Set Size",
"\Hyper-V Virtual Network Adapter($vm*)\bytes/sec",
"\Hyper-V Virtual Network Adapter($vm*)\packets/sec"
$data = get-counter -Counter $ctrs -ComputerName $hv -SampleInterval 10 -MaxSamples 12
$results = $data | Select-Object -expandproperty CounterSamples | Select-Object Timestamp,InstanceName,CookedValue,@{Name='Counterset';Expression={$_.Path.Split('\')[4]}},@{Name='Counter';Expression={$_.Path.Split('\')[5]}}
$results | out-gridview

#Exchange
#Bevor man einen Exchange-Server neu startet oder vom Netz nimmt, macht es Sinn, vorher zu prüfen, wie viel Benutzer auf dem Server aktiv sind.
get-counter '\MSExchange OWA\Aktuelle eindeutige Benutzer' 
get-counter '\MSExchange RpcClientAccess\Anzahl Benutzer'
get-counter '\MSExchange OWA\Current Unique Users' 
get-counter 'MSExchange RpcClientAccess\User Count'
(get-counter -ListSet 'MSExchange OWA').Counter
#Wer nun wissen will, welche Performance Counter den Eintrag "Benutzer" kennen, der verwendet diesen Befehl:
get-counter -ListSet MSExchange* | Select-Object -ExpandProperty Counter | Where-Object {$_ -match 'benutzer'}

http://www.powershellmagazine.com/2013/07/19/querying-performance-counters-from-powershell/
Get-Counter -ListSet * | Select-Object -ExpandProperty Counter
Get-Counter -ListSet *processor* | Select-Object -ExpandProperty Counter

# Sample interval 3 seconds
$load = (Get-Counter '\Processor(_total)\% Processor Time' -SampleInterval 3).CounterSamples.CookedValue
"Average CPU load in the past 3 seconds was $load%"
function Get-PerformanceCounterLocalName {
  param
  (
    [UInt32]
    $ID,
    $ComputerName = $env:COMPUTERNAME
  )
  
  $code = '[DllImport("pdh.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern UInt32 PdhLookupPerfNameByIndex(string szMachineName, uint dwNameIndex, System.Text.StringBuilder szNameBuffer, ref uint pcchNameBufferSize);'
  
  $Buffer = New-Object System.Text.StringBuilder(1024)
  [UInt32]$BufferSize = $Buffer.Capacity
  
  $t = Add-Type -MemberDefinition $code -PassThru -Name PerfCounter -Namespace Utility
  $rv = $t::PdhLookupPerfNameByIndex($ComputerName, $id, $Buffer, [Ref]$BufferSize)
  
  if ($rv -eq 0) {
    $Buffer.ToString().Substring(0, $BufferSize-1)
  } else {
    Throw 'Get-PerformanceCounterLocalName : Unable to retrieve localized name. Check computer name and performance counter ID.'
  }
}

$processor = Get-PerformanceCounterLocalName 238
$percentProcessorTime = Get-PerformanceCounterLocalName 6

get-counter -list hyper-v*  | Select CountersetName,Description
get-counter -list 'Hyper-V Hypervisor Virtual Processor'  | Select -ExpandProperty Counter

$ComputerName = @('FSDEBSNE0231.mgmt.fsadm.vwfs-ad','FSDEBSNE0232.mgmt.fsadm.vwfs-ad','FSDEBSNE0233.mgmt.fsadm.vwfs-ad','FSDEBSNE0234.mgmt.fsadm.vwfs-ad','FSDEBSNE0241.mgmt.fsadm.vwfs-ad','FSDEBSNE0242.mgmt.fsadm.vwfs-ad','FSDEBSNE0243.mgmt.fsadm.vwfs-ad','FSDEBSNE0244.mgmt.fsadm.vwfs-ad','FSDEBSNE0331.mgmt.fsadm.vwfs-ad','FSDEBSNE0332.mgmt.fsadm.vwfs-ad','FSDEBSNE0333.mgmt.fsadm.vwfs-ad','FSDEBSNE0334.mgmt.fsadm.vwfs-ad','FSDEBSNE0341.mgmt.fsadm.vwfs-ad','FSDEBSNE0342.mgmt.fsadm.vwfs-ad','FSDEBSNE0343.mgmt.fsadm.vwfs-ad','FSDEBSNE0344.mgmt.fsadm.vwfs-ad')

$Counters = (Get-Counter '\Hyper-V  Hypervisor Virtual Processor(FS*)\% Total Run Time' -SampleInterval 10 -MaxSamples 1).CounterSamples | Select @{l='VMName';e={($_.InstanceName -replace ':hv vp [0-9]{1,}$','')}},TimeStamp,CookedValue
$Counters = (Get-Counter -ComputerName 'FSDEBSNE0231.mgmt.fsadm.vwfs-ad' -Counter '\Hyper-V Hypervisor Virtual Processor(*)\% Guest Run Time' -SampleInterval 10 -MaxSamples 6).CounterSamples | Select @{l='VMName';e={($_.InstanceName -replace ':hv vp [0-9]{1,}$','')}},TimeStamp,CookedValue
$CounterList = @()
for ($x=0; $x -le 5; $x++) {
  $x
  $Counters = (Get-Counter '\Hyper-V Hypervisor Virtual Processor(fs*)\% Hypervisor Run Time' -SampleInterval 60 -MaxSamples 1).CounterSamples | Select @{l='VMName';e={($_.InstanceName -replace ':hv vp [0-9]{1,}$','')}},TimeStamp,CookedValue
  foreach ($GroupCounter in ($Counters | Group-Object -Property VMName)) {
    $CounterList += New-Object PSObject -Property ([ordered]@{Counter='%HypervisorRunTime';VMName=$GroupCounter.Name;ProcessorCount=$GroupCounter.Count;Timestamp=$GroupCounter.Group[0].Timestamp;TotalHypervisorRunTime='{0:N2}' -f (($GroupCounter.Group | Measure-Object -Property CookedValue -Sum).Sum)})
  }
}
$CounterList | ft -AutoSize

#https://docs.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/detecting-virtualized-environment-bottlenecks

\Hyper-V Hypervisor Logical Processor(_Total)\% Total Runtime      #counter is over 90%, the host is overloaded. You should add more processing power or move some virtual machines to a different host.
\Hyper-V Hypervisor Virtual Processor(FSDEBSY44482:VP x)\% Total Runtime  #counter is over 90% for all virtual processors, you should do the following:Verify that the host is not overloaded,Find out if the workload can leverage more virtual processors,Assign more virtual processors to the virtual machine
\Hyper-V Hypervisor Virtual Processor(FSDEBSY44482:VP x)\% Total Runtime  #ounter is over 90% for some, but not all, of the virtual processors, you should do the following:If your workload is receive network-intensive, you should consider using vRSS.If your workload is storage-intensive, you should enable virtual NUMA and add more virtual disks.



\Hyper-V Hypervisor Root Virtual Processor (Root VP x)\% Total Runtime

\Hyper-V Hypervisor Virtual Processor(*)\% Remote Run Time
\Hyper-V Hypervisor Virtual Processor(*)\Total Intercepts Cost
\Hyper-V Hypervisor Virtual Processor(*)\Total Intercepts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Total Messages/sec
\Hyper-V Hypervisor Virtual Processor(*)\% Guest Run Time
\Hyper-V Hypervisor Virtual Processor(*)\% Hypervisor Run Time
\Hyper-V Hypervisor Virtual Processor(*)\% Total Run Time
\Hyper-V Hypervisor Virtual Processor(*)\CPU Wait Time Per Dispatch
\Hyper-V Hypervisor Virtual Processor(*)\Logical Processor Dispatches/sec
\Hyper-V Hypervisor Virtual Processor(*)\Nested Page Fault Intercepts Cost
\Hyper-V Hypervisor Virtual Processor(*)\Nested Page Fault Intercepts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Hardware Interrupts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Virtual Processor Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\Virtual MMU Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\Virtual Interrupt Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\Synthetic Interrupt Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\Other Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\Long Spin Wait Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\Logical Processor Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\GPA Space Hypercalls/sec
\Hyper-V Hypervisor Virtual Processor(*)\APIC Self IPIs Sent/sec
\Hyper-V Hypervisor Virtual Processor(*)\APIC IPIs Sent/sec
\Hyper-V Hypervisor Virtual Processor(*)\Virtual Interrupts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Synthetic Interrupts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Table Write Intercepts/sec
\Hyper-V Hypervisor Virtual Processor(*)\APIC TPR Accesses/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Table Validations/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Table Resets/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Table Reclamations/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Table Evictions/sec
\Hyper-V Hypervisor Virtual Processor(*)\Local Flushed GVA Ranges/sec
\Hyper-V Hypervisor Virtual Processor(*)\Global GVA Range Flushes/sec
\Hyper-V Hypervisor Virtual Processor(*)\Address Space Flushes/sec
\Hyper-V Hypervisor Virtual Processor(*)\Address Domain Flushes/sec
\Hyper-V Hypervisor Virtual Processor(*)\Address Space Switches/sec
\Hyper-V Hypervisor Virtual Processor(*)\Address Space Evictions/sec
\Hyper-V Hypervisor Virtual Processor(*)\Logical Processor Migrations/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Table Allocations/sec
\Hyper-V Hypervisor Virtual Processor(*)\Other Messages/sec
\Hyper-V Hypervisor Virtual Processor(*)\APIC EOI Accesses/sec
\Hyper-V Hypervisor Virtual Processor(*)\Memory Intercept Messages/sec
\Hyper-V Hypervisor Virtual Processor(*)\IO Intercept Messages/sec
\Hyper-V Hypervisor Virtual Processor(*)\APIC MMIO Accesses/sec
\Hyper-V Hypervisor Virtual Processor(*)\Reflected Guest Page Faults/sec
\Hyper-V Hypervisor Virtual Processor(*)\Small Page TLB Fills/sec
\Hyper-V Hypervisor Virtual Processor(*)\Large Page TLB Fills/sec
\Hyper-V Hypervisor Virtual Processor(*)\Guest Page Table Maps/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Fault Intercepts Cost
\Hyper-V Hypervisor Virtual Processor(*)\Page Fault Intercepts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Debug Register Accesses Cost
\Hyper-V Hypervisor Virtual Processor(*)\Debug Register Accesses/sec
\Hyper-V Hypervisor Virtual Processor(*)\Emulated Instructions Cost
\Hyper-V Hypervisor Virtual Processor(*)\Emulated Instructions/sec
\Hyper-V Hypervisor Virtual Processor(*)\Pending Interrupts Cost
\Hyper-V Hypervisor Virtual Processor(*)\Pending Interrupts/sec
\Hyper-V Hypervisor Virtual Processor(*)\External Interrupts Cost
\Hyper-V Hypervisor Virtual Processor(*)\External Interrupts/sec
\Hyper-V Hypervisor Virtual Processor(*)\Other Intercepts Cost
\Hyper-V Hypervisor Virtual Processor(*)\Other Intercepts/sec
\Hyper-V Hypervisor Virtual Processor(*)\MSR Accesses Cost
\Hyper-V Hypervisor Virtual Processor(*)\MSR Accesses/sec
\Hyper-V Hypervisor Virtual Processor(*)\CPUID Instructions Cost
\Hyper-V Hypervisor Virtual Processor(*)\CPUID Instructions/sec
\Hyper-V Hypervisor Virtual Processor(*)\MWAIT Instructions Cost
\Hyper-V Hypervisor Virtual Processor(*)\MWAIT Instructions/sec
\Hyper-V Hypervisor Virtual Processor(*)\HLT Instructions Cost
\Hyper-V Hypervisor Virtual Processor(*)\HLT Instructions/sec
\Hyper-V Hypervisor Virtual Processor(*)\IO Instructions Cost
\Hyper-V Hypervisor Virtual Processor(*)\IO Instructions/sec
\Hyper-V Hypervisor Virtual Processor(*)\Control Register Accesses Cost
\Hyper-V Hypervisor Virtual Processor(*)\Control Register Accesses/sec
\Hyper-V Hypervisor Virtual Processor(*)\Page Invalidations Cost
\Hyper-V Hypervisor Virtual Processor(*)\Page Invalidations/sec
\Hyper-V Hypervisor Virtual Processor(*)\Hypercalls Cost
\Hyper-V Hypervisor Virtual Processor(*)\Hypercalls/sec
