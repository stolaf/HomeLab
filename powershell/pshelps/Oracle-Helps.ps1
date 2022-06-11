break

#Oracle InstantClient Installation
#Asnsprechpartner: Eduad Bayer
https://apex.fs01.vwf.vwfs-ad/ords/apexprod/f?p=31110:1:7399449704269:::::
Burger Menu / Software / Oracle Instant Client Windows downloaden  (über Firefox)
ZIP in einem beliebigen Ordner entpacken und Pfad Variable ergänzen

instantclient-sqlplus-windows downloaden  (über Firefox)
Du kannst aber mit SQLPLUS username/Passwort@datenbank testen.
. "C:\instantclient_19_6\sqlplus.exe" mercury/...@VWFSEH4P


<# ODP Connection Test

https://www.connectionstrings.com/oracle-data-provider-for-net-odp-net/
http://docs.oracle.com/html/E10927_01/featConnecting.htm
#>

#[System.Reflection.Assembly]::LoadWithPartialName('Oracle.DataAccess') #deprecated: https://msdn.microsoft.com/en-us/library/12xc5368(v=vs.110).aspx
[System.Reflection.Assembly]::Load("Oracle.DataAccess, Version=4.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342")

try {

   $con = New-Object Oracle.DataAccess.Client.OracleConnection("Data Source=vwfswq1e.vwfsag.de;user id=wq_owner; password=owner;Pooling=true;Connection Lifetime=180")

   $con.open()

   "Connected to database: {0} running on host: {1} - Servicename: {2} - Serverversion: {3}" -f `
   $con.DatabaseName, $con.HostName, $con.ServiceName, $con.ServerVersion

}
catch
{
    Write-Error ("Can't open connection: {0}`n{1}" -f `
    $con.ConnectionString, $_.Exception.ToString())
}
finally
{
    if ($con.State -eq 'Open') { $con.close() }
    Read-Host "Enter to continue."
}

