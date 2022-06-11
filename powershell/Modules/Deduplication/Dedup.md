# Dedup
http://blogs.technet.com/b/keithmayer/archive/2012/12/12/step-by-step-reduce-storage-costs-with-data-deduplication-in-windows-server-2012.aspx#.UM8HZm-qlks

```powershell
Add-WindowsFeature -name FS-Data-Deduplication
Import-Module Deduplication
Enable-DedupVolume D:
Set-Dedupvolume D: -MinimumFileAgeDays 20
Start-DedupJob -Volume D: -Type Optimization
Get-DedupJob
```

