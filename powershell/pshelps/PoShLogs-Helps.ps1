break

https://github.com/PoShLog/PoShLog/wiki/Usage

Find-Module -Tag 'PSEdition_Core' -Name '*Log*'
Install-Module -Name 'PoShLog' -Repository 'PSGallery' -Scope CurrentUser
Import-Module -Name 'PoShLog'

Start-Logger -FilePath 'C:\Temp\my_awesome.log' -Console

Write-InfoLog 'Hurrray, my first log message'
Write-ErrorLog 'Oops, error occurred!'

# Don't forget to close the logger
Close-Logger
