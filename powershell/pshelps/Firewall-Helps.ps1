break

New-NetFirewallRule

#region CheckPoint
#Domain Join Rules
Admin TerminalServer
D-MGT3505_ADM_TS_T-I  : 10.40.242.14,15,16,21,22
D-MGMT3505_ADM_TS_P-C : 10.40.242.10,11,34,24

D-HN06_AD-RootDomainController
D-HN06_AD-ResDomainController  # diese nicht D-HN06_AD-RootDomainController
gAD-Replication_no_tcphigh

SCCM: Netz VLAN3515  mgt-xx-3515-SC_SCCM_DIST
SCOM: D-MGT2_SCOM2012

Smartlog logt nicht hinter der DC-Firewall, dafür die DC-FW (DataCenter Firewall) 'DE-BS-DC-P-FW1' auswählen /Rechts Klick/Launch on Active Management Server/SmartView Tracker
#endregion CheckPoint

# Copy local FirewallRules to GPO
$CimSession = New-CimSession -ComputerName '<Server mit installierten Roles>'
$DisplayGroup = 'Remote File Server Resource Manager'
Get-NetFirewallRule -DisplayGroup $DisplayGroup -CimSession $CimSession
Get-NetFirewallRule -DisplayGroup $DisplayGroup -CimSession $CimSession | Set-NetFirewallRule -Enabled True

$CimSession = New-CimSession -ComputerName '<Server mit installierten Roles>' -Authentication CredSsp -Credential $myAdminCrential

(Get-GPO -All).DisplayName
Get-GPO -all | Where-Object {$_.DisplayName -like 'test*'} | Remove-GPO -WhatIf

$newGPO = 'Test 1 (Import Firewall Settings)'
New-GPO -Name $newGPO 

$gpoFQDN = (Get-ADDomain).DNSRoot + '\' + $newGPO 
Get-NetFirewallRule -PolicyStore $gpoFQDN  | ft enabled,Display*
$groupDisplayName = 'Remote File Server Resource Manager Management'
Get-NetFirewallRule -DisplayGroup $groupDisplayName  -PolicyStoreSourceType Local -CimSession $CimSession | ft enabled,Display*,store* 
Copy-NetFirewallRule -DisplayGroup $groupDisplayName -PolicyStoreSourceType Local -NewPolicyStore $gpoFQDN -CimSession $CimSession -WhatIf

Get-NetFirewallRule -PolicyStore $gpoFQDN | ft enabled,Display*,store* 
 
######################
$r=Get-NetFirewallRule 
$r.length 
($r | Where-Object enabled -eq 'True').length 
($r | Where-Object enabled -eq 'False').length #oder
($r| Where-Object enabled -eq ([Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetSecurity.Enabled]::True)).length 
($r| Where-Object enabled -eq ([Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetSecurity.Enabled]::False)).length 

Get-NetFirewallServiceFilter -Service dosvc | Get-NetFirewallRule
Get-NetFirewallServiceFilter -Service dosvc | Get-NetFirewallRule | Get-NetFirewallPortFilter

#https://technet.microsoft.com/de-de/library/cc771920(v=ws.10).aspx
#https://technet.microsoft.com/de-de/library/dd734783%28v=ws.10%29.aspx?f=255&MSPPError=-2147217396
netsh.exe advfirewall export 'C:\temp\WFconfiguration.wfw'	
netsh.exe advfirewall reset export 'C:\temp\WFconfiguration.wfw'	
netsh.exe advfirewall import 'C:\temp\WFconfiguration.wfw'
netsh.exe advfirewall show currentprofile
netsh.exe advfirewall show domainprofile   #allprofiles | currentprofile | privateprofile | publicprofile
netsh.exe advfirewall firewall show rule name=all profile=domain
netsh.exe advfirewall firewall show rule name=all
netsh.exe advfirewall set allprofiles state on #off
netsh.exe advfirewall reset
netsh.exe advfirewall set currentprofile logging filename 'C:\temp\pfirewall.log'
netsh.exe advfirewall firewall add rule name="All ICMP V4" dir=in action=allow protocol=icmpv4
netsh.exe advfirewall firewall add rule name="All ICMP V4" dir=in action=block protocol=icmpv4
netsh.exe advfirewall firewall add rule name="Open SQL Server Port 1433" dir=in action=allow protocol=TCP localport=1433
netsh.exe advfirewall firewall delete rule name="Open SQL Server Port 1433" protocol=tcp localport=1433
netsh.exe advfirewall firewall add rule name="Allow Messenger" dir=in action=allow program="C:\programfiles\messenger\msnmsgr.exe"
netsh.exe advfirewall firewall set rule group="remote administration" new enable=yes
netsh.exe advfirewall firewall set rule group="remote desktop" new enable=Yes

Get-ChildItem HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy -Recurse

$Firewall1 = Get-netfirewallrule -Enabled True | Select-Object DisplayName,DisplayGroup,Profile

$Firewall1 = Invoke-Command -ComputerName 'FSDEBSNE0311.mgmt.fsadm.vwfs-ad' -ScriptBlock {Get-Netfirewallrule -Enabled True -Direction Inbound | Where-Object Profile -eq 'Domain'} # | Select DisplayName,DisplayGroup,Profile}
$Firewall2 = Invoke-Command -ComputerName 'FSDEBSNE0312.mgmt.fsadm.vwfs-ad' -ScriptBlock {Get-Netfirewallrule -Enabled True -Direction Inbound | Where-Object Profile -eq 'Domain'} # | Select DisplayName,DisplayGroup,Profile}

$Firewall1 = Invoke-Command -ComputerName 'FSDEBSNE0311.mgmt.fsadm.vwfs-ad' -ScriptBlock {netsh.exe advfirewall firewall show rule name=all profile=domain}
$Firewall2 = Invoke-Command -ComputerName 'FSDEBSNE0312.mgmt.fsadm.vwfs-ad' -ScriptBlock {netsh.exe advfirewall firewall show rule name=all profile=domain}
$Firewall3 = Invoke-Command -ComputerName 'FSDEBSNE0313.mgmt.fsadm.vwfs-ad' -ScriptBlock {netsh.exe advfirewall firewall show rule name=all profile=domain}
$Firewall4 = Invoke-Command -ComputerName 'FSDEBSNE0314.mgmt.fsadm.vwfs-ad' -ScriptBlock {netsh.exe advfirewall firewall show rule name=all profile=domain}

$Firewall1 = Invoke-Command -ComputerName 'FSDEBSNE0311.mgmt.fsadm.vwfs-ad' -ScriptBlock {Show-NetFirewallRule -PolicyStore ActiveStore}
$Firewall2 = Invoke-Command -ComputerName 'FSDEBSNE0313.mgmt.fsadm.vwfs-ad' -ScriptBlock {Show-NetFirewallRule -PolicyStore ActiveStore}

$Firewall2 | Where-Object DisplayName -eq 'Remote Event Monitor (RPC)'
$Firewall1
$Firewall2.Count
Compare-Object -ReferenceObject $Firewall1 -DifferenceObject $Firewall2# -Property DisplayName

Get-WmiObject -ComputerName 'FSDEBSNE0311.mgmt.fsadm.vwfs-ad' -Query 'SELECT * FROM Win32_ComputerSystem'
Get-CimInstance -ComputerName 'FSDEBSNE0311.mgmt.fsadm.vwfs-ad' -Query 'SELECT * FROM Win32_ComputerSystem'

Show-NetFirewallRule -PolicyStore ActiveStore | Select-Object *

$Firewall1 = Get-Netfirewallrule -Enabled True -Direction Inbound | Where-Object Profile -eq 'Domain'

Get-Command -Module NetSecurity