<#
Find modules/commands used by script
$File = 'C:\Program Files\PowerShell\7\profile.ps1'
& C:\Users\olaf\Documents\PowerShell\Scripts\Get-Commands.ps1 -file $File 
#>


param($file)

$tokens = $null
$err = $null

$file = Resolve-Path $file
$ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$err)
$commands = $ast.FindAll({$true},$true) | Where-Object { $_ -is [System.Management.Automation.Language.CommandAst] } | ForEach-Object { $_.CommandElements[0].Value } | Sort-Object -Unique
$sources = [System.Collections.Generic.List[string]]::new()
$commands | ForEach-Object {
    $c = Get-Command $_ -ErrorAction Ignore
    if ($null -eq $c) {
        Write-Warning "$_ not found"
    }
    else {
        $null = $sources.Add($c.Source)
    }
}

$sources | Sort-Object -Unique

