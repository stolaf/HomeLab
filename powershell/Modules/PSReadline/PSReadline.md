# PSReadline

## Beta 2.2
https://devblogs.microsoft.com/powershell/announcing-psreadline-2-2-beta-2-with-dynamic-help/

https://docs.microsoft.com/de-de/powershell/module/psreadline/?view=powershell-7.1

```powershell
Install-Module PSReadLine -AllowPrerelease -Force
```

PSReadLine maps the function ShowCommandHelp to the F1 key.
When the cursor is at the end of a fully expanded cmdlet, pressing F1 displays the help for that cmdlet.
When the cursor is at the end of a fully expanded parameter, pressing F1 displays the help beginning at the parameter.
Pressing the Alt-h key combination provides dynamic help for parameters. The help is shown below the current command line like MenuComplete. The cursor must be at the end of the fully-expanded parameter name when you press the Alt-h key.
To rapidly select and change the arguments of a cmdlet without disturbing your syntax, press Alt-a.

```powershell
$parameters = @{
    Key              = 'F7'
    BriefDescription = 'ShowMatchingHistoryOcgv'
    LongDescription  = 'Show Matching History using Out-ConsoleGridView'
    ScriptBlock      = {
        param($key, $arg)   # The arguments are ignored in this example
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        $history = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems().CommandLine | Select-Object -Unique
      
        # reverse the items so most recent is on top
        [array]::Reverse($history)
  
        $selection = $history | Out-ConsoleGridView -Title "Select History" -OutputMode Single -Filter $line
        if ($selection) {
            [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)

            if ($selection.StartsWith($line)) {
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)
            }
            else {
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selection.Length)
            }
        }
    }
}
Set-PSReadLineKeyHandler @parameters
```

```powershell
Get-Command -Module PSReadline
Get-PSReadLineKeyHandler

[Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems().CommandLine

Import-Module Microsoft.Powershell.ConsoleGuiTools

function ocgv_history {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $selection = $history | Out-ConsoleGridView -Title 'Select Commandline from History' -OutputMode Single -Filter $line
    if ($selection) {
        [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
        if ($selection.StartsWith($line)) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selection.Length)
        }
    }
}
        
$parameters = @{
    Key              = "Shift-F7"
    Briefdescription = 'Show Matching History for all Powershell instances using Out-ConsoleGridview'
    ScriptBlock      = {
        param($key, $arg)
        $history = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems().CommandLine
        [array]::Reverse($history)
        $history | Select-Object -Unique | ocgv_history
    }
}
Set-PSReadLineKeyHandler @parameters

```
