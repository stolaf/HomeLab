Function Get-IOPI_NtpTime  {
  <#
      .DESCRIPTION
      Get-Time from NTP Server

      .EXAMPLE
      Get-IOPI_NtpTime -NTPServer '192.168.80.68'
      Get-IOPI_NtpTime -NTPServer '10.43.225.10'
  #>
  [CmdletBinding()]
  param ([string]$NTPServer )

  # Build NTP request packet. We'll reuse this variable for the response packet
  $NTPData    = New-Object byte[] 48  # Array of 48 bytes set to zero
  $NTPData[0] = 27                    # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27

  # Open a connection to the NTP service
  $Socket = New-Object Net.Sockets.Socket ('InterNetwork', 'Dgram', 'Udp' )
  $Socket.SendTimeOut    = 2000  # ms
  $Socket.ReceiveTimeOut = 2000  # ms
  $Socket.Connect($NTPServer, 123 )

  # Make the request
  $Null = $Socket.Send($NTPData )
  $Null = $Socket.Receive($NTPData )
  
  $Socket.Shutdown('Both') # Clean up the connection
  $Socket.Close()

  $Seconds = [BitConverter]::ToUInt32($NTPData[43..40], 0 )  # Extract relevant portion of first date in result (Number of seconds since "Start of Epoch")
  ([datetime]'1/1/1900').AddSeconds($Seconds ).ToLocalTime()   # Add them to the "Start of Epoch", convert to local time zone, and return
} 

$sNTPServer = 'de.pool.ntp.org'

function Get-NTPDateTime ([string] $sNTPServer) {
    $StartOfEpoch=New-Object DateTime(1900,1,1,0,0,0,[DateTimeKind]::Utc)   
    [Byte[]]$NtpData = ,0 * 48
    $NtpData[0] = 0x1B    # NTP Request header in first byte
    $Socket = New-Object Net.Sockets.Socket([Net.Sockets.AddressFamily]::InterNetwork, [Net.Sockets.SocketType]::Dgram, [Net.Sockets.ProtocolType]::Udp)
    $Socket.Connect($sNTPServer,123)
    
    $t1 = Get-Date    # Start of transaction... the clock is ticking...
    [Void]$Socket.Send($NtpData)
    [Void]$Socket.Receive($NtpData)  
    $t4 = Get-Date    # End of transaction time
    $Socket.Close()

    $IntPart = [BitConverter]::ToUInt32($NtpData[43..40],0)   # t3
    $FracPart = [BitConverter]::ToUInt32($NtpData[47..44],0)
    $t3ms = $IntPart * 1000 + ($FracPart * 1000 / 0x100000000)

    $IntPart = [BitConverter]::ToUInt32($NtpData[35..32],0)   # t2
    $FracPart = [BitConverter]::ToUInt32($NtpData[39..36],0)
    $t2ms = $IntPart * 1000 + ($FracPart * 1000 / 0x100000000)

    $t1ms = ([TimeZoneInfo]::ConvertTimeToUtc($t1) - $StartOfEpoch).TotalMilliseconds
    $t4ms = ([TimeZoneInfo]::ConvertTimeToUtc($t4) - $StartOfEpoch).TotalMilliseconds
 
    $Offset = (($t2ms - $t1ms) + ($t3ms-$t4ms))/2
    
    [String]$NTPDateTime = $StartOfEpoch.AddMilliseconds($t4ms + $Offset).ToLocalTime() 

    set-date $NTPDateTime
}

clear

get-date # Get Current Windows Date/Time

set-date "2015-12-2 12:00:00" # Set specific Windows Date/Time

Get-NTPDateTime -sNTPServer $sNTPServer # Get NTP Date/Time and Set Windows Date/Time