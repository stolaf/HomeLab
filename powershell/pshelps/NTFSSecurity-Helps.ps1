Import-Module NTFSSecurity
<#
\\FSDEBSGV0540\pSRDMZ1VMs
\\FSDEBSGV0540\pSRDMZ2u3VMs
\\FSDEBSGV0540\pSRSCBVMs
\\FSDEBSGV0440\pGFDMZ1VMs
\\FSDEBSGV0440\pGFDMZ2u3VMs
\\FSDEBSGV0440\pGFSCBVMs
#>

[string[]]$VHDs = Get-ChildItem -Path '\\FSDEBSGV0440\pGFDMZ2u3VMs' -Filter '*vhd*' -Recurse | Select-Object -ExpandProperty FullName
# Disable-NTFSAccessInheritance -Path $VHDs
foreach ($VHD in $VHDs) {
   Write-Host $VHD 
   Get-NTFSAccess -Path $VHD | Disable-NTFSAccessInheritance 
   Get-NTFSAccess -Path $VHD | Remove-NTFSAccess 
   Get-NTFSAccess -Path $VHD | Enable-NTFSAccessInheritance 
   Add-NTFSAccess -Path $VHD -Account 'Everyone' -AccessRights FullControl -PropagationFlags InheritOnly
}

