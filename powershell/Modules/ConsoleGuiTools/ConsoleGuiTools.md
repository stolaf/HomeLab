# ConsoleGuiTools
[https://www.youtube.com/watch?v=DpSRW1G2N7Y](https://www.youtube.com/watch?v=DpSRW1G2N7Y "https://www.youtube.com/watch?v=DpSRW1G2N7Y")

```powershell
Install-Module Microsoft.Powershell.ConsoleGuiTools
Import-Module Microsoft.Powershell.ConsoleGuiTools

Get-Process | Out-ConsoleGridView -Title 'Processes' -OutputMode Multiple  # Single |None

($A = Get-ChildItem -Path $PSHome -Recurse) | Out-ConsoleGridView

function killp {
    param ($Process)
    Get-Process | Out-ConsoleGridView -OutputMode Single -Filter $Process | Stop-Process -Id {$_.id}
}
Start-Process Notepad
killp notepad
```

```powershell
code $profile

$profile | Select *
code $profile.AllUsersAllHosts
```