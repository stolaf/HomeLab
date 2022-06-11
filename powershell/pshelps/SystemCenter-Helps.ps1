function Get-SysCtrTechPreviewVHDs {
  # Download SC Technical Preview VHD Eval SystemCenter 2015
  #
  # http://vniklas.djungeln.se/2014/10/12/download-sysctr-tech-preview-vhds-with-powershell/
  [CmdletBinding()]
  param([switch]$SCVMM,[switch]$SCOM,[switch]$SCDPM,[switch]$SCORCH,[switch]$SCSM,[switch]$All,[string]$Dest="$Env:USERPROFILE\Downloads\VHDEVAL")
  
  # Check if the folder exists
  if(!(Get-Item $Dest -ErrorAction SilentlyContinue)){New-Item -Path $Dest -ItemType Directory}
  
  # SCVMM
  if($SCVMM -or $All){
    ((Invoke-WebRequest -Uri 'http://www.microsoft.com/en-us/download/confirmation.aspx?id=44306' -UseBasicParsing).links |
    Where-Object  -Property href -Match  -Value "exe$|docx$|bin$").href | Select-Object -Unique | ForEach-Object -Process { Start-BitsTransfer -Source $_ -Destination $Dest }
  }
  # SCOM
  if($SCOM -or $All){
    ((Invoke-WebRequest -Uri 'http://www.microsoft.com/en-us/download/confirmation.aspx?id=44303' -UseBasicParsing).links |
    Where-Object  -Property href -Match  -Value "exe$|docx$|bin$").href | Select-Object -Unique | ForEach-Object -Process { Start-BitsTransfer -Source $_ -Destination $Dest}
  }
  # SCORCH
  if($SCORCH -or $All){
    ((Invoke-WebRequest -Uri 'http://www.microsoft.com/en-us/download/confirmation.aspx?id=44302' -UseBasicParsing).links |
    Where-Object  -Property href -Match  -Value "exe$|docx$|bin$").href | Select-Object -Unique | ForEach-Object -Process { Start-BitsTransfer -Source $_ -Destination $Dest}
  }
  # SCDPM
  if($SCDPM -or $All){
    ((Invoke-WebRequest -Uri 'http://www.microsoft.com/en-us/download/confirmation.aspx?id=44304' -UseBasicParsing).links |
    Where-Object  -Property href -Match  -Value "exe$|docx$|bin$").href | Select-Object -Unique | ForEach-Object -Process { Start-BitsTransfer -Source $_ -Destination $Dest} 
  }
  # SCSM
  if($SCSM -or $All){
    ((Invoke-WebRequest -Uri 'http://www.microsoft.com/en-us/download/confirmation.aspx?id=44305' -UseBasicParsing).links |
    Where-Object  -Property href -Match  -Value "exe$|docx$|bin$").href | Select-Object -Unique | ForEach-Object -Process { Start-BitsTransfer -Source $_ -Destination $Dest}
  }
}
