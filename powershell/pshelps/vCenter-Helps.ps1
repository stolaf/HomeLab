Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
$vCenter_Server = 'fsdebssa0231.fs01.vwf.vwfs-ad'
Connect-VIServer -Server 'fsdebssa0231.fs01.vwf.vwfs-ad' -Credential $MyAdminCredential 
