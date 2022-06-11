#Fix Windows Update Errors
Stop-Service wuauserv
Remove-Item 'Env:WINDIR\SoftwareDistribution\Datastore\*' -recurse -force
Remove-Item 'Env:WINDIR\SoftwareDistribution\Download\*' -recurse -force
iexplore.exe www.microsoft.com   # ---> Search "windows update agent" download
Start-Service wuauserv
iexplore.exe www.microsoft.com  # ---> Search  "Microsoft Fix it"  --> Fix it Solution Center --> Install or upgrade software or hardware --> Windows Update
# --> Run now 'Fix the problem with Microsoft Windows Update that is not working"
# In dem Script wird zunächst das passende Modul geladen und anschließend die nicht mehr benötigten Updates bereinigt.
import-module updateservices 
Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles  -CompressUpdates -DeclineExpiredUpdates -DeclineSupersededUpdate

Apply-WindowsUpdates.ps1 -VhdPath .\WS2012_Template.vhdx -MountDir 'c:\temp\mnt' -WsusServerName wsus01 -WsusServerPort 8530 -WsusTargetGroupName 'Windows Server 2012' -WsusContentPath 'c:\WsusContent'
Apply-WindowsUpdates.ps1    # http://www.sepago.de/d/nicholas/2013/06/14/offline-servicing-of-vhds-against-wsus
param (
  [Parameter(Mandatory=$true)][string]$VhdPath,
  [Parameter(Mandatory=$true)][string]$MountDir,
  [Parameter(Mandatory=$true)][string]$WsusServerName,
  [Parameter(Mandatory=$true)][Int32]$WsusServerPort,
  [Parameter(Mandatory=$true)][string]$WsusTargetGroupName,
  [Parameter(Mandatory=$true)][string]$WsusContentPath
)

# Namespace: http://msdn.microsoft.com/en-us/library/microsoft.updateservices.administration%28v=VS.85%29.aspx
$null = [reflection.assembly]::LoadWithPartialName('Microsoft.UpdateServices.Administration')

# Establish connection with WSUS server
# AdminProxy: http://msdn.microsoft.com/de-de/library/microsoft.updateservices.administration.adminproxy_members%28v=vs.85%29.aspx
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($WsusServerName, $False, $WsusServerPort)

# Build an update scope to specify which updates to process
# UpdateScope: http://msdn.microsoft.com/en-us/library/microsoft.updateservices.administration.updatescope_members%28v=vs.85%29.aspx
$UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
# Only approved updates
# ApprovedStates: http://msdn.microsoft.com/en-us/library/microsoft.updateservices.administration.approvedstates%28v=vs.85%29.aspx
$UpdateScope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved
# Only updates which are not installed
# UpdateInstallationStates: http://msdn.microsoft.com/en-us/library/microsoft.updateservices.administration.updateinstallationstates%28v=vs.85%29.aspx
$UpdateScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::NotInstalled
# Select updates released since the first day of the current month
$Now = Get-Date
$UpdateScope.FromArrivalDate = $Now.AddDays(-1 * ($Now.Day - 1))
# Only consider updates approved for the specified computer target group
$TargetGroup = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq $WsusTargetGroupName }
$null = $UpdateScope.ApprovedComputerTargetGroups.Add($TargetGroup)

# Mount VHD file using dism
Dism.exe /Mount-Image /ImageFile:"$VhdPath" /Index:1 /MountDir:"$MountDir"

# Collect updates and process them individually
# IUpdateServer: http://msdn.microsoft.com/de-de/library/microsoft.updateservices.administration.iupdateserver_members%28v=vs.85%29.aspx
# IUpdate: http://msdn.microsoft.com/de-de/library/microsoft.updateservices.administration.iupdate_members%28v=vs.85%29.aspx
$wsus.GetUpdates($UpdateScope) | ForEach {
  Write-Host "Hotfix: $($_.Title)"
  
  # Get the files associated with an update and don't process PSF files
  $_.GetInstallableItems().Files | Where-Object { $_.FileUri.LocalPath -notmatch '.psf' } | ForEach {
    # Substitute the WSUS content path and replace slashes with backslashes
    $FileName = $_.FileUri.LocalPath.Replace('/Content', "$WsusContentPath").Replace('/', '\')
    
    # Make sure that the file really exists
    if (Test-Path "$FileName") {
      Write-Host "  File: $FileName"
      
      # Add the update as an additional package to the mounted VHD file
      Dism.exe /Image:"$MountDir" /Add-Package /PackagePath:"$FileName"
    }
  }
}
