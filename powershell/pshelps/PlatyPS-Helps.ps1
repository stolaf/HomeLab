break

Start-Process https://github.com/PowerShell/platyPS

Install-Module -Name platyPS -Scope CurrentUser

Import-Module platyPS

Import-Module -Name '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI' -Force 
New-MarkdownHelp -Module 'IH-IOPI' -OutputFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\docs'

Update-MarkdownHelp '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\docs'

