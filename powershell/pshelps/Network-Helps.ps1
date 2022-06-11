break

#statischen ARP Eintrag setzen
New-NetNeighbor -IPAddress 192.168.56.204 -LinkLayerAddress 02-a0-98-e0-21-e7 -InterfaceIndex 13  #MACAdress der NetApp
Remove-NetNeighbor -IPAddress 192.168.56.204

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

function Convert-CIDR_to_Mask {
  param($CIDR)
 ([ipaddress]([uint32]::MaxValue-[math]::Pow(2,32-$CIDR)+1)).IPAddressToString
}

[PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
[IPAddress] '127.0.0.1'
'127.0.0.1' -as [IPAddress]

#WOL Einstellung, ausführen als Admin
Get-NetAdapterPowerManagement -Name Ether*   
Set-NetAdapterPowerManagement -Name Ether* -WakeOnMagicPacket Enabled

#Protokolle an Adapter
Get-NetAdapterBinding
Set-NetAdapterBinding -Name "Ethernet 3" -DisplayName "*(TCP/IPv4)*" -Enabled $true
Enable-NetAdapterBinding bzw. Disable-NetAdapterBinding 

#Macaddress Arithmetik
$MacAddressMinimumLast = Invoke-Command -ComputerName $IOPI_All_HyperVServerNames -ScriptBlock {Hyper-V\Get-VMHost | Select-Object MACAddressMinimum, MACAddressMaximum} | Sort-Object -Property MACAddressMinimum | Select-Object -ExpandProperty MacAddressMinimum -Last 1
$MacAddressMinimum  = "{0:X12}" -f ([int64]("0x$MacAddressMinimumLast") + 0x100)
$MACAddressMaximum = "{0:X12}" -f ([int64]("0x$MacAddressMinimumLast") + 0x1FF)

$MacAddressMinimum 
$MACAddressMaximum 
Hyper-V\Set-VMHost  -MACAddressMinimum $MacAddressMinimum  -MACAddressMaximum $MACAddressMaximum

#MacAddress 02:BF  NLB cluster in unicast mode
$MacAddress = '00:1D:D8:E0:07:84'
$MAC_dec = [int64]("0x$($MacAddress.Replace(':',''))") 
('{0:X12}' -f $MAC_dec).Insert(2,':').Insert(5,':').Insert(8,':').Insert(11,':').Insert(14,':')

$MacAddressHV = "00:1D:D8:E0:07:81"
$MAC_HV_Dec = [int64]("0x$($MacAddressHV.Replace(':',''))") 
$MacAddressVM = "00:1D:D8:E0:07:7A"
$MAC_VM_Dec = [int64]("0x$($MacAddressVM.Replace(':',''))") 

[math]::Abs($MAC_HV_Dec - $MAC_VM_Dec)

#Sort IPAddresses
#start http://www.madwithpowershell.com/2016/03/sorting-ip-addresses-in-powershell-part.html
($VMConfigs_All.Root.VMConfig | Where-Object {$_.VMDetails.Network.VlanID -eq '1280'}).VMDetails.Network.IPv4 | Sort-Object -Property {[Version]$_ } 

#Adapter no DNS Registration
((Get-WmiObject Win32_NetworkAdapter -Filter "NetEnabled=True").GetRelated('Win32_NetworkAdapterConfiguration') | ? IPAddress -eq $Using:IPv4).SetDynamicDNSRegistration($false,$false)

#IP Address on WinPE
[Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) | ForEach-Object {if ($_.IPAddressToString -match '192.168') {Write-Host $_.IPAddressToString}}

#in Server Core disabled Adapter enablen (Enable-Netadapter funktioniert nicht)
$wmi = Get-WmiObject -Class Win32_NetworkAdapter -Filter 'Name LIKE "HP NC552SFP%"'
$Null = $wmi.enable()

#System Proxy setzen
netsh.exe winhttp import proxy source=ie

#WLAN Passwort anzeigen
netsh.exe wlan show profiles 'cs-fb7490ac' key=clear

#CAU Proxy Konfiguration auf allen Clusterknoten als System Konto
#http://www.faq-o-matic.net/2015/01/28/windows-failover-cluster-service-fehler-beim-aktualisieren-einer-smb-freigabe/
# netsh.exe winhttp set proxy <proxy-server:port> '<local>;*.kundendomain.tld;<clusternode1>;<clusternode2>'

PrefixLength;Netzmaske;Anzahl nutzbarer IPv4-Adressen
/8;255.0.0.0;	max. 16.777.214
/12;255.240.0.0;	max. 1.048.574
/16;255.255.0.0;	max. 65.534
/20;255.255.240.0;	max. 4094
/21;255.255.248.0;	max. 2046
/22;255.255.252.0;	max. 1022
/23;255.255.254.0;	max. 510
/24;255.255.255.0;	max. 254
/25;255.255.255.128;max. 126
/26;255.255.255.192;max. 62
/27;255.255.255.224;max. 30
/28;255.255.255.240;max. 14
/29;255.255.255.248;max. 6
/30;255.255.255.252;max. 2
/31;255.255.255.254;Keine
/32;255.255.255.255;Keine

getmac.exe /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header MAC, Transport

#Disable VMQueue in 10GB Netadapter
Get-NetAdapter | Where-Object LinkSpeed -eq '10 Gbps' | Get-NetAdapterAdvancedProperty -DisplayName 'Virtual Machine Queues'
Set-NetAdapterAdvancedProperty -Name 'MGMT 122_00_04' -DisplayName 'Virtual Machine Queues' -DisplayValue 'Disabled'

#function Show-HostsFile
Start-Process -FilePath notepad -ArgumentList "$env:windir\system32\drivers\etc\hosts" -Verb runas

#Get TimeServer
$key = Get-Item -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers'
Foreach ($valuename in $key.GetValueNames()) {if ($valuename -ne '') {$key.GetValue($valuename)}}

#Count Hops to Server PS4
(Test-NetConnection -TraceRoute -ComputerName 'www.contoso.com').traceroute.count 

#Edit Hostfile
Start-Process notepad.exe -ArgumentList \\$ComputerName\admin$\System32\drivers\etc\hosts -Verb RunAs

#IPV6 deaktivieren
Set-NetAdapterBinding -name 'vEthernet (Livemigration)' -ComponentID ms_tcpip6 -Enabled $false

Get-NetAdapter -physical | Where-Object status -eq 'up'

#Metric
Set-NetIPInterface -InterfaceAlias Ethernet -AddressFamily IPv4 -InterfaceMetric 5
Set-NetIPInterface -InterfaceAlias Wi-Fi -AddressFamily IPv4 -InterfaceMetric 1
Get-NetIPInterface
Get-WmiObject -Class Win32_NetworkAdapter -Filter "AdapterType = 'Ethernet 802.3'" | ForEach-Object { $_.GetRelated('Win32_NetworkAdapterConfiguration') } | Select-Object Description, Index, IPEnabled, IPConnectionMetric
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "Index=$index" | Invoke-WmiMethod -Name SetIPConnectionMetric -ArgumentList $metric #reboot!
set-ipmetric -index 7 -metric 200

#NetAdapter PowerManagement
Get-NetAdapter -InterfaceIndex 4 | Set-NetAdapterPowerManagement -WakeOnMagicPacket Enabled -PassThru
$session = New-CimSession -ComputerName edlt
Set-NetAdapterPowerManagement -CimSession $session -name ethernet -ArpOffload Enabled -DeviceSleepOnDisconnect Disabled -NSOffload Enabled -WakeOnMagicPacket Enabled -WakeOnPattern Enabled -PassThru

# http://newyear2006.wordpress.com/2013/11/26/zugriff-auf-wwan-profile-unter-windows-8-per-powershell/
# Zugriff auf WWAN Profile unter Windows 8 
[void][Windows.Networking.Connectivity.NetworkInformation,Windows, ContentType=WindowsRuntime]
[Windows.Networking.Connectivity.NetworkInformation]:: GetConnectionProfiles()
[Windows.Networking.Connectivity.NetworkInformation]:: GetInternetConnectionProfile()

# find which protocols are bound to your network adapters
Get-NetAdapter | Get-NetAdapterBinding | Where-Object enabled -eq $true

Get-NetAdapterStatistics -Name 'Team MGMT' | Select-Object ReceivedBytes, SentBytes,ReceivedDiscardedPackets, ReceivedPacketErrors,OutboundDiscardedPackets, OutboundPacketErrors

$sb = {
  param ([string]$computername)
  Import-Module NetAdapter
  
  $sess = New-CimSession -ComputerName $computername
  $start = Get-NetAdapterStatistics -Name WiFi -CimSession $sess
  
  Start-Sleep -Seconds 60  # 1800 = 30 minutes
  
  $end = Get-NetAdapterStatistics -Name WiFi -CimSession $sess
  Remove-CimSession $sess
  
  New-Object PSObject -Property ([ordered]@{one=1;two=2;three=3}) | Format-Table -auto
  $props = [ordered]@{
    ComputerName = $computername
    ReceivedBytes = $end.ReceivedBytes - $start.ReceivedBytes
    SentBytes = $end.SentBytes - $start.SentBytes
    ReceivedDiscardedPackets = $end.ReceivedDiscardedPackets - $start.ReceivedDiscardedPackets
    ReceivedPacketErrors = $end.ReceivedPacketErrors - $start.ReceivedPacketErrors
    OutboundDiscardedPackets = $end.OutboundDiscardedPackets -$start.OutboundDiscardedPackets
    OutboundPacketErrors = $end.OutboundPacketErrors -$start.OutboundPacketErrors
  }
  New-Object -TypeName PSObject -Property $props
}
Start-Job -ScriptBlock $sb -ArgumentList $env:COMPUTERNAME -Name "netstats-$($env:COMPUTERNAME)"
Receive-Job -Name "netstats-$($env:COMPUTERNAME)"

#ab PS4
Test-NetConnection fsdebsne0502 -CommonTCPPort WINRM   # HTTP, SMB, RDP
Test-NetConnection fsdebsne0502 -TraceRoute
Test-NetConnection www.microsoft.com -TraceRoute
while ($true) {Test-NetConnection fsdebsne0502 -InformationLevel Quiet;Start-Sleep -Seconds 1}

#region Firewall
#Enable Logging
netsh.exe advfirewall set currentprofile logging filename "$env:systemroot\system32\LogFiles\Firewall\pfirewall.log"
netsh.exe advfirewall set currentprofile logging maxfilesize 4096
#netsh.exe advfirewall set currentprofile logging droppedconnections enable
netsh.exe advfirewall set currentprofile logging allowedconnections disable
netsh.exe advfirewall show currentprofile
while ($true){
  Get-Content -Path "$env:systemroot\system32\LogFiles\Firewall\pfirewall.log" -Tail 1
  Start-Sleep -Seconds 5
}

#Servermanager ComputerManagement
Enable-NetFirewallRule -DisplayGroup 'Remote EventLog Management'

#Display Inbound Firewall Rules
Show-NetFirewallRule | Where-Object {$_.enabled -eq 'true' -AND $_.direction -eq 'inbound'} | Select-Object displayname

#Remote Desktop
Get-NetFirewallRule -DisplayName 'Remote Desktop*' | Select-Object DisplayName, Enabled
Get-NetFirewallRule -DisplayName 'Remote Desktop*' | Set-NetFirewallRule -enabled true

New-NetFirewallRule -DisplayName 'Allow Port 80' -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow

#disable Firewall for all Profile
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

Import-Module NetSecurity
New-NetFirewallRule -Name Allow_Ping -DisplayName 'Allow Ping' -Description 'Packet Internet Groper ICMPv4'  -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow 
#endregion Firewall
#region Teaming
New-NetLbfoTeam -Name rz-team01 -TeamMembers rz-intern,rz-intern1 -LoadBalancingAlgorithm TransportPorts -TeamingMode SwitchIndependent 
Get-NetLbfoTeam

#ConvergedSwitch-Team erstellen
New-NetLbfoTeam -Name Team01 -TeamMembers '10GbE #1','10GbE #2' -LoadBalancingAlgorithm HyperVPort -TeamingMode Lacp -Confirm:$false
#Management-Team erstellen
New-NetLbfoTeam -Name Team02 -TeamMembers '1GbE #1','1GbE #2' -LoadBalancingAlgorithm TransportPorts -TeamingMode SwitchIndependent -Confirm:$false

#NIC Teaming
#New-NetLbfoTeam rz-team rz-intern2,rz-intern3
New-NetLbfoTeam rz-team rz-intern,rz-intern3  -TeamingMode Lacp -LoadBalancingAlgorithm HyperVPort

lbfoadmin.exe  
#endregion Teaming
#region WLAN
#Create WiFI Hotspot http://4sysops.com/archives/how-to-share-wi-fi-in-windows-8-with-internet-connection-sharing-ics/
netsh.exe wlan show drivers # verify Hosted network supported says Yes
netsh.exe wlan set hostednetwork mode=allow ssid=cs-hotspot key=12345678 keyUsage=persistent
netsh.exe wlan start hostednetwork
#endregion WLAN

[Net.IPAddress]'10.41.231.1'
[Net.IPAddress]'10.41.231.1' .. '10.41.231.254'

#Renewing All DHCP Leases
([WMIClass]'Win32_NetworkAdapterConfiguration').RenewDHCPLeaseAll().ReturnValue

#Is Connected to Internet
[bool] $HasInternetAccess = ([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet)

$ips = 1..255 | ForEach-Object { "10.10.10.$_" }
$online = Check-Online -computername $ips

#Sort IP Addresses correctly
$iplist = '10.10.10.1', '10.10.10.3', '10.10.10.230'
$iplist | ForEach-Object { [System.Version] $_ } | Sort-Object | ForEach-Object { $_.toString() }

Get-NetAdapter -Name *external* | Get-NetIPAddress
Get-NetAdapterStatistics

#Network Profile
Get-NetAdapter | Get-NetConnectionProfile
Set-NetConnectionProfile -Name guest -NetworkCategory Private

#Get WLAN Adapter
Get-NetAdapter | Where-Object PhysicalMediaType -eq 'Native 802.11'

# removes all IPv4 information from an adapter by name
Remove-NetIPAddress -InterfaceAlias $AdapterName -Confirm:$false
Remove-NetRoute -InterfaceAlias $AdapterName -Confirm:$false -ErrorAction SilentlyContinue	# remove gateway(s)
Set-DNSClientServerAddress -InterfaceAlias $AdapterName -ResetServerAddresses				# clear DNS servers
[Threading.Thread]::Sleep(500)														# give it enough time to remove the IP

New-NetRoute -DestinationPrefix '10.0.0.0/24' -InterfaceIndex 12 -NextHop 192.168.0.1
New-NetRoute -DestinationPrefix '10.40.242.0/27' -InterfaceAlias 'VLAN 1431' -NextHop 
Get-NetRoute | Format-Table 

Set-NetIPInterface -InterfaceAlias RDMA1 -DHCP Disabled 
Remove-NetIPAddress -InterfaceAlias RDMA1 -AddressFamily IPv4 -Confirm:$false 
New-NetIPAddress -InterfaceAlias RDMA1 -IPAddress 192.168.1.10 -PrefixLength 24 -Type Unicast 
Set-DnsClientServerAddress -InterfaceAlias RDMA1 -ServerAddresses 192.168.1.2

$netadapter = Get-NetAdapter -Name Ethernet
netadapter | Set-NetIPInterface -DHCP Disabled
# Configure the IP address and default gateway.
$netadapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress 10.0.1.100 -PrefixLength 24 -Type Unicast -DefaultGateway 10.0.1.1
# Configure the DNS client server IP addresses.
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.0.1.10
netsh.exe interface ip set address name="Ethernet" static 10.0.1.100 255.255.255.0 10.0.1.1 1
netsh.exe interface ip set dns 'Ethernet' static 10.0.1.10

#Check Online fast
function Check-Online {
  param($computername)
  test-connection -count 1 -ComputerName $computername -TimeToLive 5 -asJob | Wait-Job | Receive-Job | Where-Object { $_.StatusCode -eq 0 } | Select-Object -ExpandProperty Address
}

