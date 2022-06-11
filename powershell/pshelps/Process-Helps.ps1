break

function Start-ScriptAsProcess { 
  #Run Script As A Process
  PARAM ($ScriptPath) 
  
  $TestScriptPath = Test-Path $ScriptPath 
  if ($TestScriptPath -eq $false) { 
    do  { 
      Write-Host "There's a problem with the script file path to start. Please reenter the script path." -ForegroundColor Yellow 
      $ScriptPath = Read-Host  
    } 
    while ($TestScriptPath -eq $false) 
  } 
 
  #Separate the script name from path and place into a var 
  $ScriptPathArray = $ScriptPath.Split('\') 
  $PathArrayCount = $ScriptPathArray.count 
  $ScriptName = $ScriptPathArray[$ScriptPathArrayCount - 1] 
  $Trailer = '\' + $ScriptName 
  $ScriptDir = $ScriptPath.Replace($Trailer,'') 
  $ScriptName = '.\' + $ScriptName 
 
  #Collect credentials and parse them for domain 
  $Credential = Get-Credential -Message "PowerShell Script Run As Credentials" 
  $RawUserName = $Credential.UserName 
  if ($RawUserName -match "@") 
  {$Domain = $RawUserName.Split('@')[1]; $User = $RawUserName.Split('@')[0]} 
  if ($RawUserName -match "\\") 
  {$Domain = $RawUserName.Split('\')[0]; $User = $RawUserName.Split('\')[1]} 
     
  $StartArguments = "-command " + $ScriptName 
  $StartArguments = $StartArguments.ToString() 
  $StartFile = "Powershell.exe" 
 
  $RunScriptProcess = New-Object System.Diagnostics.Process 
  $RunScriptProcess.StartInfo.FileName = "PowerShell.exe" 
  $RunScriptProcess.StartInfo.UseShellExecute = $false 
  $RunScriptProcess.StartInfo.Arguments = $StartArguments 
  $RunScriptProcess.StartInfo.Username = $UserName 
  $RunScriptProcess.StartInfo.Password = $Credential.Password 
  $RunScriptProcess.StartInfo.Domain = $Domain 
  $RunScriptProcess.StartInfo.WorkingDirectory = $ScriptDir 
  $RunScriptProcess.StartInfo.Verb = "RunAsUser" 
 
  if ($RunScriptProcess.Start()){$RunScriptProcess.WaitForExit(); "Script $Scriptname has finished."} 
}

#Memory Total Usage
$measure = Get-Process | Measure-Object WS -Sum
("{0:N2}MB " -f ($measure.sum / 1mb))

function Set-WindowStyle {
  #Set-WindowStyle -Style SHOWNORMAL
  #Set-WindowStyle -MainWindowHandle (Get-Process -id $pid).MainWindowHandle -Style SHOW
  param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    $Style = 'SHOW',
    
    [Parameter()] $MainWindowHandle = (Get-Process -id $pid).MainWindowHandle
  )
  $WindowStates = @{
    'FORCEMINIMIZE'   = 11
    'HIDE'            = 0
    'MAXIMIZE'        = 3
    'MINIMIZE'        = 6
    'RESTORE'         = 9
    'SHOW'            = 5
    'SHOWDEFAULT'     = 10
    'SHOWMAXIMIZED'   = 3
    'SHOWMINIMIZED'   = 2
    'SHOWMINNOACTIVE' = 7
    'SHOWNA'          = 8
    'SHOWNOACTIVATE'  = 4
    'SHOWNORMAL'      = 1
  }
    
  $Win32ShowWindowAsync = Add-Type -memberDefinition @"
    [DllImport("user32.dll")] 
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow); 
"@ -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru
    
  $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
  Write-Verbose ("Set Window Style '{1} on '{0}'" -f $MainWindowHandle, $Style)
}
 
#geladene DLL's eines Processes finden
Get-CimInstance -ClassName Win32_Process -Filter "Name='svchost.exe'" | Get-CimAssociatedInstance -Association Cim_ProcessExecutable | Format-Table name,version
function Show-ProcessTree  {            
  [CmdletBinding()]            
  Param()            
  Begin {            
    # Identify top level processes            
    # They have either an identified processID that doesn't exist anymore            
    # Or they don't have a Parentprocess ID at all            
    $allprocess  = Get-CimInstance -Class Win32_process            
    $uniquetop  = ($allprocess).ParentProcessID | Sort-Object -Unique            
    $existingtop =  ($uniquetop | ForEach-Object -Process {$allprocess | Where-Object ProcessId -EQ $_}).ProcessID            
    $nonexistent = (Compare-Object -ReferenceObject $uniquetop -DifferenceObject $existingtop).InPutObject            
    $topprocess = ($allprocess | ForEach-Object -Process {            
        if ($_.ProcessID -eq $_.ParentProcessID){            
          $_.ProcessID            
        }            
        if ($_.ParentProcessID -in $nonexistent) {            
          $_.ProcessID            
        }            
    })            
    # Sub functions            
    # Function that indents to a level i            
    function Get-Indent {            
      Param([Int]$i)            
      $Global:Indent = $null            
      For ($x=1; $x -le $i; $x++) {            
        $Global:Indent += [char]9            
      }            
    }            
    function Get-ChildProcessesById {            
      Param($ID)            
      # use $allprocess variable instead of Get-WmiObject -Class Win32_process to speed up            
      $allprocess | Where-Object { $_.ParentProcessID -eq $ID} | ForEach-Object {            
        Get-Indent $i            
        '{0}{1} {2}' -f $Indent,$_.ProcessID,($_.Name -split '\.')[0]            
        $i++            
        # Recurse            
        Get-ChildProcessesById -ID $_.ProcessID            
        $i--            
      }            
    } # end of function            
  }            
  Process {            
    $topprocess | ForEach-Object {            
      '{0} {1}' -f $_,(Get-Process -Id $_).ProcessName            
      # Avoid processID 0 because parentProcessId = processID            
      if ($_ -ne 0 ) {            
        $i = 1            
        Get-ChildProcessesById -ID $_            
      }            
    }            
  }             
  End {}            
}

$WMIHostProcess = Get-WmiObject -Query "SELECT * FROM win32_service WHERE Name='winmgmt'" | % {Get-WMIObject -Query "SELECT * FROM win32_process WHERE ProcessID='$($_.ProcessId)'"}
'{0:N2}' -f ($($WMIHostProcess.PrivatePageCount) / 1GB)

$proc = Get-CimInstance Win32_Process -Filter "name='powershell_ise.exe'" 
Get-CimAssociatedInstance -InputObject $proc[0] | Select-Object *
Invoke-CimMethod -InputObject $proc[0] -MethodName GetOwner
Get-Process -Name 'chrome.exe' -IncludeUserName  #PS4 elevated

#find Process Threads
$name = 'facebook.exe'
$processHandle = (Get-CimInstance Win32_Process -Filter "Name = '$name'").ProcessId
$Threads = Get-CimInstance -Class Win32_Thread -Filter "ProcessHandle = $processHandle" 
$threads | Select-Object priority, thread*, User*Time, kernel*Time | Out-GridView -Title "The $name process has $($threads.count) threads"
Function Get-ProcessEx {
  param (
    $Name='*',
    $ComputerName,
    $Credential
  )
  $null = $PSBoundParameters.Remove('Name')
  $Name = $Name.Replace('*','%')
  Get-WmiObject -Class Win32_Process @PSBoundParameters -Filter "Name like '$Name'" |
  ForEach-Object {
    $result = $_ | Select-Object Name, Owner, Description, Handle
    $Owner = $_.GetOwner()
    if ($Owner.ReturnValue -eq 2) {
      $result.Owner = 'Access Denied'
    } else {
      $result.Owner = '{0}\{1}' -f ($Owner.Domain, $Owner.User)
    }
    $result
  }
}

#Set Process Priority
$process = Get-Process -Id $pid
$process.PriorityClass = 'BelowNormal'   #'IDLE' | 'BELOW_NORMAL' | 'NORMAL' | 'ABOVE_NORMAL' | 'HIGH_PRIORITY' | 'REALTIME'

#find Last Started Processes
Get-Process | Where-Object { try { (New-Timespan $_.StartTime).TotalMinutes -le 10} catch { $false } }
Get-Process | Where-Object { trap { continue } (New-Timespan $_.StartTime).TotalMinutes -le 10 }

function Find-ChildProcess {
  param($ID=$PID)
  $CustomColumnID = @{
    Name = 'Id'
    Expression = { [Int[]]$_.ProcessID }
  }
  
  $result = Get-WmiObject -Class Win32_Process -Filter "ParentProcessID=$ID" |
  Select-Object -Property ProcessName, $CustomColumnID, CommandLine
  
  $result
  $result | Where-Object { $_.ID -ne $null } | ForEach-Object {Find-ChildProcess -id $_.Id}
}

# launch processes from within your powershell, then try
# Find-ChildProcess
# Find-ChildProcess | Stop-Process -whatif

get-process -includeusername

#Finding 32-Bit Processes
#Did you know that on a 64-bit machine that not all processes are 64-bit? You can use this little trick to filter out only 32-bit processes:
Get-Process | Where-Object {($_ | Select-Object -ExpandProperty Modules -ea 0 | Select-Object -ExpandProperty ModuleName) -contains 'wow64.dll'}

# Get Process Owner
(Get-WmiObject -Class win32_Process -filter "name='powershellplus.exe'").GetOwner()

Start-Process 'notepad.exe'
Start-Sleep -Seconds 1
$processes = Get-WmiObject Win32_Process -Filter "name='notepad.exe'" 
$appendedprocesses = foreach ($process in $processes) {   Add-Member -MemberType NoteProperty -Name Owner -Value ( $process.GetOwner().User) -InputObject $process -PassThru } 
$appendedprocesses | Format-Table name, owner

Get-WmiObject Win32_Process -filter "Name='powershellplus.exe'" | Where-Object { $_.GetOwner().user -eq 'a-staggeo'} | Select-Object CSName,name

Get-Process | Where-Object {$_.mainWindowTitle} | format-table id, name, mainwindowtitle -autosize
Get-Process -FileVersionInfo -ea SilentlyContinue

#Get Remote Process by Name
(Get-WmiObject -Class win32_Process -ComputerName $ComputerName -Credential $myDomainAdminCredentials -filter "name='setup.exe'")
