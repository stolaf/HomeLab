break

# SCCM Teammember mit guten PS Kenntnissen
Maibach, Eric Karl
Caye, Jean

# Checkpoint RuleSet lautet: gaag_sccm-2012

# Repair SCCM Agent
1. Command SFC /SCANNOW
2. Copy below to a .bat file and execute:
net stop wuauserv
net stop bits
timeout /t 2
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 Catroot2.old
timeout /t 5
net start wuauserv
net start bits
3. If above fail, try manually installing using DISM command:
DISM.exe /Online /Add-Package /PackagePath:C:\Windows\ccmcache\1g\Windows10.0-KB4485447-x64.cab  (Please locate and replace the needed patch in windows/ccmcache, easiest way will be looking for the KB number)
4. Lastly, system repair can help:
DISM.exe /Online /Cleanup-Image /NoRestart /RestoreHealth

#Update SCCM Agent
$VMInfo = Get-IOPI_HyperV_VM -VMName 'FSDEBSYDI21009' -ComputerName $IOPI_All_HyperVServerNames 
Connect-IOPI_Mstsc -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -Width 1024 -Height 768
Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerInstallApplication -ArgumentList 'FSAG-ALL-ConfigManager Client Upgrade (5.00.8740.1031)*'


<#
    $All_VMs = Get-IOPI_HyperV_VM -VMName 'FS*' -ComputerName $IOPI_PK_HyperVServerNames 
    $Patch_VMs = $All_VMs | Where-Object {$_.Notes -match 'PROD' -and $_.Notes -notmatch $IOPI_IBA_PROD_VMUpdateExclusion -and $_.State -eq 'Running'}
    $i = 0
    $Patch_VMs | ForEach-Object {
    $i++
    $VMInfo = $_
    Write-Output "$i/$($Patch_VMs.Count): $($VMInfo.VMName) Trigger SecuritySettings"
    Invoke-Command -ComputerName $($VMInfo.FQDN) -Credential $($VMInfo.WinRMCredential) -ScriptBlock $sb_SCCM_TriggerDSCBaseLine -ArgumentList 'FSAG-SRV-CCB-REM-SecuritySettings-OS-WinSrv-Windows Server *-MASTER'
    }
#>

<#  wenn sich Updates nicht installieren lassen (waiting to Install): in Host Datei sicherheitshalber eintragen
    10.40.244.230 FSDEBSY66674.MGMT.FSADM.VWFS-AD FSDEBSY66674
    10.40.244.229 FSDEBSY66673.MGMT.FSADM.VWFS-AD FSDEBSY66673
    10.40.244.238 FSDEBSY66672.MGMT.FSADM.VWFS-AD FSDEBSY66672
    10.40.244.231 FSDEBSY66683.MGMT.FSADM.VWFS-AD FSDEBSY66683 

    ccmcache löschen, restart-service ccmexec, Updates erneut versuchen zu installieren
#>

# C:\Windows\CCM\CIDownloader\DigestStore

#neuer SCCM Agent
explorer "\\fsdebsgv4911\iopi_sources$\Install\Microsoft\System Center 2016\SCCM\SCCM Agent 5.00.8740.1031"

$ComputerName = 'FSDEBSNE0181.t-fs01.vwfs-ad'
$ComputerName = 'FSDEBSNE0171.mgmt.fsadm.vwfs-ad'
$ComputerName = $IOPI_TFS_HyperVServerNames
$ComputerName = $IOPI_INT_HyperVServerNames
$ComputerName = $IOPI_SQL_PK_HyperVServerNames
$ComputerName = $IOPI_SQL_INT_HyperVServerNames
$ComputerName = $IOPI_TFS_HyperVServerNames
$ComputerName = $IOPI_SCCM_PK_HyperVServerNames
$ComputerName = $IOPI_All_HyperVServerNames
$ComputerName = $IOPI_PK_HyperVServerNames
$ComputerName = $IOPI_SCB_HyperVServerNames
Invoke-Command -ComputerName $ComputerName -ScriptBlock $sb_SCCM_GetClientVersion -Credential $myAdminCredential | Sort-Object SCCMClientVersion
Invoke-Command -ComputerName $ComputerName -ScriptBlock $sb_SCCM_GetDSCBaseLineStatus  -Credential $myAdminCredential -ArgumentList 'FSAG-SRV-CCB-MON-SecuritySettings*-MASTER' | ? CIComplianceState -ne 'Compliant' | Sort-Object Name | ft -AutoSize 
Invoke-Command -ComputerName $ComputerName -ScriptBlock $sb_SCCM_GetDSCBaseLineStatus  -Credential $myAdminCredential -ArgumentList 'FSAG-SRV-CCB-REM-SecuritySettings*-MASTER' | ? CIComplianceState -ne 'Compliant' | Sort-Object Name | ft -AutoSize
Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-WmiObject -Namespace 'root\ccm\dcm' -Class 'SMS_DesiredConfiguration'}
Invoke-Command -ComputerName $ComputerName -ScriptBlock $sb_SCCM_TriggerDSCBaseLine -Credential $myAdminCredential -ArgumentList 'FSAG-SRV-CCB-REM-SecuritySettings*-MASTER' 
Invoke-Command -ComputerName $ComputerName -ScriptBlock {"$ENV:COMPUTERNAME ;$((Get-Item -Path 'C:\Windows\ccm-FSAG\Temp').PSIsContainer)"} -Credential $myAdminCredential
Invoke-Command -ComputerName $ComputerName -ScriptBlock {"$ENV:COMPUTERNAME ;$((get-service -name mvagtsvc -ea 0).status)"} -Credential $myAdminCredential 

#Compliance Report: am besten mit Firefox
http://fsdebsy44482.mgmt.fsadm.vwfs-ad:2080/ReportS_SQLDEDWH0P/report/FSAG%20-%20Prod/Update%20Compliance%20Index
http://fsdebsy44482.mgmt.fsadm.vwfs-ad:2080/ReportS_SQLDEDWH0P/report/FSAG%20-%20Prod/Hardening%20(System)/Hardening%20-%20Operational%20-%20System%20Details


#local
c:\windows\ccm-fsag\logs

# SCCM Agent 1710 Version: 5.00.8577.1005
# SCCM Agent 1710 Version: 5.00.8740.1031

#Trigger SMS_DesiredConfiguration FSAG SecuritySettings
$INT_VMs = Get-IOPI_HyperV_VM -VMName '*' -ComputerName $IOPI_INT_HyperVServerNames | Where-Object {$_.Notes -notmatch 'SCCM|ENT|Linux|TFS|Template' -and $_.State -eq 'Running'}

<# UnInstallAgent.cmd
    cls
    @echo off
    pushd %~dp0
    wmic /namespace:\\root\sms path sms_providerlocation get * && echo found ConfigMgr Site - exiting && exit
    echo This script removes all ConfigMgr stuff. Do you want to continue? Press CTRL-C now to exit
    pause>NUL
    Echo uninstalling 2012 Agent...
    start /b %WINDIR%\ccmsetup\logs\ccmsetup.log
    start /wait %WINDIR%\ccmsetup\ccmsetup.exe /uninstall
    Echo removing remains...
    if exist %WINDIR%\System32\ccm rd /s /q %WINDIR%\System32\ccm
    if exist %WINDIR%\System32\ccmsetup rd /s /q %WINDIR%\System32\ccmsetup
    reg delete HKLM\SOFTWARE\Wow6432Node\Microsoft\CCM /f
    reg delete HKLM\SOFTWARE\Wow6432Node\Microsoft\CCMSetup /f
    reg delete HKLM\SOFTWARE\Microsoft\CCM /f
    reg delete HKLM\SOFTWARE\Microsoft\CCM /f
    rem reg delete HKLM\SOFTWARE\Microsoft\sms /f
    reg delete HKCR\Wow6432Node\CLSID\{555B0C3E-41BB-4B8A-A8AE-8A9BEE761BDF} /f
    if exist %WINDIR%\ccm rd /s /q %WINDIR%\ccm
    if exist %WINDIR%\ccmcache rd /s /q %WINDIR%\ccmcache
    if exist %WINDIR%\SMSCFG.INI del /f %WINDIR%\SMSCFG.INI
    del /f /q %WINDIR%\sms*.mif
    sc stop ccmexec>NUL
    SC delete CcmExec>NUL

    %WINDIR%\ccmsetup\logs\ccmsetup.log
#>

#Windows Server 2008R2 falls Updateinstalltion fehlschlägt: fehlt KB2522623-x64  ?

<# wichtie Logfiles
    CAS.log; ContentTransferManager.log; DataTransferService.log; LocationServices.log
    ccmsetup.log
#>
<#
    resolve-dnsname -Name FSDEBSY66672.mgmt.fsadm.vwfs-ad # [10.40.244.238] 
    resolve-dnsname -Name FSDEBSY66673.mgmt.fsadm.vwfs-ad # [10.40.244.229] telnet ok   SMSSLP
    resolve-dnsname -Name FSDEBSY66674.mgmt.fsadm.vwfs-ad # [10.40.244.230] telnet ok
    resolve-dnsname -Name FSDEBSY66683.mgmt.fsadm.vwfs-ad # [10.40.244.231] telnet ok

    Test-NetConnection -ComputerName 'fsdebsy66672.mgmt.fsadm.vwfs-ad' -Port 2080

    telnet  FSDEBSY66673.mgmt.fsadm.vwfs-ad 2080
    route ADD 10.40.244.224 MASK 255.255.255.240 10.41.235.1 /p
    Port 2080 / 2081 / 8530 / 8531 (nur FSDEBSY66672, FSDEBSY66683) / 8531 (nur FSDEBSY66673, FSDEBSY66674)
    für die vollständige SCCM Nutzung müssen noch die Ports 8530/8531 und 10123 freigeschaltet werden.

    \\fsdebsgv4911\iopi_sources$\Install\Microsoft\SystemCenter2012R2\SCCM\ClientInstall\CCMAgentMigration nach C:\Windows\ccm-FSAG kopieren
    Install_Prod_SCCM_Client.bat als admin ausführen

    @"
    ################################################################
    # SCCM
    ################################################################
    10.40.244.238    fsdebsy66672.mgmt.fsadm.vwfs-ad fsdebsy66672 #DP
    10.40.244.229    fsdebsy66673.mgmt.fsadm.vwfs-ad fsdebsy66673 #SCCM-CB MP SUP
    10.40.244.230    fsdebsy66674.mgmt.fsadm.vwfs-ad fsdebsy66674 #SCCM-CB MP SUP
    10.40.244.231    fsdebsy66683.mgmt.fsadm.vwfs-ad fsdebsy66683 #DP

    "@ | clip
    notepad C:\Windows\System32\drivers\etc\hosts
    explorer C:\Windows\System32\drivers\etc
    Read-Host -Prompt 'Press Enter to continue'
    stop-service ccmexec
    stop-service wuauserv
    Remove-Item -Path 'C:\Windows\ccmcache' -Recurse -Force
    start-service wuauserv
    start-service ccmexec
    Start-Process C:\Windows\ccm\scclient.exe
#>
<# 
    #Identify reboot state: http://blog.coretech.dk/kea/dealing-with-reboot-pending-clients-in-configuration-manager-2012/
    Invoke-WmiMethod -Namespace 'ROOT\ccm\ClientSDK' -Class CCM_ClientUtilities -Name DetermineIfRebootPending
  
    2012: Ccmsetup.exe /mp:FSDEBSY44473.mgmt.fsadm.vwfs-ad SMSMP=FSDEBSY44473.mgmt.fsadm.vwfs-ad SMSSITECODE=P01 CCMHTTPPORT=2080 CCMHTTPSPORT=2081 SMSCACHESIZE=10000
    Bitte stellt sicher, daß eure Systeme via TCP-2080, TCP-2081, TCP-8530 und TCP-10123 auf FSDEBSY44473.mgmt.fsadm.vwfs-ad und FSDEBSY44474.mgmt.fadm.vwfs-ad an der Firewall freigeschaltet sind.
    Die Setup-Logs findet ihr dann in %systemroot%\ccmsetup\logs.
    Der ConfigMgr Agent wird nach %systemroot%\ccm installiert - logs findet ihr im Unterverzeichnis "logs".
  
    telnet fsdebsy44473.mgmt.fsadm.vwfs-ad 2080
    Test-NetConnection -ComputerName 'fsdebsy66673.mgmt.fsadm.vwfs-ad' -Port 2080
    route add -p 10.40.244.224 mask 255.255.255.240 10.41.211.1   #10.40.244.224/28=SCCM Netz /28 hat die Maske 255.255.255.240
  
    SCCM MPs Prod: FSDEBSY44473,FSDEBSY44474
    SCCM MPs Dev:  FSDTBSY04574, FSDTBSY04575
  
    ccmsetup.exe /forceinstall /mp:FSDEBSY44474.mgmt.fsadm.vwfs-ad SMSMP=FSDEBSY44474.mgmt.fsadm.vwfs-ad SMSSLP=FSDEBSY44474.mgmt.fsadm.vwfs-ad SMSSITECODE=P01 CCMHTTPPORT=2080 CCMHTTPSPORT=2081 SMSCACHESIZE=10000
#>


#Windows Server 2008 R2 Systeme aufsetzt diesen Hotfix mit als erstes Installieren. Nur mit diesem Hotfix funktioniert SCCM!
. '\\fsdebsgv4911\iopi_sources$\Install\Microsoft\SystemCenter2012R2\SCCM\SCCM_KB2522623\Windows6.1-KB2522623-x64.msu'


# Identify reboot state: http://blog.coretech.dk/kea/dealing-with-reboot-pending-clients-in-configuration-manager-2012/
Invoke-WmiMethod -Namespace 'ROOT\ccm\ClientSDK' -Class CCM_ClientUtilities -Name DetermineIfRebootPending -ComputerName $ComputerName | Select-Object PSComputerName,RebootPending,IngracePeriod

$SCCM_Client = [wmiclass] '\\.\root\ccm:sms_client'
$($SCCM_Client.GetAssignedSite()).sSiteCode
(Get-CimInstance -Namespace 'root\CCM' -Query 'Select * From SMS_Client').ClientVersion
Get-CimInstance -Namespace 'root\CCM' -Query 'Select * From CCM_Client' | Select-Object ClientID,ClientIdChangedate
(Get-WMIObject -Computer $ComputerName -Namespace 'root\CCM\SoftMgmtAgent' -Query 'Select * From CacheConfig' ).Size

Get-WMIObject -Namespace 'root\CCM' -List | Where-Object Name -NotLike '__*' |Select-Object -ExpandProperty Name
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_ClientIdentificationInformation' | Select-Object *
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_ClientSiteMode' | Select-Object *                    
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_Authority' | Select-Object *                           
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_Authority' | Select-Object *                           
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From ClientInfo' | Select-Object *                              
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_ClientSecurityInformation' | Select-Object *           
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_LocalMP' | Select-Object *                             
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_MPProxyInformation' | Select-Object *                  
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_MaintenanceTaskRequests' | Select-Object *             
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_InstalledProduct' | Select-Object *                    
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_UserLogonEvents' | Select-Object *                     
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_Client' | Select-Object *                              
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_PendingSiteAssignment' | Select-Object *               
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_Client' | Select-Object *                              
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_LookupMP' | Select-Object *                            
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_PendingUserAffinity' | Select-Object *                 
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_InstalledComponent' | Select-Object Name,Version                 
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_NetworkProxy' | Select-Object *                        
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_Indication' | Select-Object *                          
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_ClassIndication' | Select-Object *                     
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_ClassDeletion' | Select-Object *                       
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_ClassCreation' | Select-Object *                       
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_ClassModification' | Select-Object *                   
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_InstIndication' | Select-Object *                      
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_InstCreation' | Select-Object *                        
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_InstModification' | Select-Object *                    
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_InstDeletion' | Select-Object *                        
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CIM_Error' | Select-Object *                               
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From MSFT_WmiError' | Select-Object *                           
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From MSFT_ExtendedStatus' | Select-Object *                     
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_Service_Failure' | Select-Object *                     
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_Service_ComponentException' | Select-Object *          
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From SMS_PendingReRegistrationOnSiteReAssignment' | Select-Object *    
Get-WMIObject -Namespace 'root\CCM' -Query 'Select * From CCM_PrvsMethodProvider' | Select-Object *                

