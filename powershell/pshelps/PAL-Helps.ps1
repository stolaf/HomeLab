break

https://github.com/clinthuffman/PAL
# Auswertungen auf dem FSDEBSY44409
# https://www.hyper-v-server.de/management/langzeit-performanceanalyse-von-hyper-v-hosts-und-grafische-auswertung-mit-pal/

#Hyper-V
Set-Location -Path "C:\Users\zz_acuser\Desktop\PAL_FlatFiles_2.7.7_x64"
$LogFileName = "D:\PerfCounters\Microsoft Windows Server 2012 Hyper-V\FSDEBSNE0405_20180620-000004\PAL_Microsoft_Windows_Server_2012_Hyper-V.blg"
.\PAL.ps1 -Log $LogFileName  `
-ThresholdFile "C:\Users\zz_acuser\Desktop\PAL_FlatFiles_2.7.7_x64\HyperV30.xml" `
-Interval "AUTO" -IsOutputHtml $True -IsOutputXml $False -AllCounterStats $False -NumberOfThreads 16 -IsLowPriority $False `
-HtmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].htm" `
-XmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].xml"

Set-Location -Path "C:\Users\zz_acuser\Desktop\PAL_FlatFiles_2.7.7_x64"
.\PAL.ps1 -Log "C:\Users\zz_acuser\Desktop\PAL_Microsoft_Windows_Server_2012_Hyper-V_FSDEBSNE0156.blg" `
-ThresholdFile "C:\Users\zz_acuser\Desktop\PAL_FlatFiles_2.7.7_x64\HyperV30.xml" `
-Interval "AUTO" -IsOutputHtml $True -IsOutputXml $False -AllCounterStats $False -NumberOfThreads 16 -IsLowPriority $False `
-HtmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].htm" `
-XmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].xml"

#System Overview
Set-Location -Path "C:\Program Files\PAL\PAL"
$LogFileName = "C:\Users\dkx8zb8adm\Desktop\PAL_Quick_System_Overview.blg"
.\PAL.ps1 -Log $LogFileName  `
-ThresholdFile "C:\Users\zz_acuser\Desktop\PAL_FlatFiles_2.7.7_x64\SystemOverview.xml" `
-Interval "AUTO" -IsOutputHtml $True -IsOutputXml $False -AllCounterStats $False -NumberOfThreads 16 -IsLowPriority $False `
-HtmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].htm" `
-XmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].xml"


##########################################
Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture, Caption
Get-WmiObject Win32_ComputerSystem | ForEach-Object {$_.TotalPhysicalMemory /1GB}

Set-Location -Path 'D:\Logging\PAL_FlatFiles_2.7.7_x64'
Powershell -ExecutionPolicy ByPass -NoProfile -File ".\PAL.ps1" -Log "D:\Logging\Hyper-V.blg" `
-ThresholdFile "D:\Logging\PAL_FlatFiles_2.7.7_x64\HyperV30.xml" -Interval "86400" -IsOutputHtml $True -HtmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].htm" `
-IsOutputXml $False -XmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].xml" `
-AllCounterStats $False -NumberOfThreads 16 -IsLowPriority $True -OS "Microsoft Windows Server 2012 R2 Datacenter"  -PhysicalMemory "1024" -UserVa "2048"


D:
cd "D:\Logging\PAL_FlatFiles_2.7.7_x64"
start /LOW /WAIT Powershell -ExecutionPolicy ByPass -NoProfile -File ".\PAL.ps1" -Log "" -ThresholdFile "D:\Logging\PAL_FlatFiles_2.7.7_x64\HyperV30.xml" -Interval "86400" -IsOutputHtml $True -HtmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].htm" -IsOutputXml $False -XmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].xml" -AllCounterStats $False -NumberOfThreads 16 -IsLowPriority $True -OS "64-bit Windows Server 2012" -PhysicalMemory "1024" -UserVa "2048"


Powershell -ExecutionPolicy ByPass -NoProfile -File ".\PAL.ps1"
-Log ""
-ThresholdFile "D:\Logging\PAL_FlatFiles_2.7.7_x64\HyperV30.xml"
-Interval "AUTO"
-IsOutputHtml $True
-HtmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].htm"
-IsOutputXml $False
-XmlOutputFileName "[LogFileName]_PAL_ANALYSIS_[DateTimeStamp].xml"
-AllCounterStats $False
-NumberOfThreads 16
-IsLowPriority $True
-OS "64-bit Windows Server 2012"
-PhysicalMemory "1024"
-UserVa "2048"

#PAL Counter
$Counters = [Xml.XmlDocument](Get-Content "C:\Users\DKX8ZB8ADM\Desktop\HyperV30.xml" -Raw)
$HV_Counters = $Counters.PAL.ANALYSIS.DATASOURCE | Select-Object -ExpandProperty Name

'\Hyper-V Hypervisor Virtual Processor(*)\% Guest Run Time',
'\Hyper-V Hypervisor Logical Processor(*)\% Total Run Time',
'\Hyper-V Virtual Network Adapter(*)\Bytes/sec',
'\Hyper-V Virtual Switch(*)\Bytes/sec',
'\Hyper-V Virtual Storage Device(*)\Read Bytes/sec',
'\Hyper-V Virtual Storage Device(*)\Write Bytes/sec',
'\Hyper-V Virtual Storage Device(*)\Error Count',
'\Hyper-V Virtual Machine Health Summary\Health Critical',
'\Hyper-V Hypervisor\Logical Processors',
'\Hyper-V Hypervisor\Virtual Processors',
'\Hyper-V Hypervisor Root Partition(*)\Deposited Pages',
'\Hyper-V VM Vid Partition(*)\Remote Physical Pages',
'\Hyper-V Virtual Storage Device(*)\Error Count',
'\Hyper-V Virtual Storage Device(*)\Read Bytes/sec',
'\Hyper-V Virtual Storage Device(*)\Write Bytes/sec',
'\Hyper-V VM Vid Numa Node(*)\ProcessorCount',
'\Hyper-V VM Vid Partition(*)\Preferred NUMA Node Index',
'\Hyper-V Hypervisor Root Virtual Processor(*)\Hypercalls Cost',
'\Hyper-V Hypervisor Root Virtual Processor(*)\IO Instructions Cost',
'\Hyper-V Hypervisor Partition(*)\Virtual TLB Flush Entires/sec',
'\Hyper-V Dynamic Memory VM(*)\Added Memory',
'\Hyper-V Dynamic Memory VM(*)\Average Pressure',
'\Hyper-V Dynamic Memory VM(*)\Removed Memory',
'\Hyper-V Dynamic Memory Balancer(*)\Average Pressure',
'\Hyper-V Hypervisor Root Partition(*)\Address Spaces',
'\Hyper-V Hypervisor Logical Processor(*)\Context Switches/sec',
'\Hyper-V Dynamic Memory VM(*)\Guest Visible Physical Memory',
'\Hyper-V Dynamic Memory VM(*)\Smart Paging Working Set Size',
'\Hyper-V Virtual Switch Processor(*)\Number of VMQs',
'\Hyper-V Virtual Machine Bus\Throttle Events',
'\Hyper-V Legacy Network Adapter(*)\Frames Dropped',
'\Hyper-V Legacy Network Adapter(*)\Bytes Dropped',
'\Hyper-V Replica VM\Compression Efficiency',
'\LogicalDisk(*)\Disk Transfers/sec',
'\PhysicalDisk(*)\Disk Transfers/sec',
'\NUMA Node Memory(*)\Available MBytes',
'\Cluster CSV Volume Cache(*)\Cache Size - Configured',
'\Cluster CSV Volume Cache(*)\Cache Size - Current',
'\Cluster CSV Volume Cache(*)\Cache IO Read - Bytes/sec',
'\Cluster CSV Volume Cache(*)\Disk IO Read - Bytes/Sec',
'\Cluster CSV File System(*)\Redirected Read Bytes/sec',
'\Cluster CSV File System(*)\Redirected Write Bytes/sec',
'\Cluster CSV Volume Cache\Cache State',
'\Cluster CSV File System\Volume State',
'\Cluster CSV Block Redirection\IO Reads/sec',
'\Cluster CSV Volume Manager\Direct IO Failure Redirection/sec',
'\Cluster CSV Block Redirection\IO Writes/sec',
'\Cluster Resource Control Manager\RHS Restarts'

'\Cluster NetFt Heartbeats\Missing heartbeats',
'\RDMA Activity(*)\RDMA Completion Queue Errors',
'\RDMA Activity(*)\RDMA Connection Errors',
'\RDMA Activity(*)\RDMA Failed Connection Attempts',
'\RemoteFX Network(*)\Loss Rate',
'\RemoteFX Root GPU Management(*)\Resources: VMs running RemoteFX',
'\RemoteFX Root GPU Management(*)\VRAM: Available MB per GPU',
'\Hyper-V Replica VM(*)\Network Bytes Recv',
'\Hyper-V Replica VM(Hoster-Replica-Test)\Network Bytes Sent'
