iexplore.exe http://www.powershellmagazine.com/2011/09/28/powershell-v3-ise-and-ise-scripting-model-changes-improvements/ 

New-IseSnippet -Title 'Show Definition' -Description 'Shows command definition' -Text '(Get-Command ).Definition' -CaretOffset 13 
Join-Path (Split-Path $profile.CurrentUserCurrentHost) 'Snippets' 
Get-IseSnippet 
Import-IseSnippet -ModuleSnippetModule -ListAvailable
Import-IseSnippet -Path \\Server01\Public\Snippets -Recurse

#Capture ConsoleScreen:
$psise.CurrentPowerShellTab.Output.Text  #(ISE v2)
$psise.CurrentPowerShellTab.ConsolePane.Text  #(ISE v3)

Get-IseSnippet
Import-IseSnippet -Path 'C:\Temp'
Import-IseSnippet -Path '\\dc1\SharedStorage\snippets' -Recurse
Import-IseSnippet -Module Xyz
New-IseSnippet -Title 'Show Definition' -Description 'Shows command definition' -Text '(Get-Command ).Definition' -CaretOffset 13

Get-IseSnippet | Where-Object Name -like 'Function body*' | Remove-Item
$code = @'
$strDomain = $env:USERDOMAIN
$strDomainUser = $env:USERNAME
$objUser = New-Object System.Security.Principal.NTAccount("$strDomain", "$strDomainUser")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value
'@
New-IseSnippet -Title 'Get-SIDfromDomainUser' -Description 'Retrieve SID from a Domain User in a specified Domain' -Text $code -Force

#List all Shortcuts
$gps = $psISE.GetType().Assembly
$rm = New-Object System.Resources.ResourceManager GuiStrings,$gps
$rs = $rm.GetResourceSet((Get-Culture),$true,$true)
$rs | Where-Object Name -match 'Shortcut\d?$|^F\d+Keyboard' | Sort-Object Value | Format-Table -AutoSize

