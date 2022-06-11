# PowerShellGet
https://devblogs.microsoft.com/powershell/powershellget-3-0-preview-12-release/
https://github.com/PowerShell/PowerShellGet/blob/master/CHANGELOG.md

Install-Module PowerShellGet -Force -AllowClobber -AllowPrerelease

Find-PSResource -Name * | Sort Version

Find-PSResource -Name IdracRedfishSupport | fl *
Find-PSResource -Name PSLog  | fl *  # Setzt auf PSFramework auf
Find-PSResource -Name PendingReboot | fl *