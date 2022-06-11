break

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxyEnable' -Value 1 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxyServer' -Value '10.41.77.154:8080' -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxyOverride' -Value '.vwfs-ad;10.*.*.*;*.local;*.external;web1.collaboration.fs01.vwf.vwfs-ad;*.vwfs-ad;asappgateway;192.*.*.*;169.*.*.*;10.40.*.*;<local>' -Force

$myProxyCredential = Get-Credential -Message 'Input Proxy Credential'
$null = netsh winhttp import proxy source=ie
$webclient = New-Object System.Net.WebClient
$webclient.Proxy.Credentials=$myProxyCredential

#proxy wieder entfernen sonst kein PS Remoting
netsh winhttp reset proxy
netsh winhttp show proxy

'10.41.77.150:8080'   #Proxy Prod
#Ausnahmen
localhost;127.0.0.1;*.t-fs01.vwfs-ad;*.mgmt.fsadm.vwfs-ad;*.fs01.vwf.vwfs-ad;*.quest.com;*.toadsoft.com;fsdebsea0072*

$webClient = new-object System.Net.WebClient 
$webClient.DownloadFile('http://fs-net.fs01.vwf.vwfs-ad:82/vwbank-prod.pac', "c:\Temp\proxy.pac")
notepad "c:\Temp\proxy.pac"

function Update-Proxy {
  <#
      .SYNOPSIS
      Get or set system proxy properties.
      .DESCRIPTION
      This function implements unified method to set proxy system wide settings.
      It sets both WinINET ("Internet Options" proxy) and WinHTTP proxy.
      Without any arguments function will return the current proxy properties.
      To change a proxy property pass adequate argument to the function.
      .EXAMPLE
      Update-Proxy -Server "10.41.77.149:8080" -Override "localhost;10.43.225.20;127.0.0.1;*.t-fs01.vwfs-ad;*.mgmt.fsadm.vwfs-ad;*.fs01.vwf.vwfs-ad;*.quest.com;*.toadsoft.com;fsdebsea0072*" #-ShowGUI
      Set proxy server, clear overrides and show IE GUI.
      .EXAMPLE
      Update-Proxy | Export-CSV proxy;  Import-CSV proxy | Update-Proxy -Verbose
      Save and restore proxy properties
      .EXAMPLE
      $p = Update-Proxy; $p.Override += $p.Override += "*.domain.com" ; $p | proxy
      Add "*.domain.com" to the proxy override list
      .NOTES
      The format of the parameters is the same as seen in Internet Options GUI.
      To bypass proxy for a local network specify keyword ";<local>" at the end
      of the Overide values.
      Setting the winhttp proxy requires administrative prvilegies.
      .OUTPUTS
      [HashTable]
  #>
  [CmdletBinding()]
  param(
    # Proxy:Port
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string] $Server,
    # Semicollon delimited list of exlusions
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string] $Override,
    # 0 to disable, anything else to enable proxy
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string] $Enable,
    # Show Internet Options GUI
    [switch] $ShowGUI
  )

  function refresh-system() {
    $signature = @'
[DllImport("wininet.dll", SetLastError = true, CharSet=CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@

    $INTERNET_OPTION_SETTINGS_CHANGED   = 39
    $INTERNET_OPTION_REFRESH            = 37
    $type = Add-Type -MemberDefinition $signature -Name wininet -Namespace pinvoke -PassThru
    $a = $type::InternetSetOption(0, $INTERNET_OPTION_SETTINGS_CHANGED, 0, 0)
    $b = $type::InternetSetOption(0, $INTERNET_OPTION_REFRESH, 0, 0)
    return $a -and $b
  }

  $key  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $r = Get-ItemProperty $key
  Write-Verbose "Reading proxy data from the registry"
  $proxy=@{
    Server   = if ($PSBoundParameters.Keys -contains 'Server')   {$Server}   else { $r.ProxyServer }
    Override = if ($PSBoundParameters.Keys -contains 'Override') {$Override} else { $r.ProxyOverride }
    Enable   = if ($PSBoundParameters.Keys -contains 'Enable')   {$Enable}   else { $r.ProxyEnable }
  }

  $set  = "Server","Override","Enable" | ? {$PSBoundParameters.Keys -contains $_ }
  if ($set) {
    #if (!(test-admin)) { throw "Setting proxy requires admin privileges" }

    Write-Verbose "Saving proxy data to registry"

    Set-ItemProperty $key ProxyServer   $proxy.Server
    Set-ItemProperty  $key ProxyOverride $proxy.Override
    Set-ItemProperty  $key ProxyEnable   $proxy.Enable
    if (!(refresh-system)) { Write-Warning "Can not force system refresh after proxy change" }

    Write-Verbose "Importing winhttp proxy from IE settings"
    $OFS = "`n"
    [string]$res = netsh.exe winhttp import proxy source=ie
    if ($res -match 'Access is denied') {Write-Warning $res}
    else { Write-Verbose $res.Trim()}
  }

  New-Object PSCustomObject -Property $proxy
  if ($ShowGUI) { Start-Process control "inetcpl.cpl,,4" }
}

