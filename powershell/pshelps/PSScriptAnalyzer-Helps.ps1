break
# https://technet.microsoft.com/en-us/library/dn948237.aspx?f=255&MSPPError=-2147217396

Import-Module Pester

$scriptAnalyzerRules = Get-ScriptAnalyzerRule
$powerShellFiles = Get-ChildItem '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI' -Recurse -Filter *.ps*1

foreach ($powerShellFile in $powerShellFiles) {
    Describe "File $($powerShellFile) should not produce any PSScriptAnalyzer warnings" {
        
        $analysis = Invoke-ScriptAnalyzer -Path $powerShellFile.FullName   
        
        foreach ($rule in $scriptAnalyzerRules) {
            It "Should pass $rule" {
            
                If ($analysis.RuleName -contains $rule) {
                
                $analysis | Where-Object RuleName -EQ $rule -outvariable failures | Out-Default
                
                $failures.Count | Should Be 0
                
                }
            }
        }
    }
}

##########################################################
Get-Command -Module PSScriptAnalyzer
Get-Module PSScriptAnalyzer -ListAvailable
(Get-ScriptAnalyzerRule).RuleName

Get-ScriptAnalyzerRule -Name PSAvoidUsingCmdletAliases
Get-ScriptAnalyzerRule | out-gridview 

Invoke-ScriptAnalyzer -Path C:\users\test\Documents\demo\Test-Script.ps1 -IncludeRule 'PSAvoidUsingCmdletAliases'

Invoke-ScriptAnalyzer -Path 'C:\Users\Olaf\Documents\WindowsPowerShell\Stagge\Install-MacBook.ps1' -ExcludeRule 'PSAvoidUsingInternalURLs'
Invoke-ScriptAnalyzer -Path D:\test_scripts\Test-Script.ps1 -Severity 'Warning'
Invoke-ScriptAnalyzer -Path D:\test_scripts\Test-Script.ps1 -CustomizedRulePath C:\CommunityAnalyzerRules

#im ModulePath
Invoke-ScriptAnalyzer -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MrDSC" -ExcludeRule PSProvideDefaultParameterValue

Install-Module -Name ISEScriptAnalyzerAddOn -Force
Get-Module -Name ISEScriptAnalyzerAddOn -ListAvailable
