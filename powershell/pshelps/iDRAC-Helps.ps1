break

Default UserName: Root, PW: calvin

start-process http://en.community.dell.com/techcenter/systems-management/w/wiki/7727.powershell-cmdlets-for-poweredge-servers
Get-Command -Module DellPEPowerShellTools
Import-Module -Name 'DellPEPowerShellTools'

[string] $ComputerName = 'FSDEBSNE0512r'
if (!$Credential) {$Credential = Get-Credential -UserName 'ILOINSTALL' -Message 'Input ILOINSTALL Credential'}
$iDRACSession = New-PEDRACSession -IPAddress 10.94.225.102 -Credential $Credential

$IP = (Resolve-DnsName -Name $ComputerName -Type A).IPAddress

$iDRACSession = New-PEDRACSession -IPAddress $IP -Credential $Credential -SetDefaultParameterValue
'IP1', 'IP2', 'IP3' | New-PEDRACSession -Credential $Credential -SetDefaultParameterValue

Set-PEPowerState -iDRACSession $iDRACSession -State PowerOn
Get-PEBootOrder -iDRACSession $iDRACSession    
Get-PESystemInformation -iDRACSession $iDRACSession 

Remove-Module -Name 'DellPEPowerShellTools'
Import-Module -Name 'DellPEWSManTools'
Get-Command -Module 'DellPEWSManTools'
Set-PEPowerState -iDRACSession $iDRACSession -State PowerOn -Force   # PowerCycle,PowerOff,PowerOn 
Connect-PERFSISOImage -iDRACSession $iDRACSession -
Get-Command -Module DellPEWSManTools *virtual*
Get-PEVirtualDisk -iDRACSession $iDRACSession 
Get-PEBIOSAttribute -iDRACSession $iDRACSession 
Set-PEBIOSAttribute -iDRACSession $iDRACSession 



#region Get-PEBIOSAttribute
<#  Get-PEBIOSAttribute -iDRACSession  $iDRACSession


AttributeDisplayName      : System Memory Testing
AttributeName             : MemTest
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 305
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:MemTest
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, HardwareBasedTest}
PossibleValuesDescription : {Enabled, Disabled, Hardware Based}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Memory Operating Mode
AttributeName             : MemOpMode
CurrentValue              : OptimizerMode
Dependency                : 
DisplayOrder              : 306
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:MemOpMode
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {OptimizerMode, SpareMode, MirrorMode, FaultResilientMode}
PossibleValuesDescription : {Optimizer Mode, Spare Mode, Mirror Mode, Fault Resilient Mode}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Spare Ranks per DDR channel
AttributeName             : MltRnkSpr
CurrentValue              : MltRnkSpr1
Dependency                : 
DisplayOrder              : 307
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:MltRnkSpr
IsReadOnly                : true
PendingValue              : 
PossibleValues            : MltRnkSpr1
PossibleValuesDescription : 1
PSComputerName            : 192.168.9.219

AttributeDisplayName      : FRM Redundant Memory Size
AttributeName             : AddrBasMir
CurrentValue              : AllMem
Dependency                : 
DisplayOrder              : 308
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:AddrBasMir
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {AllMem, 64GB, HalfMem}
PossibleValuesDescription : {Full Riser, 64GB, Half Riser}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Node Interleaving
AttributeName             : NodeInterleave
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 309
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:NodeInterleave
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Snoop Mode
AttributeName             : SnoopMode
CurrentValue              : HomeSnoop
Dependency                : <Dep><ValLev Val="ClusterOnDie" Op="OR"><SupIf Name="NodeInterleave">Enabled</SupIf></ValLev></Dep>
DisplayOrder              : 310
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:SnoopMode
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {HomeSnoop, ClusterOnDie}
PossibleValuesDescription : {Home Snoop, Cluster On Die}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Correctable Memory ECC SMI
AttributeName             : CorrEccSmi
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 313
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Memory Settings
GroupID                   : MemSettings
InstanceID                : BIOS.Setup.1-1:CorrEccSmi
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Logical Processor
AttributeName             : LogicalProc
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="IntelTxt">On</ROIf></AttrLev></Dep>
DisplayOrder              : 400
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:LogicalProc
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : QPI Speed
AttributeName             : QpiSpeed
CurrentValue              : MaxDataRate
Dependency                : 
DisplayOrder              : 401
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:QpiSpeed
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {MaxDataRate, 9GTps, 8GTps, 7GTps...}
PossibleValuesDescription : {Maximum data rate, 9.6 GT/s, 8.0 GT/s, 7.2 GT/s...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Virtualization Technology
AttributeName             : ProcVirtualization
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 403
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcVirtualization
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Address Translation Services (ATS)
AttributeName             : ProcAts
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="ProcVirtualization">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 404
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcAts
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Adjacent Cache Line Prefetch
AttributeName             : ProcAdjCacheLine
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 405
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcAdjCacheLine
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Hardware Prefetcher
AttributeName             : ProcHwPrefetcher
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 406
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcHwPrefetcher
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : DCU Streamer Prefetcher
AttributeName             : DcuStreamerPrefetcher
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 407
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:DcuStreamerPrefetcher
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : DCU IP Prefetcher
AttributeName             : DcuIpPrefetcher
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 408
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:DcuIpPrefetcher
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Execute Disable
AttributeName             : ProcExecuteDisable
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 409
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcExecuteDisable
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Logical Processor Idling
AttributeName             : DynamicCoreAllocation
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 410
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:DynamicCoreAllocation
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Configurable TDP
AttributeName             : ProcConfigTdp
CurrentValue              : Nominal
Dependency                : 
DisplayOrder              : 411
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcConfigTdp
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Nominal, Level1}
PossibleValuesDescription : {Nominal, Level 1}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : X2Apic Mode
AttributeName             : ProcX2Apic
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="ProcVirtualization">Disabled</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="ProcVirtualization">Disabled</SupIf></ValLev><ValLev Val="Disabled" Op="OR"><ForceIf 
                            Name="ProcVirtualization">Disabled</ForceIf></ValLev></Dep>
DisplayOrder              : 412
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcX2Apic
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Number of Cores per Processor
AttributeName             : ProcCores
CurrentValue              : All
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="IntelTxt">On</ROIf></AttrLev><ValLev Val="All" Op="OR"><ForceIf 
                            Name="IntelTxt">On</ForceIf></ValLev></Dep>
DisplayOrder              : 419
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Processor Settings
GroupID                   : ProcSettings
InstanceID                : BIOS.Setup.1-1:ProcCores
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {All, 1, 2, 4...}
PossibleValuesDescription : {All, 1, 2, 4...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Embedded SATA
AttributeName             : EmbSata
CurrentValue              : AhciMode
Dependency                : 
DisplayOrder              : 500
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : SATA Settings
GroupID                   : SataSettings
InstanceID                : BIOS.Setup.1-1:EmbSata
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {AtaMode, AhciMode, Off}
PossibleValuesDescription : {ATA Mode                     , AHCI Mode                    , Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Security Freeze Lock
AttributeName             : SecurityFreezeLock
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="EmbSata">RaidMode</ROIf><ROIf Name="EmbSata">Off</ROIf></AttrLev><ValLev Val="Enabled" 
                            Op="OR"><SupIf Name="EmbSata">RaidMode</SupIf><SupIf Name="EmbSata">Off</SupIf></ValLev><ValLev Val="Disabled" 
                            Op="OR"><ForceIf Name="EmbSata">RaidMode</ForceIf><ForceIf Name="EmbSata">Off</ForceIf></ValLev></Dep>
DisplayOrder              : 501
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : SATA Settings
GroupID                   : SataSettings
InstanceID                : BIOS.Setup.1-1:SecurityFreezeLock
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Write Cache
AttributeName             : WriteCache
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="EmbSata">RaidMode</ROIf><ROIf Name="EmbSata">Off</ROIf></AttrLev><ValLev Val="Enabled" 
                            Op="OR"><SupIf Name="EmbSata">RaidMode</SupIf><SupIf Name="EmbSata">Off</SupIf></ValLev><ValLev Val="Disabled" 
                            Op="OR"><ForceIf Name="EmbSata">RaidMode</ForceIf><ForceIf Name="EmbSata">Off</ForceIf></ValLev></Dep>
DisplayOrder              : 502
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : SATA Settings
GroupID                   : SataSettings
InstanceID                : BIOS.Setup.1-1:WriteCache
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Port A
AttributeName             : SataPortA
CurrentValue              : Auto
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="EmbSata">AtaMode</ROIf></AttrLev><ValLev Val="Auto" Op="OR"><ForceIf 
                            Name="EmbSata">AhciMode</ForceIf><ForceIf Name="EmbSata">RaidMode</ForceIf></ValLev><ValLev Val="Off" Op="OR"><SupIf 
                            Name="EmbSata">AhciMode</SupIf><SupIf Name="EmbSata">RaidMode</SupIf></ValLev></Dep>
DisplayOrder              : 503
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : SATA Settings
GroupID                   : SataSettings
InstanceID                : BIOS.Setup.1-1:SataPortA
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Auto, Off}
PossibleValuesDescription : {Auto, Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Port B
AttributeName             : SataPortB
CurrentValue              : Auto
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="EmbSata">AtaMode</ROIf></AttrLev><ValLev Val="Auto" Op="OR"><ForceIf 
                            Name="EmbSata">AhciMode</ForceIf><ForceIf Name="EmbSata">RaidMode</ForceIf></ValLev><ValLev Val="Off" Op="OR"><SupIf 
                            Name="EmbSata">AhciMode</SupIf><SupIf Name="EmbSata">RaidMode</SupIf></ValLev></Dep>
DisplayOrder              : 507
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : SATA Settings
GroupID                   : SataSettings
InstanceID                : BIOS.Setup.1-1:SataPortB
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Auto, Off}
PossibleValuesDescription : {Auto, Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Port C
AttributeName             : SataPortC
CurrentValue              : Auto
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="EmbSata">AtaMode</ROIf></AttrLev><ValLev Val="Auto" Op="OR"><ForceIf 
                            Name="EmbSata">AhciMode</ForceIf><ForceIf Name="EmbSata">RaidMode</ForceIf></ValLev><ValLev Val="Off" Op="OR"><SupIf 
                            Name="EmbSata">AhciMode</SupIf><SupIf Name="EmbSata">RaidMode</SupIf></ValLev></Dep>
DisplayOrder              : 511
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : SATA Settings
GroupID                   : SataSettings
InstanceID                : BIOS.Setup.1-1:SataPortC
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Auto, Off}
PossibleValuesDescription : {Auto, Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Boot Mode
AttributeName             : BootMode
CurrentValue              : Uefi
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="SecureBoot">Enabled</ROIf></AttrLev></Dep>
DisplayOrder              : 600
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Boot Settings
GroupID                   : BootSettings
InstanceID                : BIOS.Setup.1-1:BootMode
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Bios, Uefi}
PossibleValuesDescription : {BIOS, UEFI}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Boot Sequence Retry
AttributeName             : BootSeqRetry
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 601
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Boot Settings
GroupID                   : BootSettings
InstanceID                : BIOS.Setup.1-1:BootSeqRetry
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Hard-Disk Failover
AttributeName             : HddFailover
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="BootMode">Uefi</ROIf></AttrLev></Dep>
DisplayOrder              : 602
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Boot Settings
GroupID                   : BootSettings
InstanceID                : BIOS.Setup.1-1:HddFailover
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : One-Time Boot Device List
AttributeName             : OneTimeBootMode
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 800
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : One-Time Boot
GroupID                   : OneTimeBoot
InstanceID                : BIOS.Setup.1-1:OneTimeBootMode
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Disabled, OneTimeUefiBootSeq}
PossibleValuesDescription : {Disabled, UEFI Boot Sequence Device}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : UEFI Boot Sequence Device
AttributeName             : OneTimeUefiBootSeqDev
CurrentValue              : RAID.Integrated.1-1
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="OneTimeBootMode">OneTimeUefiBootSeq</ROIf></AttrLev></Dep>
DisplayOrder              : 801
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : One-Time Boot
GroupID                   : OneTimeBoot
InstanceID                : BIOS.Setup.1-1:OneTimeUefiBootSeqDev
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {RAID.Integrated.1-1, Unknown.Unknown.1-1, Unknown.Unknown.2-1, Unknown.Unknown.3-1...}
PossibleValuesDescription : {Integrated RAID Controller 1: Windows Boot Manager, Unavailable: Windows Boot Manager, Unavailable: Windows Boot Manager, 
                            Unavailable: Windows Boot Manager...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : PXE Device1
AttributeName             : PxeDev1EnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><SupIf Name="BootMode">Bios</SupIf></AttrLev></Dep>
DisplayOrder              : 900
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Network Settings
GroupID                   : NetworkSettings
InstanceID                : BIOS.Setup.1-1:PxeDev1EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : PXE Device2
AttributeName             : PxeDev2EnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><SupIf Name="BootMode">Bios</SupIf></AttrLev></Dep>
DisplayOrder              : 901
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Network Settings
GroupID                   : NetworkSettings
InstanceID                : BIOS.Setup.1-1:PxeDev2EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : PXE Device3
AttributeName             : PxeDev3EnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><SupIf Name="BootMode">Bios</SupIf></AttrLev></Dep>
DisplayOrder              : 902
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Network Settings
GroupID                   : NetworkSettings
InstanceID                : BIOS.Setup.1-1:PxeDev3EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : PXE Device4
AttributeName             : PxeDev4EnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><SupIf Name="BootMode">Bios</SupIf></AttrLev></Dep>
DisplayOrder              : 903
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Network Settings
GroupID                   : NetworkSettings
InstanceID                : BIOS.Setup.1-1:PxeDev4EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : ISCSI Device1
AttributeName             : IscsiDev1EnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 909
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Network Settings
GroupID                   : NetworkSettings
InstanceID                : BIOS.Setup.1-1:IscsiDev1EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Interface
AttributeName             : PxeDev1Interface
CurrentValue              : NIC.Slot.1-1-1
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev1EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1000
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device1 Settings
GroupID                   : PxeDev1Settings
InstanceID                : BIOS.Setup.1-1:PxeDev1Interface
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {NIC.Slot.1-1-1, NIC.Slot.1-2-1, NIC.Slot.3-1-1, NIC.Slot.3-2-1...}
PossibleValuesDescription : {NIC in Slot 1 Port 1 Partition 1, NIC in Slot 1 Port 2 Partition 1, NIC in Slot 3 Port 1 Partition 1, NIC in Slot 3 Port 
                            2 Partition 1...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Protocol
AttributeName             : PxeDev1Protocol
CurrentValue              : IPv4
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev1EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1001
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device1 Settings
GroupID                   : PxeDev1Settings
InstanceID                : BIOS.Setup.1-1:PxeDev1Protocol
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {IPv4, IPv6}
PossibleValuesDescription : {IPv4, IPv6}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : VLAN
AttributeName             : PxeDev1VlanEnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev1EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1002
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device1 Settings
GroupID                   : PxeDev1Settings
InstanceID                : BIOS.Setup.1-1:PxeDev1VlanEnDis
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Interface
AttributeName             : PxeDev2Interface
CurrentValue              : NIC.Slot.1-1-1
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev2EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1100
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device2 Settings
GroupID                   : PxeDev2Settings
InstanceID                : BIOS.Setup.1-1:PxeDev2Interface
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {NIC.Slot.1-1-1, NIC.Slot.1-2-1, NIC.Slot.3-1-1, NIC.Slot.3-2-1...}
PossibleValuesDescription : {NIC in Slot 1 Port 1 Partition 1, NIC in Slot 1 Port 2 Partition 1, NIC in Slot 3 Port 1 Partition 1, NIC in Slot 3 Port 
                            2 Partition 1...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Protocol
AttributeName             : PxeDev2Protocol
CurrentValue              : IPv4
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev2EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1101
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device2 Settings
GroupID                   : PxeDev2Settings
InstanceID                : BIOS.Setup.1-1:PxeDev2Protocol
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {IPv4, IPv6}
PossibleValuesDescription : {IPv4, IPv6}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : VLAN
AttributeName             : PxeDev2VlanEnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev2EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1102
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device2 Settings
GroupID                   : PxeDev2Settings
InstanceID                : BIOS.Setup.1-1:PxeDev2VlanEnDis
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Interface
AttributeName             : PxeDev3Interface
CurrentValue              : NIC.Slot.1-1-1
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev3EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1200
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device3 Settings
GroupID                   : PxeDev3Settings
InstanceID                : BIOS.Setup.1-1:PxeDev3Interface
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {NIC.Slot.1-1-1, NIC.Slot.1-2-1, NIC.Slot.3-1-1, NIC.Slot.3-2-1...}
PossibleValuesDescription : {NIC in Slot 1 Port 1 Partition 1, NIC in Slot 1 Port 2 Partition 1, NIC in Slot 3 Port 1 Partition 1, NIC in Slot 3 Port 
                            2 Partition 1...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Protocol
AttributeName             : PxeDev3Protocol
CurrentValue              : IPv4
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev3EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1201
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device3 Settings
GroupID                   : PxeDev3Settings
InstanceID                : BIOS.Setup.1-1:PxeDev3Protocol
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {IPv4, IPv6}
PossibleValuesDescription : {IPv4, IPv6}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : VLAN
AttributeName             : PxeDev3VlanEnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev3EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1202
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device3 Settings
GroupID                   : PxeDev3Settings
InstanceID                : BIOS.Setup.1-1:PxeDev3VlanEnDis
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Interface
AttributeName             : PxeDev4Interface
CurrentValue              : NIC.Slot.1-1-1
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev4EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1300
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device4 Settings
GroupID                   : PxeDev4Settings
InstanceID                : BIOS.Setup.1-1:PxeDev4Interface
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {NIC.Slot.1-1-1, NIC.Slot.1-2-1, NIC.Slot.3-1-1, NIC.Slot.3-2-1...}
PossibleValuesDescription : {NIC in Slot 1 Port 1 Partition 1, NIC in Slot 1 Port 2 Partition 1, NIC in Slot 3 Port 1 Partition 1, NIC in Slot 3 Port 
                            2 Partition 1...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Protocol
AttributeName             : PxeDev4Protocol
CurrentValue              : IPv4
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev4EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1301
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device4 Settings
GroupID                   : PxeDev4Settings
InstanceID                : BIOS.Setup.1-1:PxeDev4Protocol
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {IPv4, IPv6}
PossibleValuesDescription : {IPv4, IPv6}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : VLAN
AttributeName             : PxeDev4VlanEnDis
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="PxeDev4EnDis">Disabled</ROIf></AttrLev></Dep>
DisplayOrder              : 1302
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : PXE Device4 Settings
GroupID                   : PxeDev4Settings
InstanceID                : BIOS.Setup.1-1:PxeDev4VlanEnDis
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Connection 1
AttributeName             : IscsiDev1Con1EnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1400
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : ISCSI Device1 Settings
GroupID                   : IscsiDev1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Connection 2
AttributeName             : IscsiDev1Con2EnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1401
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : ISCSI Device1 Settings
GroupID                   : IscsiDev1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2EnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Connection Order
AttributeName             : IscsiDev1ConOrder
CurrentValue              : Con1Con2
Dependency                : 
DisplayOrder              : 1404
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : ISCSI Device1 Settings
GroupID                   : IscsiDev1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1ConOrder
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Con1Con2, Con2Con1}
PossibleValuesDescription : {Connection 1, Connection 2, Connection 2, Connection 1}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Interface
AttributeName             : IscsiDev1Con1Interface
CurrentValue              : NIC.Slot.1-1-1
Dependency                : 
DisplayOrder              : 1500
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1Interface
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {NIC.Slot.1-1-1, NIC.Slot.1-2-1, NIC.Slot.3-1-1, NIC.Slot.3-2-1...}
PossibleValuesDescription : {NIC in Slot 1 Port 1 Partition 1, NIC in Slot 1 Port 2 Partition 1, NIC in Slot 3 Port 1 Partition 1, NIC in Slot 3 Port 
                            2 Partition 1...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Protocol
AttributeName             : IscsiDev1Con1Protocol
CurrentValue              : IPv4
Dependency                : 
DisplayOrder              : 1501
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1Protocol
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {IPv4, IPv6}
PossibleValuesDescription : {IPv4, IPv6}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : VLAN
AttributeName             : IscsiDev1Con1VlanEnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1502
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1VlanEnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : DHCP
AttributeName             : IscsiDev1Con1DhcpEnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1507
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1DhcpEnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Target info via DHCP
AttributeName             : IscsiDev1Con1TgtDhcpEnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1511
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1TgtDhcpEnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Authentication Type
AttributeName             : IscsiDev1Con1Auth
CurrentValue              : None
Dependency                : 
DisplayOrder              : 1517
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1Auth
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Chap, None}
PossibleValuesDescription : {CHAP, None}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : CHAP Type
AttributeName             : IscsiDev1Con1ChapType
CurrentValue              : OneWay
Dependency                : 
DisplayOrder              : 1518
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 1 Settings
GroupID                   : IscsiDev1Con1Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con1ChapType
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {OneWay, Mutual}
PossibleValuesDescription : {One Way, Mutual}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Interface
AttributeName             : IscsiDev1Con2Interface
CurrentValue              : NIC.Slot.1-1-1
Dependency                : 
DisplayOrder              : 1600
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2Interface
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {NIC.Slot.1-1-1, NIC.Slot.1-2-1, NIC.Slot.3-1-1, NIC.Slot.3-2-1...}
PossibleValuesDescription : {NIC in Slot 1 Port 1 Partition 1, NIC in Slot 1 Port 2 Partition 1, NIC in Slot 3 Port 1 Partition 1, NIC in Slot 3 Port 
                            2 Partition 1...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Protocol
AttributeName             : IscsiDev1Con2Protocol
CurrentValue              : IPv4
Dependency                : 
DisplayOrder              : 1601
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2Protocol
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {IPv4, IPv6}
PossibleValuesDescription : {IPv4, IPv6}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : VLAN
AttributeName             : IscsiDev1Con2VlanEnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1602
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2VlanEnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : DHCP
AttributeName             : IscsiDev1Con2DhcpEnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1607
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2DhcpEnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Target info via DHCP
AttributeName             : IscsiDev1Con2TgtDhcpEnDis
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1611
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2TgtDhcpEnDis
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Authentication Type
AttributeName             : IscsiDev1Con2Auth
CurrentValue              : None
Dependency                : 
DisplayOrder              : 1617
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2Auth
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Chap, None}
PossibleValuesDescription : {CHAP, None}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : CHAP Type
AttributeName             : IscsiDev1Con2ChapType
CurrentValue              : OneWay
Dependency                : 
DisplayOrder              : 1618
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Connection 2 Settings
GroupID                   : IscsiDev1Con2Settings
InstanceID                : BIOS.Setup.1-1:IscsiDev1Con2ChapType
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {OneWay, Mutual}
PossibleValuesDescription : {One Way, Mutual}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : User Accessible USB Ports
AttributeName             : UsbPorts
CurrentValue              : AllOn
Dependency                : 
DisplayOrder              : 1701
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:UsbPorts
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {AllOn, OnlyBackPortsOn, AllOff}
PossibleValuesDescription : {All Ports On, Only Back Ports On, All Ports Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Internal USB Port
AttributeName             : InternalUsb
CurrentValue              : On
Dependency                : 
DisplayOrder              : 1702
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:InternalUsb
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {On, Off}
PossibleValuesDescription : {On, Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Integrated RAID Controller
AttributeName             : IntegratedRaid
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1705
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:IntegratedRaid
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Integrated Network Card 1
AttributeName             : IntegratedNetwork1
CurrentValue              : DisabledOs
Dependency                : 
DisplayOrder              : 1706
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:IntegratedNetwork1
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, DisabledOs}
PossibleValuesDescription : {Enabled, Disabled (OS)}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : I/OAT DMA Engine
AttributeName             : IoatEngine
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1725
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:IoatEngine
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : I/O Non-Posted Prefetch
AttributeName             : IoNonPostedPrefetch
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1726
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:IoNonPostedPrefetch
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : I/O Snoop HoldOff Response
AttributeName             : SnoopHldOff
CurrentValue              : Roll256Cycles
Dependency                : 
DisplayOrder              : 1727
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:SnoopHldOff
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Roll256Cycles, Roll512Cycles, Roll1KCycles, Roll2KCycles}
PossibleValuesDescription : {256 Cycles, 512 Cycles, 1K Cycles, 2K Cycles}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Embedded Video Controller
AttributeName             : EmbVideo
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1728
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:EmbVideo
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : SR-IOV Global Enable
AttributeName             : SriovGlobalEnable
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1730
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:SriovGlobalEnable
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : OS Watchdog Timer
AttributeName             : OsWatchdogTimer
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1733
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:OsWatchdogTimer
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Memory Mapped I/O above 4GB
AttributeName             : MmioAbove4Gb
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1734
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Integrated Devices
GroupID                   : IntegratedDevices
InstanceID                : BIOS.Setup.1-1:MmioAbove4Gb
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 1 Bifurcation
AttributeName             : Slot1Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1800
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot1Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4}
PossibleValuesDescription : {Default Bifurcation, x4 x4 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 3 Bifurcation
AttributeName             : Slot3Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1802
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot3Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4}
PossibleValuesDescription : {Default Bifurcation, x4 x4 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 4 Bifurcation
AttributeName             : Slot4Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1803
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot4Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4x4x4, x8x8}
PossibleValuesDescription : {Default Bifurcation, x4 x4 x4 x4 Bifurcation, x8 x8 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 5 Bifurcation
AttributeName             : Slot5Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1804
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot5Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4x4x4, x8x8}
PossibleValuesDescription : {Default Bifurcation, x4 x4 x4 x4 Bifurcation, x8 x8 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 6 Bifurcation
AttributeName             : Slot6Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1805
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot6Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4x4x4, x8x8}
PossibleValuesDescription : {Default Bifurcation, x4 x4 x4 x4 Bifurcation, x8 x8 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 7 Bifurcation
AttributeName             : Slot7Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1806
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot7Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4x4x4, x8x8}
PossibleValuesDescription : {Default Bifurcation, x4 x4 x4 x4 Bifurcation, x8 x8 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 8 Bifurcation
AttributeName             : Slot8Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1807
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot8Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4x4x4, x8x8}
PossibleValuesDescription : {Default Bifurcation, x4 x4 x4 x4 Bifurcation, x8 x8 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 9 Bifurcation
AttributeName             : Slot9Bif
CurrentValue              : DefaultBifurcation
Dependency                : 
DisplayOrder              : 1808
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Bifurcation
GroupID                   : SlotBifurcation
InstanceID                : BIOS.Setup.1-1:Slot9Bif
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {DefaultBifurcation, x4x4x4x4, x8x8}
PossibleValuesDescription : {Default Bifurcation, x4 x4 x4 x4 Bifurcation, x8 x8 Bifurcation}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Global Slot Boot Driver Disable
AttributeName             : GlobalSlotDriverDisable
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 1900
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:GlobalSlotDriverDisable
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 1
AttributeName             : Slot1
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1901
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot1
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 3
AttributeName             : Slot3
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1903
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot3
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 4
AttributeName             : Slot4
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1904
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot4
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 5
AttributeName             : Slot5
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1905
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot5
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 6
AttributeName             : Slot6
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1906
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot6
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 7
AttributeName             : Slot7
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1907
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot7
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 8
AttributeName             : Slot8
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1908
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot8
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Slot 9
AttributeName             : Slot9
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 1909
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Slot Disablement
GroupID                   : SlotDisablement
InstanceID                : BIOS.Setup.1-1:Slot9
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled, BootDriverDisabled}
PossibleValuesDescription : {Enabled, Disabled, Boot Driver Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Serial Communication
AttributeName             : SerialComm
CurrentValue              : OnConRedirAuto
Dependency                : 
DisplayOrder              : 2000
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Serial Communication
GroupID                   : SerialCommSettings
InstanceID                : BIOS.Setup.1-1:SerialComm
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {OnNoConRedir, OnConRedirAuto, OnConRedirCom1, OnConRedirCom2...}
PossibleValuesDescription : {On without Console Redirection, Auto, On with Console Redirection via COM1, On with Console Redirection via COM2...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Serial Port Address
AttributeName             : SerialPortAddress
CurrentValue              : Serial1Com2Serial2Com1
Dependency                : 
DisplayOrder              : 2001
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Serial Communication
GroupID                   : SerialCommSettings
InstanceID                : BIOS.Setup.1-1:SerialPortAddress
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Serial1Com1Serial2Com2, Serial1Com2Serial2Com1}
PossibleValuesDescription : {Serial Device1=COM1,Serial Device2=COM2, Serial Device1=COM2,Serial Device2=COM1}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : External Serial Connector
AttributeName             : ExtSerialConnector
CurrentValue              : Serial1
Dependency                : 
DisplayOrder              : 2002
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Serial Communication
GroupID                   : SerialCommSettings
InstanceID                : BIOS.Setup.1-1:ExtSerialConnector
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Serial1, Serial2, RemoteAccDevice}
PossibleValuesDescription : {Serial Device 1, Serial Device 2, Remote Access Device}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Failsafe Baud Rate
AttributeName             : FailSafeBaud
CurrentValue              : 115200
Dependency                : 
DisplayOrder              : 2003
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Serial Communication
GroupID                   : SerialCommSettings
InstanceID                : BIOS.Setup.1-1:FailSafeBaud
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {115200, 57600, 19200, 9600}
PossibleValuesDescription : {115200, 57600, 19200, 9600}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Remote Terminal Type
AttributeName             : ConTermType
CurrentValue              : Vt100Vt220
Dependency                : 
DisplayOrder              : 2004
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Serial Communication
GroupID                   : SerialCommSettings
InstanceID                : BIOS.Setup.1-1:ConTermType
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Vt100Vt220, Ansi}
PossibleValuesDescription : {VT100/VT220, ANSI}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Redirection After Boot
AttributeName             : RedirAfterBoot
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 2005
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Serial Communication
GroupID                   : SerialCommSettings
InstanceID                : BIOS.Setup.1-1:RedirAfterBoot
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : System Profile
AttributeName             : SysProfile
CurrentValue              : PerfOptimized
Dependency                : 
DisplayOrder              : 2100
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:SysProfile
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {PerfPerWattOptimizedDapc, PerfPerWattOptimizedOs, PerfOptimized, DenseCfgOptimized...}
PossibleValuesDescription : {Performance Per Watt (DAPC), Performance Per Watt (OS), Performance, Dense Configuration...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : CPU Power Management
AttributeName             : ProcPwrPerf
CurrentValue              : MaxPerf
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="SysDbpm" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">PerfOptimized</SupIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev><ValLev 
                            Val="OsDbpm" Op="OR"><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf></ValLev><ValLev Val="MaxPerf" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf 
                            Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf Name="SysProfile">PerfOptimized</ForceIf></ValLev><ValLev 
                            Val="HwpDbpm" Op="OR"><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">DenseCfgOptimized</SupIf><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf></ValLev></Dep>
DisplayOrder              : 2101
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:ProcPwrPerf
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {SysDbpm, OsDbpm, MaxPerf, HwpDbpm}
PossibleValuesDescription : {System DBPM (DAPC), OS DBPM, Maximum Performance, Hardware P States}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Memory Frequency
AttributeName             : MemFrequency
CurrentValue              : MaxPerf
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="MaxPerf" Op="OR"><ForceIf 
                            Op="NOT" Name="SysProfile">Custom</ForceIf></ValLev><ValLev Val="2133MHz" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="1866MHz" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="1600MHz" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="1333MHz" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="MaxReliability" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2102
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:MemFrequency
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {MaxPerf, 2133MHz, 1866MHz, 1600MHz...}
PossibleValuesDescription : {Maximum Performance, 2133MHz, 1866MHz, 1600MHz...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Turbo Boost
AttributeName             : ProcTurboMode
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf Name="SysProfile">PerfOptimized</ForceIf></ValLev><ValLev 
                            Val="Disabled" Op="OR"><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">PerfOptimized</SupIf><ForceIf 
                            Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev></Dep>
DisplayOrder              : 2103
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:ProcTurboMode
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Energy Efficient Turbo
AttributeName             : EnergyEfficientTurbo
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><SupIf Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf Name="SysProfile">PerfOptimizedHwp</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf></ValLev><ValLev Val="Disabled" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedOs</SupIf><ForceIf 
                            Name="SysProfile">PerfOptimized</ForceIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev></Dep>
DisplayOrder              : 2104
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:EnergyEfficientTurbo
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : C1E
AttributeName             : ProcC1E
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><ForceIf Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev><ValLev 
                            Val="Disabled" Op="OR"><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf 
                            Name="SysProfile">PerfOptimized</ForceIf></ValLev></Dep>
DisplayOrder              : 2105
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:ProcC1E
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : C States
AttributeName             : ProcCStates
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><ForceIf Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev><ValLev 
                            Val="Disabled" Op="OR"><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf 
                            Name="SysProfile">PerfOptimized</ForceIf></ValLev><ValLev Val="Autonomous" Op="OR"><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">DenseCfgOptimized</SupIf></ValLev></Dep>
DisplayOrder              : 2106
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:ProcCStates
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled, Autonomous}
PossibleValuesDescription : {Enabled, Disabled, Autonomous}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Collaborative CPU Performance Control
AttributeName             : CollaborativeCpuPerfCtrl
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><SupIf Name="SysProfile">DenseCfgOptimized</SupIf></ValLev><ValLev Val="Disabled" 
                            Op="OR"><ForceIf Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf><ForceIf 
                            Name="SysProfile">PerfOptimized</ForceIf><ForceIf Name="SysProfile">PerfOptimizedHwp</ForceIf></ValLev></Dep>
DisplayOrder              : 2108
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:CollaborativeCpuPerfCtrl
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Memory Patrol Scrub
AttributeName             : MemPatrolScrub
CurrentValue              : Standard
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Extended" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><ForceIf Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev><ValLev 
                            Val="Standard" Op="OR"><SupIf Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf 
                            Name="SysProfile">PerfOptimized</ForceIf><ForceIf Name="SysProfile">PerfOptimizedHwp</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf></ValLev><ValLev Val="Disabled" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2109
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:MemPatrolScrub
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Extended, Standard, Disabled}
PossibleValuesDescription : {Extended, Standard, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Memory Refresh Rate
AttributeName             : MemRefreshRate
CurrentValue              : 1x
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="1x" Op="OR"><SupIf 
                            Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf Name="SysProfile">PerfOptimized</ForceIf></ValLev><ValLev 
                            Val="2x" Op="OR"><SupIf Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf Name="SysProfile">PerfOptimized</SupIf><ForceIf 
                            Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev></Dep>
DisplayOrder              : 2110
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:MemRefreshRate
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {1x, 2x}
PossibleValuesDescription : {1x, 2x}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Uncore Frequency
AttributeName             : UncoreFrequency
CurrentValue              : MaxUFS
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="DynamicUFS" Op="OR"><SupIf 
                            Name="SysProfile">PerfOptimized</SupIf><ForceIf Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf 
                            Name="SysProfile">PerfOptimizedHwp</ForceIf><ForceIf Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf 
                            Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev><ValLev Val="MaxUFS" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf 
                            Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf Name="SysProfile">PerfOptimized</ForceIf></ValLev></Dep>
DisplayOrder              : 2111
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:UncoreFrequency
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {DynamicUFS, MaxUFS}
PossibleValuesDescription : {Dynamic, Maximum}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Energy Efficient Policy
AttributeName             : EnergyPerformanceBias
CurrentValue              : MaxPower
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="MaxPower" Op="OR"><SupIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</SupIf><SupIf Name="SysProfile">PerfPerWattOptimizedOs</SupIf><SupIf 
                            Name="SysProfile">DenseCfgOptimized</SupIf><ForceIf Name="SysProfile">PerfOptimized</ForceIf></ValLev><ValLev 
                            Val="BalancedPerformance" Op="OR"><SupIf Name="SysProfile">PerfOptimized</SupIf><ForceIf 
                            Name="SysProfile">PerfPerWattOptimizedDapc</ForceIf><ForceIf Name="SysProfile">PerfPerWattOptimizedOs</ForceIf><ForceIf 
                            Name="SysProfile">DenseCfgOptimized</ForceIf></ValLev><ValLev Val="BalancedEfficiency" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="LowPower" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2112
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:EnergyPerformanceBias
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {MaxPower, BalancedPerformance, BalancedEfficiency, LowPower}
PossibleValuesDescription : {Performance, Balanced Performance, Balanced Energy, Energy Efficient}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Number of Turbo Boost Enabled Cores for Processor 1
AttributeName             : Proc1TurboCoreNum
CurrentValue              : All
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="All" Op="OR"><ForceIf Op="NOT" 
                            Name="SysProfile">Custom</ForceIf></ValLev><ValLev Val="1" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="2" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="4" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="6" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="8" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2113
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:Proc1TurboCoreNum
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {All, 1, 2, 4...}
PossibleValuesDescription : {All, 1, 2, 4...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Number of Turbo Boost Enabled Cores for Processor 2
AttributeName             : Proc2TurboCoreNum
CurrentValue              : All
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="All" Op="OR"><ForceIf Op="NOT" 
                            Name="SysProfile">Custom</ForceIf></ValLev><ValLev Val="1" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="2" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="4" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="6" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="8" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2114
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:Proc2TurboCoreNum
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {All, 1, 2, 4...}
PossibleValuesDescription : {All, 1, 2, 4...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Number of Turbo Boost Enabled Cores for Processor 3
AttributeName             : Proc3TurboCoreNum
CurrentValue              : All
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="All" Op="OR"><ForceIf Op="NOT" 
                            Name="SysProfile">Custom</ForceIf></ValLev><ValLev Val="1" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="2" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="4" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="6" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="8" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2115
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:Proc3TurboCoreNum
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {All, 1, 2, 4...}
PossibleValuesDescription : {All, 1, 2, 4...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Number of Turbo Boost Enabled Cores for Processor 4
AttributeName             : Proc4TurboCoreNum
CurrentValue              : All
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="All" Op="OR"><ForceIf Op="NOT" 
                            Name="SysProfile">Custom</ForceIf></ValLev><ValLev Val="1" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="2" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="4" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="6" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev><ValLev Val="8" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2116
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:Proc4TurboCoreNum
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {All, 1, 2, 4...}
PossibleValuesDescription : {All, 1, 2, 4...}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Monitor/Mwait
AttributeName             : MonitorMwait
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Op="NOT" Name="SysProfile">Custom</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><ForceIf 
                            Op="NOT" Name="SysProfile">Custom</ForceIf></ValLev><ValLev Val="Disabled" Op="OR"><SupIf Op="NOT" 
                            Name="SysProfile">Custom</SupIf></ValLev></Dep>
DisplayOrder              : 2117
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:MonitorMwait
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Power Saver
AttributeName             : PowerSaver
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 2119
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Profile Settings
GroupID                   : SysProfileSettings
InstanceID                : BIOS.Setup.1-1:PowerSaver
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Password Status
AttributeName             : PasswordStatus
CurrentValue              : Unlocked
Dependency                : 
DisplayOrder              : 2203
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:PasswordStatus
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Unlocked, Locked}
PossibleValuesDescription : {Unlocked, Locked}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : TPM Security
AttributeName             : TpmSecurity
CurrentValue              : Off
Dependency                : 
DisplayOrder              : 2208
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:TpmSecurity
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Off, On}
PossibleValuesDescription : {Off, On}
PSComputerName            : 192.168.9.219

AttributeDisplayName      :     TPM Hierarchy
AttributeName             : Tpm2Hierarchy
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="TpmSecurity">Off</ROIf></AttrLev><ValLev Val="Enabled" Op="OR"><SupIf 
                            Name="TpmSecurity">Off</SupIf></ValLev><ValLev Val="Disabled" Op="OR"><SupIf 
                            Name="TpmSecurity">Off</SupIf></ValLev><ValLev Val="Clear" Op="OR"><SupIf Name="TpmSecurity">Off</SupIf></ValLev></Dep>
DisplayOrder              : 2213
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:Tpm2Hierarchy
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled, Clear}
PossibleValuesDescription : {Enabled, Disabled, Clear}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Intel(R) TXT
AttributeName             : IntelTxt
CurrentValue              : Off
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="ProcVirtualization">Disabled</ROIf><ROIf Name="TpmCommand">Deactivate</ROIf><ROIf 
                            Name="TpmCommand">Clear</ROIf><ROIf Name="TpmSecurity">Off</ROIf><ROIf Name="TpmSecurity">OnNoPbm</ROIf><ROIf Op="NOT" 
                            Name="TpmStatus">TpmStatusEnabledActivated</ROIf></AttrLev><ValLev Val="Off" Op="OR"><ForceIf 
                            Name="ProcVirtualization">Disabled</ForceIf><ForceIf Name="TpmCommand">Deactivate</ForceIf><ForceIf 
                            Name="TpmCommand">Clear</ForceIf><ForceIf Name="TpmSecurity">OnNoPbm</ForceIf><ForceIf 
                            Name="TpmSecurity">Off</ForceIf></ValLev><ValLev Val="On" Op="OR"><SupIf Name="ProcVirtualization">Disabled</SupIf><SupIf 
                            Name="TpmCommand">Deactivate</SupIf><SupIf Name="TpmCommand">Clear</SupIf><SupIf Name="TpmSecurity">OnNoPbm</SupIf><SupIf 
                            Name="TpmSecurity">Off</SupIf></ValLev></Dep>
DisplayOrder              : 2215
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:IntelTxt
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Off, On}
PossibleValuesDescription : {Off, On}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Power Button
AttributeName             : PwrButton
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 2216
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:PwrButton
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : NMI Button
AttributeName             : NmiButton
CurrentValue              : Disabled
Dependency                : 
DisplayOrder              : 2217
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:NmiButton
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : AC Power Recovery
AttributeName             : AcPwrRcvry
CurrentValue              : Last
Dependency                : 
DisplayOrder              : 2218
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:AcPwrRcvry
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Last, On, Off}
PossibleValuesDescription : {Last, On, Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : AC Power Recovery Delay
AttributeName             : AcPwrRcvryDelay
CurrentValue              : Immediate
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="AcPwrRcvry">Off</ROIf></AttrLev></Dep>
DisplayOrder              : 2219
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:AcPwrRcvryDelay
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Immediate, Random, User}
PossibleValuesDescription : {Immediate, Random, User Defined}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : UEFI Variable Access
AttributeName             : UefiVariableAccess
CurrentValue              : Standard
Dependency                : 
DisplayOrder              : 2221
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:UefiVariableAccess
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Standard, Controlled}
PossibleValuesDescription : {Standard, Controlled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Secure Boot
AttributeName             : SecureBoot
CurrentValue              : Enabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="BootMode">Bios</ROIf><ROIf Name="ForceInt10">Enabled</ROIf></AttrLev></Dep>
DisplayOrder              : 2222
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:SecureBoot
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Secure Boot Policy
AttributeName             : SecureBootPolicy
CurrentValue              : Standard
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="BootMode">Bios</ROIf><ROIf Name="ForceInt10">Enabled</ROIf></AttrLev></Dep>
DisplayOrder              : 2223
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : System Security
GroupID                   : SysSecurity
InstanceID                : BIOS.Setup.1-1:SecureBootPolicy
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Standard, Custom}
PossibleValuesDescription : {Standard, Custom}
PSComputerName            : 192.168.9.219

AttributeDisplayName      :     TPM PPI Bypass Provision
AttributeName             : TpmPpiBypassProvision
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="TpmSecurity">Off</ROIf></AttrLev></Dep>
DisplayOrder              : 2300
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : TPM Advanced
GroupID                   : TpmAdvanced
InstanceID                : BIOS.Setup.1-1:TpmPpiBypassProvision
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Disabled, Enabled}
PossibleValuesDescription : {Disabled, Enabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      :     TPM PPI Bypass Clear
AttributeName             : TpmPpiBypassClear
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="TpmSecurity">Off</ROIf></AttrLev></Dep>
DisplayOrder              : 2301
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : TPM Advanced
GroupID                   : TpmAdvanced
InstanceID                : BIOS.Setup.1-1:TpmPpiBypassClear
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Disabled, Enabled}
PossibleValuesDescription : {Disabled, Enabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Keyboard NumLock
AttributeName             : NumLock
CurrentValue              : On
Dependency                : 
DisplayOrder              : 2401
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Miscellaneous Settings
GroupID                   : MiscSettings
InstanceID                : BIOS.Setup.1-1:NumLock
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {On, Off}
PossibleValuesDescription : {On, Off}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : F1/F2 Prompt on Error
AttributeName             : ErrPrompt
CurrentValue              : Enabled
Dependency                : 
DisplayOrder              : 2402
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Miscellaneous Settings
GroupID                   : MiscSettings
InstanceID                : BIOS.Setup.1-1:ErrPrompt
IsReadOnly                : false
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

AttributeDisplayName      : Load Legacy Video Option ROM
AttributeName             : ForceInt10
CurrentValue              : Disabled
Dependency                : <Dep><AttrLev Op="OR"><ROIf Name="SecureBoot">Enabled</ROIf></AttrLev></Dep>
DisplayOrder              : 2403
FQDD                      : BIOS.Setup.1-1
GroupDisplayName          : Miscellaneous Settings
GroupID                   : MiscSettings
InstanceID                : BIOS.Setup.1-1:ForceInt10
IsReadOnly                : true
PendingValue              : 
PossibleValues            : {Enabled, Disabled}
PossibleValuesDescription : {Enabled, Disabled}
PSComputerName            : 192.168.9.219

#>
#endregion Get-PEBIOSAttribute
