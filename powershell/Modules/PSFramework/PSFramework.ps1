break 
<# PSFramework von [Friedrich Weinmann](https://github.com/FriedrichWeinmann)

https://psframework.org/  
https://psframework.org/documentation/documents/psframework.html
https://admf.one

PSFramework ModuleVersion 04.12.2021: 1.6.214
#>

Install-Module -Name PSFramework -Scope AllUsers -force
Install-Module -Name PSUtil -Scope AllUsers -force
Import-Module -Name PSUtil
Import-Module -Name PSFramework
Get-Module PSFramework -ListAvailable

# Configuration
# https://psframework.org/documentation/quickstart/psframework.html  
Get-PSFConfig -Module PSFramework
Get-PSFConfig -Module ImportExcel
Set-PSFConfig -FullName PSFramework.Path.Temp -Value 'C:\Temp'
Get-PSFPath -Name Temp
Get-PSFPath -Name LocalAppData
Set-PSFConfig -FullName PSFramework.Logging.LogFile.CsvDelimiter -Value ';'
Get-PSFConfig -FullName PSFramework.Logging.LogFile.CsvDelimiter
Set-PSFConfig -FullName PSFramework.Logging.LogFile.CsvDelimiter -Value ';' -PassThru | Register-PSFConfig   # dauerhaft für alle neuen Sessions

Get-PSFConfig -Module PSFramework | Export-PSFConfig -OutPath C:\Temp\PSFramework.json
code C:\Temp\PSFramework.json
Import-PSFConfig -Path C:\Temp\PSFramework.json 
Get-PSFConfig 
Get-PSFConfigValue -FullName psframework.logging.filesystem.logpath # | Invoke-Item

Set-PSFConfig -Module MyModule -Name Path.ExportPath -Value "C:\Export" 
Get-PSFConfig -Module myModule | Export-PSFConfig -OutPath C:\Temp\myModule.json

## Logging 
<#
- Umgebungsspezifisch
- Parallelisieren == Lock / Konflikt
- Metainformation
https://psframework.org/documentation/quickstart/psframework/logging.html
https://psframework.org/documentation/documents/psframework/logging.html
https://psframework.org/documentation/documents/psframework/logging/basics/writing-messages.html
#>

Get-PSFLoggingProvider

Write-PSFMessage -Level Host -Message "Message visible to the user"
Write-PSFMessage -Level Debug -Message "Very well hidden message"
Write-PSFMessage -Level Warning -Message "Warning Message"

Get-PSFMessage   # Standardmäßig wird in Arbeitsspeicher geloggt
$msg = Get-PSFMessage |Select -last 1
$msg | fl *
Get-PSFRunspace  # dieser Runspace bearbeitet das Logging, chronologisch in der richtigen Reihenfolge

$paramSetPSFLoggingProvider = @{ 
    Name = 'logfile' 
    InstanceName = 'Testlog' 
    FilePath = 'C:\Temp\TaskName-%Date%.csv' 
    Enabled = $true 
}
Set-PSFLoggingProvider @paramSetPSFLoggingProvider

$paramSetPSFLoggingProvider = @{
    Name = 'logfile' 
    InstanceName = '<backup.docker-01>' 
    FilePath = 'C:\Scripts\Scheduled.Tasks\TaskName-%Date%.log' 
    FileType = 'CMTrace' 
    Enabled = $true 
} 
Set-PSFLoggingProvider @paramSetPSFLoggingProvider

Write-PSFMessage -Message "Test Message"  # Verbose
Write-PSFMessage -Level Host -Message "Message visible to the user" # Host
Write-PSFMessage -Level Debug -Message "Very well hidden message"  # Debug
Write-PSFMessage -Level Warning -Message "Warning Message" # Warning

Set-PSFLoggingProvider -Name logfile -InstanceName MyDemo -FilePath C:\temp\mylog.csv -Enabled $true
Get-PSFConfigValue PSFramework.Logging.FileSystem.LogPath

Write-PSFMessage -Level Verbose   -Message "Test Message" 
Write-PSFMessage -Level Host -Message "Message visible to the user"  
Write-PSFMessage -Level Debug -Message "Very well hidden message" 
Write-PSFMessage -Level Warning -Message "Warning Message" 
Write-PSFMessage -Level Error -Message "Die Welt brennt und mein Bier ist leer" -Tag beer, Catastrophe -Target Bierkrug

$setPSFLoggingProviderSplat = @{
    Name = 'logfile'
    InstanceName = 'MyDemo2'
    IncludeTags = 'error'
    Enabled = $true
    FilePath = 'C:\temp\mylog-%date%.json'
    FileType = 'json'
    UTC = $true
    Headers = 'Timestamp', 'Message', 'Tags', 'Target', 'Data'
    LogRotatePath = "C:\Temp\mylog-*.json"
    JsonCompress = $true
    JsonNoComma = $true
}
Set-PSFLoggingProvider @setPSFLoggingProviderSplat
Set-PSFLoggingProvider -FileType 

# Shift+Alt+S
Set-PSFLoggingProvider -Name logfile -InstanceName MyDemo2 -FilePath C:\temp\mylog-%date%.json -IncludeTags error -FileType json -UTC $true -Headers 'Timestamp', 'Message', 'Tags', 'Target', 'Data' -LogRotatePath "C:\Temp\mylog-*.json" -JsonCompress $true -JsonNoComma $true -Enabled $true

Write-PSFMessage -Level Warning -Message "Bier ist immer noch leer" -Tag error
Write-PSFMessage -Level Warning -Message "Bier ist immer noch leer" -Tag error -Data @{
    Brand = "Hofbräu"
    Level = "Kritisch"
}
Write-PSFMessage -Level Host -Message "Bier wieder voll"
Get-PSFLoggingProviderInstance
code C:\Temp\mylog-2021-12-04.json
Get-PSFConfig *logfile* # es werden die Parameter der  myDemo2 Instance verwendet

# License
Get-PSFLicense

# Select-PSFObject
dir c:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize' | sort Size
$res = dir c:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize' | sort Size
$res[-1].Size   # kann auch Global per Configuration eingestellt werden

dir c:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize', 'LastWriteTime.Year as Year'
dir c:\windows -File | Select-PSFObject Name, 'Length as Size to PSFSize', 'LastWriteTime.Year as Year', 'LastWriteTime.ToString("yyyy-MM-dd") as LastWriteTime'

$file1 = dir C:\Windows -File
$file2 = dir C:\Windows -File
$file1 | Select-PSFObject Name,LastWriteTime, "Length from file2 where Name = Name"  # like sql syntax

# ConvertFrom-PSFArray
$object = [PSCustomObject]@{
    Name = 'Olaf'
    Zahl = 23,42
}
$object | ConvertTo-Csv
$object | ConvertFrom-PSFArray | ConvertTo-Csv
$object | ConvertFrom-PSFArray -JoinBy ':' | ConvertTo-Csv

# Invoke-PSFProtectedCommand
$path = 'C:\Temp\notexist.txt'
function Remove-File {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        $path
    )
    Invoke-PSFProtectedCommand -Action 'Delete File' -Target $path -ScriptBlock {
        Remove-Item -Path $path -ErrorAction Stop -Confirm:$false
    } -EnableException $true -PSCmdlet $PSCmdlet -RetryCount 3 -RetryWait 1
}
Remove-File -path $path -Verbose

# Module  
# https://psframework.org/documentation/commands/PSModuleDevelopment/Invoke-PSMDTemplate.html
# Creates a project/file from a template.
Install-Module PSModuleDevelopment -Scope CurrentUser
cd C:\Temp
Invoke-PSMDTemplate PSFProject -Name MyProject 

# Alias
Set-Alias Write-Host Write-PSFMessageProxy
Set-Alias Write-Warning Write-PSFMessageProxy
Set-Alias Write-Error Write-PSFMessageProxy
Set-Alias Write-Verbose Write-PSFMessageProxy
Write-Warning Foo
Write-Error 'Das gibts ja gar nicht'
Write-Verbose 'Hi Kumpel'
Get-PSFMessage
Get-PSFMessage | Select-Object -Last 1 | fl *