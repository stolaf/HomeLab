#Check the Windows Defender Configuration and Settings:

Get-MpPreference

Set-MpPreference -DisableRealtimeMonitoring $true   #Turn off Windows Defender Real-Time Protection using PowerShell
Set-MpPreference -DisableRealtimeMonitoring $false  #Turn on Windows Defender Real-Time Protection using PowerShell

Set-MpPreference -ExclusionPath 'C:\temp', 'C:\VMs', 'C:\NanoServer'   #Add a File path exclusion
Set-MpPreference -ExclusionProcess 'vmms.exe', 'Vmwp.exe'   #Add process exclusion

function Get-Av {
    $AntiVirusProduct = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct 
    Write-Output '========== Anti Virus Products and Status========== '
    foreach ($avp in $AntiVirusProduct) {
        $avp.displayname
        switch ($avp.productState) { 
            '262144' { $defstatus = 'Up to date' ; $rtstatus = 'Disabled' } 
            '262160' { $defstatus = 'Out of date' ; $rtstatus = 'Disabled' } 
            '266240' { $defstatus = 'Up to date' ; $rtstatus = 'Enabled' } 
            '266256' { $defstatus = 'Out of date' ; $rtstatus = 'Enabled' } 
            '393216' { $defstatus = 'Up to date' ; $rtstatus = 'Disabled' } 
            '393232' { $defstatus = 'Out of date' ; $rtstatus = 'Disabled' } 
            '393488' { $defstatus = 'Out of date' ; $rtstatus = 'Disabled' } 
            '397312' { $defstatus = 'Up to date' ; $rtstatus = 'Enabled' } 
            '397328' { $defstatus = 'Out of date' ; $rtstatus = 'Enabled' } 
            '397584' { $defstatus = 'Out of date' ; $rtstatus = 'Enabled' } 
            '397568' { $defstatus = 'Up to date'; $rtstatus = 'Enabled' }
            '393472' { $defstatus = 'Up to date' ; $rtstatus = 'Disabled' }
            default { $defstatus = 'Unknown' ; $rtstatus = 'Unknown' } 
        }
        Write-Output "Definition status:  $defstatus"
        Write-output "Real-time protection status: $rtstatus" 
    }
    $Defstat = Get-Service windefend
    if ($Defstat.Status -match 'stop') {
        Write-output 'Defender Service is not running' 
    }
}