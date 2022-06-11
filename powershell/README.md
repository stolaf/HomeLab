# Powershell

## Links
https://github.com/PowerShell/PowerShell  
https://github.com/PowerShell/PowerShell/releases  

## New Features in Powershell 7
https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-71?view=powershell-7.1

### Chain-Operator
```powershell
# the '&&' operator would execute the right-hand pipeline if the left-hand pipeline succeeded
Get-Process "notepad" && start "https://www.google.de"

# The `||` operator would run the right-hand pipeline if the left-hand pipeline failed.
Get-Process "notepad" || Start-Process notepad
```

