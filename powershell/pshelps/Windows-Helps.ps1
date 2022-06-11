break

#Disable Shutdown Event Tracker
if (!(Test-Path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability") ) {
  New-Item "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability"
}

if ((Get-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability").ShutdownReasonOn -eq 0 ) {
  Set-ItemProperty -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name ShutdownReasonOn -Value 0 -Type DWORD
}
else {
  New-ItemProperty -Type DWord -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -value "0"
}

#IE Dialog beim ersten Start ausschalten (Security Warnung)
Set-ItemProperty -Path "HKLM:Software\Microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -Value 1 -Type DWORD 

#logoff all Users
function Remove-Space([string]$text) {  
  $private:array = $text.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
  [string]::Join(" ", $array) 
}

$quser = quser
foreach ($sessionString in $quser) {
  $sessionString = Remove-Space($sessionString)
  $session = $sessionString.split()
    
  if ($session[0].Equals(">nistuke")) {continue}
  if ($session[0].Equals("USERNAME")) {continue}
  # Use [1] because if the user is disconnected there will be no session ID. 
  $result = logoff $session[1] 
}


#region WASP
#http://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys.aspx
Import-Module "$((get-module isb-toolcollection).ModuleBase)\Resources\wasp.dll"
$null = Select-Window Explorer | Set-WindowActive
Select-Window Explorer | Send-Keys '^+(6)'
Start-Process ncpa.cpl
$null = Select-Window -Title 'Network Connections' | Set-WindowActive
Select-Window -Title 'Network Connections' | Send-Keys '^+(6)'
#endregion WASP
#region GUI
#Setting Mouse Position
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(500,100)
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(618,927)

#InputBox
$null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$name = [Microsoft.VisualBasic.Interaction]::InputBox('Enter Desired Computer Name ')

#MessageBox
$Answer = [Windows.Forms.Messagebox]::Show('Powershell rocks?', [Windows.Forms.MessageboxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Question)
if ($Answer -eq [Windows.Forms.DialogResult]::Yes) {Write-Host 'Yes Powershell rocks'}

$Name = 
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 
$rv = [Microsoft.VisualBasic.Interaction]::MsgBox('Do you want this to happen?', 'YesNoCancel,Exclamation,MsgBoxSetForeground,SystemModal', 'Accept or Deny')
switch ($rv) {
  'Yes'    { "OK, we'll do it!" }
  'No'     { 'Next time maybe...' }
  'Cancel' { 'you cancelled...'}
}
#siehe http://msdn.microsoft.com/en-us/library/x83z1d9f(v=VS.84).aspx

#PropertyGrid
Function Show-Object {
  param
  (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [Object] $InputObject,
    $Title
  )
  if (!$Title) { $Title = "$InputObject" }
  $Form = New-Object System.Windows.Forms.Form
  $Form.Size = New-Object System.Drawing.Size @(600,600)
  $PropertyGrid = New-Object System.Windows.Forms.PropertyGrid
  $PropertyGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
  $Form.Text = $Title
  $PropertyGrid.SelectedObject = $InputObject
  $PropertyGrid.PropertySort = 'Alphabetical'
  $Form.Controls.Add($PropertyGrid)
  $Form.TopMost = $true
  $null = $Form.ShowDialog()
}
Get-Process -Id $pid | Show-Object
$host | Show-Object
Get-Item -Path $pshome\powershell.exe | Show-Object

#Open File Dialog
$null = [reflection.assembly]::loadwithpartialname('System.Windows.Forms')
$openFile = New-Object System.Windows.Forms.OpenFileDialog
$openFile.Filter = 'txt files (*.txt)|*.txt|All files (*.*)|*.*' 
If($openFile.ShowDialog() -eq 'OK') {get-content $openFile.FileName} 

# $file = Open-FileDialog -Title "Select a file" -Directory "D:\install\psscripts" -Filter "Powershell Scripts (*.ps1)|*.ps1"
function Open-FileDialog
{
  param([string]$Title,[string]$Directory,[string]$Filter='All Files (*.*)|*.*')
  [void] [Reflection.Assembly]::LoadWithPartialName( 'System.Windows.Forms' )
  $ofn = New-Object System.Windows.Forms.OpenFileDialog
  $ofn.InitialDirectory = $Directory
  $ofn.Filter = $Filter
  $ofn.Title = $Title
  $outer = New-Object System.Windows.Forms.Form
  $outer.StartPosition = [Windows.Forms.FormStartPosition] 'Manual'
  $outer.Location = New-Object System.Drawing.Point -100, -100
  $outer.Size = New-Object System.Drawing.Size 10, 10
  $outer.add_Shown( {
      $outer.Activate();   
      $ofn.ShowDialog( $outer );   
      $outer.Close(); 
  } )
  $Show =$outer.ShowDialog() 
  return $ofn.FileName
}

#Important note: Dialogs only work correctly when you launch PowerShell with the -STA option! So before you enter and run the code, be sure to open the correct PowerShell environment:
#Powershell -sta
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.windows.forms')
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.DefaultExt = '.ps1'
$dialog.Filter = 'PowerShell-Skripts|*.ps1|All Files|*.*'
$dialog.FilterIndex = 0
$dialog.InitialDirectory = $home
$dialog.Multiselect = $false
$dialog.RestoreDirectory = $true
$dialog.Title = 'Select a script file'
$dialog.ValidateNames = $true
$dialog.ShowDialog()
$dialog.FileName

#To run the selected script, use this line instead:
#& $dialog.FileName
#endregion GUI

Set-WinUserLanguageList -LanguageList en-US

#Out-GridView can show a maximum of 30 columns silently suppresses the rest
1..100 | ForEach-Object { $hash = [Ordered]@{} }{$hash."Column$_" = $_}{ New-Object PSObject -Property $hash} | Out-GridView
##ask to Save Data, 
Get-Process | Where-Object MainWindowTitle | Out-GridView -Title 'Select Program To Kill' -PassThru | ForEach-Object { $_.CloseMainWindow() } 

#Create Folder Selector
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$null = $FolderBrowser.ShowDialog()
$Path = $FolderBrowser.SelectedPath

([System.Guid]::NewGuid()).Guid
#This will create a list of different ways to  create a GUID and shows the result:
[GUID]::NewGuid().ToString('N') 			# 94a5feaffa0848668f055fea268be867
[GUID]::NewGuid().ToString('D')				# 94a5feaf-fa08-4866-8f05-5fea268be867
[GUID]::NewGuid().ToString('B') 			# {94a5feaf-fa08-4866-8f05-5fea268be867}
[GUID]::NewGuid().ToString('P') 			# (94a5feaf-fa08-4866-8f05-5fea268be867)

#Set Mouse Position
$null = [system.Reflection.Assembly]::LoadWithPartialName('Microsoft.Forms')
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(500,100)

#Play System Sound
[System.Console]::Beep()
[System.Console]::Beep(1000,300)
[system.media.systemsounds]::Beep.play()
[system.media.systemsounds]::Asterisk.play()
[system.media.systemsounds]::Exclamation.play()
[system.media.systemsounds]::Hand.play()

#Screen Resolution
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::AllScreens
[System.Windows.Forms.Screen]::PrimaryScreen
[System.Windows.Forms.Screen]::AllScreens | Measure-Object | Select-Object -ExpandProperty Count

#MsgBox im Vordergrund halten
Add-Type -AssemblyName Microsoft.VisualBasic 
[Microsoft.VisualBasic.Interaction]::MsgBox('My message','YesNo,MsgBoxSetForeground,Information', 'MyTitle')

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
  InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
  Filter = 'Documents (*.docx)|*.docx|SpreadSheet (*.xlsx)|*.xlsx'
  Multiselect = $true
}
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileNames

