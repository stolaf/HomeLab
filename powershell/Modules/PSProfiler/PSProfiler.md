# PSProfiler
#pwsh 

von Mathias R. Jessen: https://github.com/IISResetMe/PSProfiler

Misst Scriptlaufzeiten

## Installation

```powershell
Install-Module -Name PSProfiler -AllowPrerelease -Force
```

## Usage
```powershell
Import-Module PSProfiler

Measure-Script -Path $profile
Measure-Script -Path $profile -Top 5
measure-script -ScriptBlock {hostname.exe}
```

