break

#http://blogs.technet.com/b/heyscriptingguy/archive/2015/11/29/weekend-scripter-a-look-at-the-poshrsjob-module.aspx
#http://blogs.technet.com/b/heyscriptingguy/archive/2015/11/26/beginning-use-of-powershell-runspaces.aspx
#http://blogs.technet.com/b/heyscriptingguy/archive/2015/11/27/beginning-use-of-powershell-runspaces-part-2.aspx
#http://blogs.technet.com/b/heyscriptingguy/archive/2015/11/28/beginning-use-of-powershell-runspaces-part-3.aspx
#http://blogs.technet.com/b/heyscriptingguy/archive/2015/11/27/powertip-get-the-async-object-created-by-begininvoke.aspx
#http://blogs.technet.com/b/heyscriptingguy/archive/2015/11/28/powertip-add-custom-function-to-runspace-pool.aspx

Get-Runspace #ab Powershell 5

$Runspace = [runspacefactory]::CreateRunspace()
$PowerShell = [powershell]::Create()
$PowerShell.runspace = $Runspace
$Runspace.Open()
[void]$PowerShell.AddScript({Get-Date})
$PowerShell.Invoke()

#asynchron
$Runspace = [runspacefactory]::CreateRunspace()
$PowerShell = [powershell]::Create()
$PowerShell.runspace = $Runspace
$Runspace.Open()
[void]$PowerShell.AddScript({
    Get-Date
    Start-Sleep -Seconds 10
})
$AsyncObject = $PowerShell.BeginInvoke()
while (!$AsyncObject.IsCompleted) {
  Start-Sleep -Milliseconds 500
}
$Data = $PowerShell.EndInvoke($AsyncObject)
$PowerShell.Dispose()

#Variables Outsid Scriptblock
$PowerShell = [powershell]::Create()
$Global:Param1 = 'Param1'
$Global:Param2 = 'Param2'

[void]$PowerShell.AddScript({
    [pscustomobject]@{
        Param1 = $Param1
        Param2 = $Param2
    }
})
$PowerShell.Invoke()
$PowerShell.Dispose()

$Param1 = 'Param1'
$Param2 = 'Param2'
$PowerShell = [powershell]::Create()
[void]$PowerShell.AddScript({
    Param ($Param1, $Param2)
    [pscustomobject]@{
        Param1 = $Param1
        Param2 = $Param2
    }
}).AddArgument($Param1).AddArgument($Param2)
$PowerShell.Invoke()
$PowerShell.Dispose()

#besser
$Param1 = 'Param1'
$Param2 = 'Param2'
$PowerShell = [powershell]::Create()
[void]$PowerShell.AddScript({
    Param ($Param1, $Param2)
    [pscustomobject]@{
        Param1 = $Param1
        Param2 = $Param2
    }
}).AddParameter('Param2',$Param2).AddParameter('Param1',$Param1) #Order won't matter now
$PowerShell.Invoke()
$PowerShell.Dispose()

#noch besser
$ParamList = @{
    Param1 = 'Param1'
    Param2 = 'Param2'
}
$PowerShell = [powershell]::Create()
[void]$PowerShell.AddScript({
    Param ($Param1, $Param2)
    [pscustomobject]@{
        Param1 = $Param1
        Param2 = $Param2
    }
}).AddParameters($ParamList)
$PowerShell.Invoke()
$PowerShell.Dispose()

##########################################
[runspacefactory]::CreateRunspacePool()
$SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

$RunspacePool = [runspacefactory]::CreateRunspacePool(
    1, #Min Runspaces
    5 #Max Runspaces
)
$PowerShell = [powershell]::Create()
#Uses the RunspacePool vs. Runspace Property
#Cannot have both Runspace and RunspacePool property used; last one applied wins
$PowerShell.RunspacePool = $RunspacePool
$RunspacePool.Open()

$jobs = New-Object System.Collections.ArrayList

1..50 | ForEach {
    $PowerShell = [powershell]::Create() 
    $PowerShell.RunspacePool = $RunspacePool   
    [void]$PowerShell.AddScript({
        Param (
            $Param1,
            $Param2
        )
        $ThreadID = [appdomain]::GetCurrentThreadId()
        Write-Verbose "ThreadID: Beginning $ThreadID" -Verbose
        $sleep = Get-Random (1..5)       
        [pscustomobject]@{
            Param1 = $param1
            Param2 = $param2
            Thread = $ThreadID
            ProcessID = $PID
            SleepTime = $Sleep
        } 
        Start-Sleep -Seconds $sleep
        Write-Verbose "ThreadID: Ending $ThreadID" -Verbose
    })
    [void]$PowerShell.AddParameters($Parameters)
    $Handle = $PowerShell.BeginInvoke()
    $temp = '' | Select-Object PowerShell,Handle
    $temp.PowerShell = $PowerShell
    $temp.handle = $Handle

    [void]$jobs.Add($Temp)   
    Write-Debug ('Available Runspaces in RunspacePool: {0}' -f $RunspacePool.GetAvailableRunspaces())
    Write-Debug ('Remaining Jobs: {0}' -f @($jobs | Where-Object {
        $_.handle.iscompleted -ne 'Completed'
    }).Count)
}

#Get the Async Object Created by BeginInvoke
$Runspace = [runspacefactory]::CreateRunspace()
$PowerShell = [powershell]::Create()
$Runspace.Open()
$PowerShell.Runspace = $Runspace
[void]$PowerShell.AddScript({
    [pscustomobject]@{
        Name = 'Boe Prox'
        PowerShell = $True
    }
})
#Intentionally forget to save this
$PowerShell.BeginInvoke()
#Time to retrieve our missing object
$BindingFlags = [Reflection.BindingFlags]'nonpublic','instance'
$Field = $PowerShell.GetType().GetField('invokeAsyncResult',$BindingFlags)
$AsyncObject = $Field.GetValue($PowerShell)
#Now end the runspace
$PowerShell.EndInvoke($AsyncObject)

#Add Custom Function to Runspace Pool
#Custom Function
function ConvertTo-Hex {
    Param([int]$Number)
    '0x{0:x}' -f $Number
}

#Get body of function
$Definition = Get-Content Function:\ConvertTo-Hex -ErrorAction Stop
#Create a sessionstate function entry
$SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'ConvertTo-Hex', $Definition
#Create a SessionStateFunction
$InitialSessionState.Commands.Add($SessionStateFunction)
#Create the runspacepool by adding the sessionstate with the custom function
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,5,$InitialSessionState,$Host)
