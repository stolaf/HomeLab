break

Install-Module -Name 'Pode' -Repository PSGallery -Scope AllUsers
Import-Module -Name 'Pode'
Install-Module InvokeBuild -Scope AllUsers
Import-Module -Name 'InvokeBuild'

sdelete -z D: