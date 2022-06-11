break

#https://www.gruppenrichtlinien.de/artikel/netzwerktrace-ohne-zusatztools-erzeugen
netsh.exe trace start capture=yes Ethernet.Type = IPv4.Address = 192.168.178.10 tracefile  = c:\temp\mytrace.etl

$filename = "c:\temp\${env:computername}_netsh_trace.etl"
$IPs = "({0},172.25.28.12,172.25.28.11,172.25.28.13,172.25.28.14,172.25.28.15)" -f (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias *).IPAddress 
netsh trace start capture=yes tracefile=$filename maxsize=2048 filemode=circular overwrite=yes report=no correlation=no IPv4.SourceAddress=$IPs IPv4.DestinationAddress=$IPs Ethernet.Type=IPv4

# Diese Dateien können dann bspw. mit dem Microsoft Network Monitor oder dem Microsoft Message Analyzer ausgewertet werden.

net trace stop

###################################################################
netsh.exe interface ip reset  #Zurücksetzen des TCP/IP-Stacks
netsh.exe interface show interface  #Verfügbare Schnittstellen anzeigen
netsh.exe interface ip set address 'Local Area Connection' static 10.40.244.152 255.255.255.192  #Feste IP-Adresse setzen:
netsh.exe interface ip set address 'Local Area Connection' static 10.40.244.152 255.255.255.192 10.40.244.129 1  #Feste IP-Adresse und Gateway setzen:

netsh.exe interface ip set address 'Local Area Connection' static 10.40.244.152 255.255.255.192 #Zwei feste IP-Adressen setzen
netsh.exe interface ip add address 'Local Area Connection' 10.40.244.153 255.255.255.192

netsh.exe interface ip set address name="Local Area Connection" source=dhcp #Dynamische IP-Adresse
netsh.exe winhttp import proxy source=ie  #Im Internet Explorer eingetragenen Proxy systemweit nutzen:

netsh.exe interface ip set dns 'Local Area Connection' static 10.43.225.244
netsh.exe interface ip add dns 'Local Area Connection' 10.43.225.246
netsh.exe interface ip set dns 'Local Area Connection' dhcp

netsh.exe interface set interface name="Local Area Connection" newname="ExampleLan"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
$InterfaceNames = @()
$MgmtInterfaceName = ''
$Interfaces = netsh.exe interface show interface | select-string -Pattern 'Verbunden|Connected'
$Interfaces | % {$InterfaceNames += (($_ -split '  ')[-1]).Trim()}

foreach ($InterfaceName in $InterfaceNames) {
  netsh.exe interface ip set address "$InterfaceName" static 10.40.244.152 255.255.255.192 10.40.244.129 1
  Start-Sleep -Seconds 10
  Write-Host "Start Ping to '10.40.244.175; on Interface: $InterfaceName"
  $PingStatus = Get-WmiObject -Class Win32_Pingstatus -Filter 'Address="10.40.244.175" and Timeout=1000'
  if ($PingStatus.StatusCode -eq 0) {
    netsh.exe interface ip set dns "$InterfaceName" static 10.43.225.244
    netsh.exe interface ip add dns "$InterfaceName" 10.43.225.246
    Write-Host 'Try to Connect SCVMM Prj Library Server FSDTBSY04431 (10.40.244.175)'
    net.exe use z: \\10.40.244.175\SCVMMLibrary /User:zz_acuser
    $MgmtInterfaceName = $InterfaceName
    break
  } Else {
    netsh.exe interface ip set address "$InterfaceName" dhcp
  }
}

'Management Interface: {0}' -f $MgmtInterfaceName
ipconfig.exe | Select-string 'ipv4'