break

#Get-VMName from BackupCatalog
$BackupPath = (Get-ChildItem 'C:\Daten\HVBackup')
foreach ($File in $BackupPath.GetEnumerator()) {
  if ($file.Name.Contains('Writer')) {
    # we have a file with VSS writer info, now parse it
    $xml = New-Object -Typename XML
    $xml.load($File.FullName)
    # get the writer's friendly name
    $WriterName = ($xml.WRITER_METADATA.IDENTIFICATION.friendlyName)
    if ($WriterName.Contains('Hyper-V')) {
      # we have a Hyper-V writer file, now get the file group information
      $FileGroup = ($xml.WRITER_METADATA.BACKUP_LOCATIONS.FILE_GROUP)
      foreach ($File in $FileGroup) {
        # for VMs, componentName contains the VM's GUID, caption contains its name
        $File.componentName + ': ' + $File.caption
      }
    }
  }
}

