break

function Start-AppxPackage { 
    #Start-AppxPackage *edge*
    [CmdletBinding(SupportsShouldProcess)] 
    [Alias('StartApp')] 
    param($Name)
    foreach($package in Get-AppxPackage) 
    { 
        foreach($appId in ($package | Get-AppxPackageManifest).Package.Applications.Application.Id) 
        { 
            if(($package.Name -like $Name) -or ($appId -like $Name)) 
            { 
                $commandLine = "shell:AppsFolder\$($package.PackageFamilyName)!$appId" 
                if($PSCmdlet.ShouldProcess($commandLine)) 
                { 
                    Start-Process $commandLine 
                } 
            } 
        } 
    }
}
