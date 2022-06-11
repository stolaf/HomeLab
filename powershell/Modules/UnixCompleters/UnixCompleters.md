# UnixCompleters
http://www.maxtblog.com/2020/07/getting-started-unixcompleters-module-for-powershell-in-linux/

## Installation
```powershell
Install-Module -Name Microsoft.PowerShell.UnixCompleters

Import-Module Microsoft.PowerShell.UnixCompleters
```

## CmdLets
```powershell
Import-UnixCompleters
Remove-UnixCompleters
Set-UnixCompleter
```

## Usage
After typing the double-dash, press the tab key twice. The list of parameters will show at the bottom of the command:

df --