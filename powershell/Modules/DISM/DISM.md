# DISM

Disk Cleanup in Windows Server 2012 (R2) - DISM  https://www.saotn.org/windows-server-2012-r2-disk-cleanup-dism
```powershell
DISM /online /Cleanup-Image /AnalyzeComponentStore
DISM /online /Cleanup-Image /StartComponentCleanup /ResetBase
DISM /online /Cleanup-Image /SPSuperseded
DISM /Online /Cleanup-Image /RestoreHealth #run twice if component store is corrupt

```

