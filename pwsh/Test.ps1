# Logging: ####################################################################
Import-Module PoshLog
Import-Module PoShLog.Enrichers

$LogFilename = "C:\Temp\Log-$(Get-Date -Format 'yyyy-MM-d').log"

$Logger = New-Logger |`
    Set-MinimumLevel -Value Verbose |`
    Add-EnrichWithProperty -Name UserName -Value $(env:USERNAME).ToLower() |`
    Add-EnrichWithEnvironment -UserName -MachineName |`
    Add-EnrichWithProcessId | Add-EnrichWithProcessName |`
    Add-EnrichWithExceptionDetails |`
    Add-SinkFile -Path $LogFilename -OutputTemplate '{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level}] [{UserName}@{MachineName}] {Message:j}{NewLine}{Exception}' |`
    Add-SinkConsole -OutputTemplate "{Timestamp:HH:mm:ss.fff} [{Level}] {Message:j}{NewLine}{Exception}" | `
    Start-Logger -PassThru


Close-Logger -logger $Logger
