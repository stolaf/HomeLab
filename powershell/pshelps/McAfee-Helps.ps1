break

<#
Fabian Lippert
über Citrix adminServer: McAfee EPO WebConsole: https://fsdebsea4001:8443  : anmelden mit dkx8zb8adm

links oben --> SystemStruktur --> Eigenede Organisation/CDC/IBA

#Move Agent installieren
Server anhaken: Aktionen / Agent / Client Taks jetzt ausführen
McAfee Agent --> Produktausbringung --> VWFS MOVE Agent 4.6.0.396

#Gruppe --> zugewiesene Richlinien --> Produkt: Move Antivirus 4.6.0 --> On Access Scan , Show Advanced
#>

#ePO Automation
https://kc.mcafee.com/corporate/index?page=content&id=PD24810

Invoke-Command -ComputerName $IOPI_SQL_PK_HyperVServerNames -ScriptBlock { 
  Get-Service -Name 'McAfeeFramework','macmnsvc','masvc'
} | Sort-Object -Property PSComputerName,Name


#ExclusionList
(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mvagtdrv\Parameters' -Name 'PassThruList').PassThruList
(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mvagtdrv\Parameters' -Name 'ProcessPassthru').ProcessPassthru

#Remove Agent
'C:\Program Files\Mcafee\Agent\'   #For a fresh MA 5.x install: 
 
 
'C:\Program Files\Mcafee\Common Framework\x86\'   #For McAfee Agent 4.8, or an upgraded MA version or
'C:\Program Files (x86)\Mcafee\Common Framework\x86\' #NOTE: MA 4.8 will reach End of Life (EOL) for Windows, Mac, and Linux computers on March 31, 2018. For more information, see KB88098.

#open admin CMD and run
<location of frminst file>\frminst.exe /remove=agent 

"c:\Program Files\Network Associates\Common Framework\frminst.exe" /forceuninstall   #or
"c:\Program Files\McAfee\Common Framework\frminst.exe" /forceuninstall

$McAfee_HyperV_ExclusionList = @"
<?xml version="1.0" encoding="UTF-8"?>
-<epo:EPOPolicySchema xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:epo="mcafee-epo-policy">
  <EPOPolicyVerInfo verbld="0" verrel="0" vermin="9" vermjr="5"/>
  -<EPOPolicySettings param_str="" param_int="0" typeid="DC_Threat_Prevention_Policy_On_Access_Scan" categoryid="DC_Threat_Prevention_Policy_On_Access_Scan" featureid="DC__AM__4000" name="FSAG_HyperV::Settings (5CC5E804-17DE-4440-B1E6-05077CFCDF00)">
    -<Section name="Actions">
      <Setting name="threat-action-1" value="delete-and-quarantine"/>
      <Setting name="threat-action-2" value="deny-access"/>
    </Section>
    -<Section name="Exclusions">
      <Setting name="exclude-path" value="3|15|**\McAfee\Common Framework\||3|15|C:\Clusterstorage\||3|11|C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\||3|15|**\Program Files\McAfee\Agent\||3|11|C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Server\Health Service State\||3|11|C:\ProgramData\Microsoft\Windows\Hyper-V\Snapshots\||3|11|C:\ProgramData\Microsoft\Windows\Hyper-V\||3|15|**\SoftwareDistribution\||3|11|%program_files%\system center operations manager 2007\health service state\health service store\||3|11|C:\Program Files\System Center Operations Manager\Gateway\Health Service State\||3|11|**\Registry.pol||3|11|%program_files%\microsoft monitoring agent\agent\health service state\||3|11|**\NTUser.pol||3|15|q:\||3|15|%windir%\Cluster\||3|11|c:\pagefile.sys||3|15|d:\shares\library\||3|11|*.DIT||3|11|*.CON||3|11|*.WSB||3|11|*.ISO||3|11|*.AVHD||3|11|*.JRS||3|11|*.LDF||3|11|*.?YI||3|11|*.NDF||3|11|*.TRN||3|11|*.VHDX||3|11|*.MDF||3|11|*.VHD||3|11|*.VSV||3|11|*.?DB||3|11|*.BLG||3|11|*.00?||3|11|*.DB?||3|11|*.log||3|11|*.CHK||3|11|*.sdb||3|11|*.pol||3|11|*.xml||3|11|*.bin||3|11|*.avhdx"/>
      <Setting name="excludepath_1" value="3|15|**\McAfee\Common Framework\"/>
      <Setting name="excludepath_10" value="3|11|C:\Program Files\System Center Operations Manager\Gateway\Health Service State\"/>
      <Setting name="excludepath_11" value="3|11|**\Registry.pol"/>
      <Setting name="excludepath_12" value="3|11|%program_files%\microsoft monitoring agent\agent\health service state\"/>
      <Setting name="excludepath_13" value="3|11|**\NTUser.pol"/>
      <Setting name="excludepath_14" value="3|15|q:\"/>
      <Setting name="excludepath_15" value="3|15|%windir%\Cluster\"/>
      <Setting name="excludepath_16" value="3|11|c:\pagefile.sys"/>
      <Setting name="excludepath_17" value="3|15|d:\shares\library\"/>
      <Setting name="excludepath_18" value="3|11|*.DIT"/>
      <Setting name="excludepath_19" value="3|11|*.CON"/>
      <Setting name="excludepath_2" value="3|15|C:\Clusterstorage\"/>
      <Setting name="excludepath_20" value="3|11|*.WSB"/>
      <Setting name="excludepath_21" value="3|11|*.ISO"/>
      <Setting name="excludepath_22" value="3|11|*.AVHD"/>
      <Setting name="excludepath_23" value="3|11|*.JRS"/>
      <Setting name="excludepath_24" value="3|11|*.LDF"/>
      <Setting name="excludepath_25" value="3|11|*.?YI"/>
      <Setting name="excludepath_26" value="3|11|*.NDF"/>
      <Setting name="excludepath_27" value="3|11|*.TRN"/>
      <Setting name="excludepath_28" value="3|11|*.VHDX"/>
      <Setting name="excludepath_29" value="3|11|*.MDF"/>
      <Setting name="excludepath_3" value="3|11|C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\"/>
      <Setting name="excludepath_30" value="3|11|*.VHD"/>
      <Setting name="excludepath_31" value="3|11|*.VSV"/>
      <Setting name="excludepath_32" value="3|11|*.?DB"/>
      <Setting name="excludepath_33" value="3|11|*.BLG"/>
      <Setting name="excludepath_34" value="3|11|*.00?"/>
      <Setting name="excludepath_35" value="3|11|*.DB?"/>
      <Setting name="excludepath_36" value="3|11|*.log"/>
      <Setting name="excludepath_37" value="3|11|*.CHK"/>
      <Setting name="excludepath_38" value="3|11|*.sdb"/>
      <Setting name="excludepath_39" value="3|11|*.pol"/>
      <Setting name="excludepath_4" value="3|15|**\Program Files\McAfee\Agent\"/>
      <Setting name="excludepath_40" value="3|11|*.xml"/>
      <Setting name="excludepath_41" value="3|11|*.bin"/>
      <Setting name="excludepath_42" value="3|11|*.avhdx"/>
      <Setting name="excludepath_5" value="3|11|C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Server\Health Service State\"/>
      <Setting name="excludepath_6" value="3|11|C:\ProgramData\Microsoft\Windows\Hyper-V\Snapshots\"/>
      <Setting name="excludepath_7" value="3|11|C:\ProgramData\Microsoft\Windows\Hyper-V\"/>
      <Setting name="excludepath_8" value="3|15|**\SoftwareDistribution\"/>
      <Setting name="excludepath_9" value="3|11|%program_files%\system center operations manager 2007\health service state\health service store\"/>
      <Setting name="oasexcludepathchunks" value="42"/>
      <Setting name="oasprocesspassthruchunks" value="90"/>
      <Setting name="process-passthru" value="|Microsoft.Exchange.Search.Service.exe|SQLBrowser.exe|EdgeTransport.exe|%WINDIR%\system32\mssfh.exe|ReportingServicesService.exe|%WINDIR%\system32\mssdmn.exe|MediationServerSvc.exe|Microsoft.Exchange.Directory.TopologyService.exe|W3wp.exe|MSExchangeDagMgmt.exe|UmService.exe|MSExchangeMigrationWorkflow.exe|Microsoft.Exchange.Diagnostics.Service.exe|Microsoft.Exchange.Servicehost.exe|Noderunner.exe|UmWorkerProcess.exe|ABServer.exe|MSExchangeHMHost.exe|fms.exe|FileTransferAgent.exe|XmppTGW.exe|ScanningProcess.exe|SQLAgent.exe|mcscript_inuse.exe|OcsAppServerHost.exe|hostcontrollerservice.exe|MSExchangeDelivery.exe|RTCSrv.exe|masvc.exe|ParserServer.exe|ComplianceService.exe|ASMCUSvc.exe|SQLServr.exe|macmnsvc.exe|MSExchangeHMWorker.exe|inetinfo.exe|Microsoft.Exchange.EdgeCredentialSvc.exe|%WINDIR%\system32\mssearch.exe|MSExchangeThrottling.exe|ReplicaReplicatorAgent.exe|Microsoft.Exchange.Store.Worker.exe|MSExchangeRepl.exe|AVMCUSvc.exe|rhs.exe|Microsoft.Exchange.RPCClientAccess.Service.exe|Microsoft.Exchange.UM.CallRouter.exe|%WINDIR%\system32\winfs\winfs.exe|Microsoft.Exchange.ProtectedServiceHost.exe|ClsAgent.exe|DataMCUSvc.exe|HealthAgent.exe|MasterReplicatorAgent.exe|mcshield.exe|MRASSvc.exe|MSExchangeFrontendTransport.exe|MSExchangeTransport.exe|Microsoft.Exchange.ContentFilter.Wrapper.exe|TranscodingService.exe|macompatsvc.exe|mctray.exe|%WINDIR%\system32\searchindexer.exe|ccmexec.exe|ChannelService.exe|UpdateService.exe|XmppProxy.exe|Microsoft.Exchange.AntispamUpdateSvc.exe|MSExchangeTransportLogSearch.exe|Microsoft.Exchange.EdgeSyncSvc.exe|updaterui.exe|IMMCUSvc.exe|LysSvc.exe|Vmwp.exe|smsexec.exe|MSExchangeMailboxReplication.exe|MediaRelaySvc.exe|ReplicationApp.exe|UserProfileManager.exe|MSExchangeSubmission.exe|RtcHost.exe|ScanEngineTest.exe|Dsamain.exe|Vmms.exe|MSExchangeMailboxAssistants.exe|DataProxy.exe|Microsoft.Exchange.Store.Service.exe|clussvc.exe|Vmmservice.exe|Vmmagent.exe|VmmAdminUi.exe"/>
      <Setting name="processpassthru_1" value=""/>
      <Setting name="processpassthru_10" value="W3wp.exe"/>
      <Setting name="processpassthru_11" value="MSExchangeDagMgmt.exe"/>
      <Setting name="processpassthru_12" value="UmService.exe"/>
      <Setting name="processpassthru_13" value="MSExchangeMigrationWorkflow.exe"/>
      <Setting name="processpassthru_14" value="Microsoft.Exchange.Diagnostics.Service.exe"/>
      <Setting name="processpassthru_15" value="Microsoft.Exchange.Servicehost.exe"/>
      <Setting name="processpassthru_16" value="Noderunner.exe"/>
      <Setting name="processpassthru_17" value="UmWorkerProcess.exe"/>
      <Setting name="processpassthru_18" value="ABServer.exe"/>
      <Setting name="processpassthru_19" value="MSExchangeHMHost.exe"/>
      <Setting name="processpassthru_2" value="Microsoft.Exchange.Search.Service.exe"/>
      <Setting name="processpassthru_20" value="fms.exe"/>
      <Setting name="processpassthru_21" value="FileTransferAgent.exe"/>
      <Setting name="processpassthru_22" value="XmppTGW.exe"/>
      <Setting name="processpassthru_23" value="ScanningProcess.exe"/>
      <Setting name="processpassthru_24" value="SQLAgent.exe"/>
      <Setting name="processpassthru_25" value="mcscript_inuse.exe"/>
      <Setting name="processpassthru_26" value="OcsAppServerHost.exe"/>
      <Setting name="processpassthru_27" value="hostcontrollerservice.exe"/>
      <Setting name="processpassthru_28" value="MSExchangeDelivery.exe"/>
      <Setting name="processpassthru_29" value="RTCSrv.exe"/>
      <Setting name="processpassthru_3" value="SQLBrowser.exe"/>
      <Setting name="processpassthru_30" value="masvc.exe"/>
      <Setting name="processpassthru_31" value="ParserServer.exe"/>
      <Setting name="processpassthru_32" value="ComplianceService.exe"/>
      <Setting name="processpassthru_33" value="ASMCUSvc.exe"/>
      <Setting name="processpassthru_34" value="SQLServr.exe"/>
      <Setting name="processpassthru_35" value="macmnsvc.exe"/>
      <Setting name="processpassthru_36" value="MSExchangeHMWorker.exe"/>
      <Setting name="processpassthru_37" value="inetinfo.exe"/>
      <Setting name="processpassthru_38" value="Microsoft.Exchange.EdgeCredentialSvc.exe"/>
      <Setting name="processpassthru_39" value="%WINDIR%\system32\mssearch.exe"/>
      <Setting name="processpassthru_4" value="EdgeTransport.exe"/>
      <Setting name="processpassthru_40" value="MSExchangeThrottling.exe"/>
      <Setting name="processpassthru_41" value="ReplicaReplicatorAgent.exe"/>
      <Setting name="processpassthru_42" value="Microsoft.Exchange.Store.Worker.exe"/>
      <Setting name="processpassthru_43" value="MSExchangeRepl.exe"/>
      <Setting name="processpassthru_44" value="AVMCUSvc.exe"/>
      <Setting name="processpassthru_45" value="rhs.exe"/>
      <Setting name="processpassthru_46" value="Microsoft.Exchange.RPCClientAccess.Service.exe"/>
      <Setting name="processpassthru_47" value="Microsoft.Exchange.UM.CallRouter.exe"/>
      <Setting name="processpassthru_48" value="%WINDIR%\system32\winfs\winfs.exe"/>
      <Setting name="processpassthru_49" value="Microsoft.Exchange.ProtectedServiceHost.exe"/>
      <Setting name="processpassthru_5" value="%WINDIR%\system32\mssfh.exe"/>
      <Setting name="processpassthru_50" value="ClsAgent.exe"/>
      <Setting name="processpassthru_51" value="DataMCUSvc.exe"/>
      <Setting name="processpassthru_52" value="HealthAgent.exe"/>
      <Setting name="processpassthru_53" value="MasterReplicatorAgent.exe"/>
      <Setting name="processpassthru_54" value="mcshield.exe"/>
      <Setting name="processpassthru_55" value="MRASSvc.exe"/>
      <Setting name="processpassthru_56" value="MSExchangeFrontendTransport.exe"/>
      <Setting name="processpassthru_57" value="MSExchangeTransport.exe"/>
      <Setting name="processpassthru_58" value="Microsoft.Exchange.ContentFilter.Wrapper.exe"/>
      <Setting name="processpassthru_59" value="TranscodingService.exe"/>
      <Setting name="processpassthru_6" value="ReportingServicesService.exe"/>
      <Setting name="processpassthru_60" value="macompatsvc.exe"/>
      <Setting name="processpassthru_61" value="mctray.exe"/>
      <Setting name="processpassthru_62" value="%WINDIR%\system32\searchindexer.exe"/>
      <Setting name="processpassthru_63" value="ccmexec.exe"/>
      <Setting name="processpassthru_64" value="ChannelService.exe"/>
      <Setting name="processpassthru_65" value="UpdateService.exe"/>
      <Setting name="processpassthru_66" value="XmppProxy.exe"/>
      <Setting name="processpassthru_67" value="Microsoft.Exchange.AntispamUpdateSvc.exe"/>
      <Setting name="processpassthru_68" value="MSExchangeTransportLogSearch.exe"/>
      <Setting name="processpassthru_69" value="Microsoft.Exchange.EdgeSyncSvc.exe"/>
      <Setting name="processpassthru_7" value="%WINDIR%\system32\mssdmn.exe"/>
      <Setting name="processpassthru_70" value="updaterui.exe"/>
      <Setting name="processpassthru_71" value="IMMCUSvc.exe"/>
      <Setting name="processpassthru_72" value="LysSvc.exe"/>
      <Setting name="processpassthru_73" value="Vmwp.exe"/>
      <Setting name="processpassthru_74" value="smsexec.exe"/>
      <Setting name="processpassthru_75" value="MSExchangeMailboxReplication.exe"/>
      <Setting name="processpassthru_76" value="MediaRelaySvc.exe"/>
      <Setting name="processpassthru_77" value="ReplicationApp.exe"/>
      <Setting name="processpassthru_78" value="UserProfileManager.exe"/>
      <Setting name="processpassthru_79" value="MSExchangeSubmission.exe"/>
      <Setting name="processpassthru_8" value="MediationServerSvc.exe"/>
      <Setting name="processpassthru_80" value="RtcHost.exe"/>
      <Setting name="processpassthru_81" value="ScanEngineTest.exe"/>
      <Setting name="processpassthru_82" value="Dsamain.exe"/>
      <Setting name="processpassthru_83" value="Vmms.exe"/>
      <Setting name="processpassthru_84" value="MSExchangeMailboxAssistants.exe"/>
      <Setting name="processpassthru_85" value="DataProxy.exe"/>
      <Setting name="processpassthru_86" value="Microsoft.Exchange.Store.Service.exe"/>
      <Setting name="processpassthru_87" value="clussvc.exe"/>
      <Setting name="processpassthru_88" value="Vmmservice.exe"/>
      <Setting name="processpassthru_89" value="Vmmagent.exe"/>
      <Setting name="processpassthru_9" value="Microsoft.Exchange.Directory.TopologyService.exe"/>
      <Setting name="processpassthru_90" value="VmmAdminUi.exe"/>
      <Setting name="publisher-trust-cache-timeout" value="30"/>
      <Setting name="publisher-trust-cert-revocation-check" value="0"/>
      <Setting name="publisher-trust-check-time-validity" value="0"/>
      <Setting name="publisher-trust-enabled" value="true"/>
      <Setting name="publisher-trust-query-timeout" value="2"/>
      <Setting name="type" value="exclude-trusted-publisher"/>
    </Section>
    -<Section name="LinuxExclusions">
      <Setting name="excludepath_1" value="3|15|/var/log/"/>
      <Setting name="excludepath_10" value="3|11|*.NDF"/>
      <Setting name="excludepath_11" value="3|11|*.TRN"/>
      <Setting name="excludepath_12" value="3|11|*.VHDX"/>
      <Setting name="excludepath_13" value="3|11|*.MDF"/>
      <Setting name="excludepath_14" value="3|11|*.VHD"/>
      <Setting name="excludepath_15" value="3|11|*.VSV"/>
      <Setting name="excludepath_16" value="3|11|*.?DB"/>
      <Setting name="excludepath_17" value="3|11|*.BLG"/>
      <Setting name="excludepath_18" value="3|11|*.00?"/>
      <Setting name="excludepath_19" value="3|11|*.DB?"/>
      <Setting name="excludepath_2" value="3|11|*.DIT"/>
      <Setting name="excludepath_20" value="3|11|*.log"/>
      <Setting name="excludepath_21" value="3|11|*.CHK"/>
      <Setting name="excludepath_22" value="3|11|*.sdb"/>
      <Setting name="excludepath_23" value="3|11|*.pol"/>
      <Setting name="excludepath_24" value="3|11|*.xml"/>
      <Setting name="excludepath_25" value="3|11|*.bin"/>
      <Setting name="excludepath_26" value="3|11|*.avhdx"/>
      <Setting name="excludepath_3" value="3|11|*.CON"/>
      <Setting name="excludepath_4" value="3|11|*.WSB"/>
      <Setting name="excludepath_5" value="3|11|*.ISO"/>
      <Setting name="excludepath_6" value="3|11|*.AVHD"/>
      <Setting name="excludepath_7" value="3|11|*.JRS"/>
      <Setting name="excludepath_8" value="3|11|*.LDF"/>
      <Setting name="excludepath_9" value="3|11|*.?YI"/>
      <Setting name="oasexcludepathchunks-linux" value="26"/>
    </Section>
    -<Section name="Performance">
      <Setting name="cache-scan-results-of-filesize-in-mb" value="40"/>
      <Setting name="deferred-scan-timeout1" value="480"/>
      <Setting name="deferred-scan-timeout2" value="900"/>
      <Setting name="deferred-scan-timeout3" value="1800"/>
      <Setting name="deferred-scan-upper-limit1" value="200"/>
      <Setting name="deferred-scan-upper-limit2" value="4096"/>
      <Setting name="oas-deferred-scan-status" value="true"/>
    </Section>
    -<Section name="ftypes">
      <Setting name="default-additional-file-types" value=""/>
      <Setting name="following-only-file-types" value="COM|EXE"/>
      <Setting name="following-only-file-types-linux" value="EXE|COM"/>
      <Setting name="scan-type" value="2"/>
    </Section>
    -<Section name="onAccessScanning">
      <Setting name="genTabScanTimeout" value="45"/>
      <Setting name="identifier" value="02ebf2f6-7d8c-48ef-b868-cd7f18546cf2"/>
      <Setting name="oasStatus" value="enabled"/>
      <Setting name="on-network" value="false"/>
      <Setting name="on-open-for-backup" value="false"/>
      <Setting name="on-read" value="true"/>
      <Setting name="on-write" value="true"/>
    </Section>
    -<Section name="threatDetectionUserMessaging">
      <Setting name="userMessagingChkBoxId" value="false"/>
    </Section>
  </EPOPolicySettings>
  -<EPOPolicyObject typeid="DC_Threat_Prevention_Policy_On_Access_Scan" categoryid="DC_Threat_Prevention_Policy_On_Access_Scan" featureid="DC__AM__4000" name="FSAG_HyperV" editflag="0" serverid="FSDEBSEA4001">
    <description>übernommen vom SEPHyper-V_CE_v0.1</description>
    <PolicySettings>FSAG_HyperV::Settings (5CC5E804-17DE-4440-B1E6-05077CFCDF00)</PolicySettings>
  </EPOPolicyObject>
</epo:EPOPolicySchema>
"@
$McAfee_FSAG_Standard_ExclusionList = @"
<?xml version="1.0" encoding="UTF-8"?>
-<epo:EPOPolicySchema xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:epo="mcafee-epo-policy">
  <EPOPolicyVerInfo verbld="0" verrel="0" vermin="9" vermjr="5"/>
  -<EPOPolicySettings param_str="" param_int="0" typeid="DC_Threat_Prevention_Policy_On_Access_Scan" categoryid="DC_Threat_Prevention_Policy_On_Access_Scan" featureid="DC__AM__4000" name="My Default::Settings (D2CDCC30-D751-42A6-A7C1-81B6D23E6566)">
    -<Section name="Actions">
      <Setting name="threat-action-1" value="delete-and-quarantine"/>
      <Setting name="threat-action-2" value="deny-access"/>
    </Section>
    -<Section name="Exclusions">
      <Setting name="exclude-path" value="3|15|**\McAfee\Common Framework\||3|15|**\Program Files\McAfee\Agent\||3|11|**\Registry.pol||3|11|%program_files%\microsoft monitoring agent\agent\health service state\||3|11|**\NTUser.pol||3|15|**\SoftwareDistribution\||3|11|%program_files%\system center operations manager 2007\health service state\health service store\||3|11|C:\Program Files\System Center Operations Manager\Gateway\Health Service State\||3|11|C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Server\Health Service State\||3|11|*.JRS||3|11|*.LDF||3|11|*.?YI||3|11|*.NDF||3|11|*.TRN||3|11|*.DIT||3|11|*.MDF||3|11|*.?DB||3|11|*.BLG||3|11|*.00?||3|11|*.DB?||3|11|*.CON||3|11|*.log||3|11|*.edb||3|11|*.WSB||3|11|*.CHK"/>
      <Setting name="excludepath_1" value="3|15|**\McAfee\Common Framework\"/>
      <Setting name="excludepath_10" value="3|11|*.JRS"/>
      <Setting name="excludepath_11" value="3|11|*.LDF"/>
      <Setting name="excludepath_12" value="3|11|*.?YI"/>
      <Setting name="excludepath_13" value="3|11|*.NDF"/>
      <Setting name="excludepath_14" value="3|11|*.TRN"/>
      <Setting name="excludepath_15" value="3|11|*.DIT"/>
      <Setting name="excludepath_16" value="3|11|*.MDF"/>
      <Setting name="excludepath_17" value="3|11|*.?DB"/>
      <Setting name="excludepath_18" value="3|11|*.BLG"/>
      <Setting name="excludepath_19" value="3|11|*.00?"/>
      <Setting name="excludepath_2" value="3|15|**\Program Files\McAfee\Agent\"/>
      <Setting name="excludepath_20" value="3|11|*.DB?"/>
      <Setting name="excludepath_21" value="3|11|*.CON"/>
      <Setting name="excludepath_22" value="3|11|*.log"/>
      <Setting name="excludepath_23" value="3|11|*.edb"/>
      <Setting name="excludepath_24" value="3|11|*.WSB"/>
      <Setting name="excludepath_25" value="3|11|*.CHK"/>
      <Setting name="excludepath_3" value="3|11|**\Registry.pol"/>
      <Setting name="excludepath_4" value="3|11|%program_files%\microsoft monitoring agent\agent\health service state\"/>
      <Setting name="excludepath_5" value="3|11|**\NTUser.pol"/>
      <Setting name="excludepath_6" value="3|15|**\SoftwareDistribution\"/>
      <Setting name="excludepath_7" value="3|11|%program_files%\system center operations manager 2007\health service state\health service store\"/>
      <Setting name="excludepath_8" value="3|11|C:\Program Files\System Center Operations Manager\Gateway\Health Service State\"/>
      <Setting name="excludepath_9" value="3|11|C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Server\Health Service State\"/>
      <Setting name="oasexcludepathchunks" value="25"/>
      <Setting name="oasprocesspassthruchunks" value="84"/>
      <Setting name="process-passthru" value="|Microsoft.Exchange.Search.Service.exe|SQLBrowser.exe|EdgeTransport.exe|%WINDIR%\system32\mssfh.exe|ReportingServicesService.exe|%WINDIR%\system32\mssdmn.exe|MediationServerSvc.exe|Microsoft.Exchange.Directory.TopologyService.exe|W3wp.exe|MSExchangeDagMgmt.exe|UmService.exe|MSExchangeMigrationWorkflow.exe|Microsoft.Exchange.Diagnostics.Service.exe|Microsoft.Exchange.Servicehost.exe|Noderunner.exe|UmWorkerProcess.exe|ABServer.exe|MSExchangeHMHost.exe|fms.exe|FileTransferAgent.exe|XmppTGW.exe|ScanningProcess.exe|SQLAgent.exe|mcscript_inuse.exe|OcsAppServerHost.exe|hostcontrollerservice.exe|MSExchangeDelivery.exe|RTCSrv.exe|masvc.exe|ParserServer.exe|ComplianceService.exe|ASMCUSvc.exe|SQLServr.exe|macmnsvc.exe|MSExchangeHMWorker.exe|inetinfo.exe|Microsoft.Exchange.EdgeCredentialSvc.exe|%WINDIR%\system32\mssearch.exe|MSExchangeThrottling.exe|ReplicaReplicatorAgent.exe|Microsoft.Exchange.Store.Worker.exe|MSExchangeRepl.exe|AVMCUSvc.exe|rhs.exe|Microsoft.Exchange.RPCClientAccess.Service.exe|Microsoft.Exchange.UM.CallRouter.exe|%WINDIR%\system32\winfs\winfs.exe|Microsoft.Exchange.ProtectedServiceHost.exe|ClsAgent.exe|DataMCUSvc.exe|HealthAgent.exe|MasterReplicatorAgent.exe|mcshield.exe|MRASSvc.exe|MSExchangeFrontendTransport.exe|MSExchangeTransport.exe|Microsoft.Exchange.ContentFilter.Wrapper.exe|TranscodingService.exe|macompatsvc.exe|mctray.exe|%WINDIR%\system32\searchindexer.exe|ccmexec.exe|ChannelService.exe|UpdateService.exe|XmppProxy.exe|Microsoft.Exchange.AntispamUpdateSvc.exe|MSExchangeTransportLogSearch.exe|Microsoft.Exchange.EdgeSyncSvc.exe|updaterui.exe|IMMCUSvc.exe|LysSvc.exe|smsexec.exe|MSExchangeMailboxReplication.exe|MediaRelaySvc.exe|ReplicationApp.exe|UserProfileManager.exe|MSExchangeSubmission.exe|RtcHost.exe|ScanEngineTest.exe|Dsamain.exe|MSExchangeMailboxAssistants.exe|DataProxy.exe|Microsoft.Exchange.Store.Service.exe"/>
      <Setting name="processpassthru_1" value=""/>
      <Setting name="processpassthru_10" value="W3wp.exe"/>
      <Setting name="processpassthru_11" value="MSExchangeDagMgmt.exe"/>
      <Setting name="processpassthru_12" value="UmService.exe"/>
      <Setting name="processpassthru_13" value="MSExchangeMigrationWorkflow.exe"/>
      <Setting name="processpassthru_14" value="Microsoft.Exchange.Diagnostics.Service.exe"/>
      <Setting name="processpassthru_15" value="Microsoft.Exchange.Servicehost.exe"/>
      <Setting name="processpassthru_16" value="Noderunner.exe"/>
      <Setting name="processpassthru_17" value="UmWorkerProcess.exe"/>
      <Setting name="processpassthru_18" value="ABServer.exe"/>
      <Setting name="processpassthru_19" value="MSExchangeHMHost.exe"/>
      <Setting name="processpassthru_2" value="Microsoft.Exchange.Search.Service.exe"/>
      <Setting name="processpassthru_20" value="fms.exe"/>
      <Setting name="processpassthru_21" value="FileTransferAgent.exe"/>
      <Setting name="processpassthru_22" value="XmppTGW.exe"/>
      <Setting name="processpassthru_23" value="ScanningProcess.exe"/>
      <Setting name="processpassthru_24" value="SQLAgent.exe"/>
      <Setting name="processpassthru_25" value="mcscript_inuse.exe"/>
      <Setting name="processpassthru_26" value="OcsAppServerHost.exe"/>
      <Setting name="processpassthru_27" value="hostcontrollerservice.exe"/>
      <Setting name="processpassthru_28" value="MSExchangeDelivery.exe"/>
      <Setting name="processpassthru_29" value="RTCSrv.exe"/>
      <Setting name="processpassthru_3" value="SQLBrowser.exe"/>
      <Setting name="processpassthru_30" value="masvc.exe"/>
      <Setting name="processpassthru_31" value="ParserServer.exe"/>
      <Setting name="processpassthru_32" value="ComplianceService.exe"/>
      <Setting name="processpassthru_33" value="ASMCUSvc.exe"/>
      <Setting name="processpassthru_34" value="SQLServr.exe"/>
      <Setting name="processpassthru_35" value="macmnsvc.exe"/>
      <Setting name="processpassthru_36" value="MSExchangeHMWorker.exe"/>
      <Setting name="processpassthru_37" value="inetinfo.exe"/>
      <Setting name="processpassthru_38" value="Microsoft.Exchange.EdgeCredentialSvc.exe"/>
      <Setting name="processpassthru_39" value="%WINDIR%\system32\mssearch.exe"/>
      <Setting name="processpassthru_4" value="EdgeTransport.exe"/>
      <Setting name="processpassthru_40" value="MSExchangeThrottling.exe"/>
      <Setting name="processpassthru_41" value="ReplicaReplicatorAgent.exe"/>
      <Setting name="processpassthru_42" value="Microsoft.Exchange.Store.Worker.exe"/>
      <Setting name="processpassthru_43" value="MSExchangeRepl.exe"/>
      <Setting name="processpassthru_44" value="AVMCUSvc.exe"/>
      <Setting name="processpassthru_45" value="rhs.exe"/>
      <Setting name="processpassthru_46" value="Microsoft.Exchange.RPCClientAccess.Service.exe"/>
      <Setting name="processpassthru_47" value="Microsoft.Exchange.UM.CallRouter.exe"/>
      <Setting name="processpassthru_48" value="%WINDIR%\system32\winfs\winfs.exe"/>
      <Setting name="processpassthru_49" value="Microsoft.Exchange.ProtectedServiceHost.exe"/>
      <Setting name="processpassthru_5" value="%WINDIR%\system32\mssfh.exe"/>
      <Setting name="processpassthru_50" value="ClsAgent.exe"/>
      <Setting name="processpassthru_51" value="DataMCUSvc.exe"/>
      <Setting name="processpassthru_52" value="HealthAgent.exe"/>
      <Setting name="processpassthru_53" value="MasterReplicatorAgent.exe"/>
      <Setting name="processpassthru_54" value="mcshield.exe"/>
      <Setting name="processpassthru_55" value="MRASSvc.exe"/>
      <Setting name="processpassthru_56" value="MSExchangeFrontendTransport.exe"/>
      <Setting name="processpassthru_57" value="MSExchangeTransport.exe"/>
      <Setting name="processpassthru_58" value="Microsoft.Exchange.ContentFilter.Wrapper.exe"/>
      <Setting name="processpassthru_59" value="TranscodingService.exe"/>
      <Setting name="processpassthru_6" value="ReportingServicesService.exe"/>
      <Setting name="processpassthru_60" value="macompatsvc.exe"/>
      <Setting name="processpassthru_61" value="mctray.exe"/>
      <Setting name="processpassthru_62" value="%WINDIR%\system32\searchindexer.exe"/>
      <Setting name="processpassthru_63" value="ccmexec.exe"/>
      <Setting name="processpassthru_64" value="ChannelService.exe"/>
      <Setting name="processpassthru_65" value="UpdateService.exe"/>
      <Setting name="processpassthru_66" value="XmppProxy.exe"/>
      <Setting name="processpassthru_67" value="Microsoft.Exchange.AntispamUpdateSvc.exe"/>
      <Setting name="processpassthru_68" value="MSExchangeTransportLogSearch.exe"/>
      <Setting name="processpassthru_69" value="Microsoft.Exchange.EdgeSyncSvc.exe"/>
      <Setting name="processpassthru_7" value="%WINDIR%\system32\mssdmn.exe"/>
      <Setting name="processpassthru_70" value="updaterui.exe"/>
      <Setting name="processpassthru_71" value="IMMCUSvc.exe"/>
      <Setting name="processpassthru_72" value="LysSvc.exe"/>
      <Setting name="processpassthru_73" value="smsexec.exe"/>
      <Setting name="processpassthru_74" value="MSExchangeMailboxReplication.exe"/>
      <Setting name="processpassthru_75" value="MediaRelaySvc.exe"/>
      <Setting name="processpassthru_76" value="ReplicationApp.exe"/>
      <Setting name="processpassthru_77" value="UserProfileManager.exe"/>
      <Setting name="processpassthru_78" value="MSExchangeSubmission.exe"/>
      <Setting name="processpassthru_79" value="RtcHost.exe"/>
      <Setting name="processpassthru_8" value="MediationServerSvc.exe"/>
      <Setting name="processpassthru_80" value="ScanEngineTest.exe"/>
      <Setting name="processpassthru_81" value="Dsamain.exe"/>
      <Setting name="processpassthru_82" value="MSExchangeMailboxAssistants.exe"/>
      <Setting name="processpassthru_83" value="DataProxy.exe"/>
      <Setting name="processpassthru_84" value="Microsoft.Exchange.Store.Service.exe"/>
      <Setting name="processpassthru_9" value="Microsoft.Exchange.Directory.TopologyService.exe"/>
      <Setting name="publisher-trust-cache-timeout" value="30"/>
      <Setting name="publisher-trust-cert-revocation-check" value="0"/>
      <Setting name="publisher-trust-check-time-validity" value="0"/>
      <Setting name="publisher-trust-enabled" value="true"/>
      <Setting name="publisher-trust-query-timeout" value="2"/>
      <Setting name="type" value="exclude-trusted-publisher"/>
    </Section>
    -<Section name="LinuxExclusions">
      <Setting name="excludepath_1" value="3|15|/var/log/"/>
      <Setting name="excludepath_10" value="3|11|*.BLG"/>
      <Setting name="excludepath_11" value="3|11|*.00?"/>
      <Setting name="excludepath_12" value="3|11|*.DB?"/>
      <Setting name="excludepath_13" value="3|11|*.CON"/>
      <Setting name="excludepath_14" value="3|11|*.log"/>
      <Setting name="excludepath_15" value="3|11|*.edb"/>
      <Setting name="excludepath_16" value="3|11|*.WSB"/>
      <Setting name="excludepath_17" value="3|11|*.CHK"/>
      <Setting name="excludepath_2" value="3|11|*.JRS"/>
      <Setting name="excludepath_3" value="3|11|*.LDF"/>
      <Setting name="excludepath_4" value="3|11|*.?YI"/>
      <Setting name="excludepath_5" value="3|11|*.NDF"/>
      <Setting name="excludepath_6" value="3|11|*.TRN"/>
      <Setting name="excludepath_7" value="3|11|*.DIT"/>
      <Setting name="excludepath_8" value="3|11|*.MDF"/>
      <Setting name="excludepath_9" value="3|11|*.?DB"/>
      <Setting name="oasexcludepathchunks-linux" value="17"/>
    </Section>
    -<Section name="Performance">
      <Setting name="cache-scan-results-of-filesize-in-mb" value="40"/>
      <Setting name="deferred-scan-timeout1" value="480"/>
      <Setting name="deferred-scan-timeout2" value="900"/>
      <Setting name="deferred-scan-timeout3" value="1800"/>
      <Setting name="deferred-scan-upper-limit1" value="200"/>
      <Setting name="deferred-scan-upper-limit2" value="4096"/>
      <Setting name="oas-deferred-scan-status" value="true"/>
    </Section>
    -<Section name="ftypes">
      <Setting name="default-additional-file-types" value=""/>
      <Setting name="following-only-file-types" value="COM|EXE"/>
      <Setting name="following-only-file-types-linux" value="EXE|COM"/>
      <Setting name="scan-type" value="2"/>
    </Section>
    -<Section name="onAccessScanning">
      <Setting name="genTabScanTimeout" value="45"/>
      <Setting name="identifier" value="abcb5035-5133-42fc-ad29-132369b93fc4"/>
      <Setting name="oasStatus" value="enabled"/>
      <Setting name="on-network" value="false"/>
      <Setting name="on-open-for-backup" value="false"/>
      <Setting name="on-read" value="true"/>
      <Setting name="on-write" value="true"/>
    </Section>
    -<Section name="threatDetectionUserMessaging">
      <Setting name="userMessagingChkBoxId" value="false"/>
    </Section>
  </EPOPolicySettings>
  -<EPOPolicyObject typeid="DC_Threat_Prevention_Policy_On_Access_Scan" categoryid="DC_Threat_Prevention_Policy_On_Access_Scan" featureid="DC__AM__4000" name="FSAG_Standard" editflag="0" serverid="FSDEBSEA4001">
    <description/>
    <PolicySettings>My Default::Settings (D2CDCC30-D751-42A6-A7C1-81B6D23E6566)</PolicySettings>
  </EPOPolicyObject>
</epo:EPOPolicySchema>
"@