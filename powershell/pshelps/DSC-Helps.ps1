break

start https://devblogs.microsoft.com/powershell/dsc-resource-kit-release-october-2019/

$null = netsh winhttp import proxy source=ie
$webclient = New-Object System.Net.WebClient
$webclient.Proxy.Credentials=$myProxyCredential

#proxy wieder entfernen sonst kein PS Remoting
netsh winhttp reset proxy
netsh winhttp show proxy

Get-DscResource 
Get-DscResource User -Syntax -Module PSDscResources
Get-DscResource -Module xActiveDirectory
Get-DscResource -Name xADDomainController -Module xActiveDirectory -Syntax

Find-Module -Tag DSCResourceKit

Get-PSRepository
Install-Module -Name xActiveDirectory


Install-Module -Name xPSDesiredStateConfiguration

Configuration MyEnvironment {
}

#https://devblogs.microsoft.com/powershell/tag/dsc-resource-kit/
$GitHubCredential = Get-Credential -UserName 'olaf.stagge@posteo.de' -Message 'Input GitHub Credential'
Configuration CopyGitHubResource {
   File DownloadPackage        {            	
     Ensure = "Present"              	
     Type = "File"
     Credential = $GitHubCredential             	
     SourcePath ="https://github.com/stolaf/powershell/blob/master/ScriptBlocks.ps1"            	
     DestinationPath = "C:\Temp"            
   }
}
 
 #https://storageaccount.blob.core.windows.net/mycontainer/file.zip
 
Configuration CopySQLRessource {
  File SQLBinaryDownload {
    DestinationPath = "C:\SQLInstall"
    Credential = $storageCredential
    Ensure = "Present"
    SourcePath = "\\[StorageAccountName].file.core.windows.net\software\SQL Server 2014"
    Type = "Directory"
    Recurse = $true
  }
}

# http://blog.enowsoftware.com/solutions-engine/bid/187447/Setting-Up-Your-First-PowerShell-DSC-Pull-Server
# http://technet.microsoft.com/en-us/library/dn249921.aspx
# http://blogs.sepago.de/d/roberth/2013/07/02/windows-server-2012-desired-state-configuration-ae-schnell-und-einfach
# http://blogs.msdn.com/b/powershell/archive/2013/11/05/understanding-configuration-keyword-in-desired-state-configuration.aspx
Configuration MyWebConfig {
  Node 'Server001' {     # A Configuration block can have zero or more Node blocks
    # Next, specify one or more resource blocks
    # WindowsFeature is one of the built-in resources you can use in a Node block
    # This example ensures the Web Server (IIS) role is installed
    WindowsFeature MyRoleExample {
      Ensure = 'Present'     # To uninstall the role, set Ensure to "Absent"
      Name   = 'Web-Server'  
    }
    
    # File is a built-in resource you can use to manage files and directories
    # This example ensures files from the source directory are present
    File MyFileExample {
      Ensure = 'Present'    # You can also set Ensure to "Absent"
      Type = 'Directory'   # Default is "File"
      Recurse = $true
      SourcePath = $WebsiteFilePath 
      DestinationPath = 'C:\inetpub\wwwroot' 
      DependsOn = '[WindowsFeature]MyRoleExample'     #This ensures that MyRoleExample completes successfully before    
    }
  }
} 

Configuration MyTestConfig {
  param($MachineName)
  Node $MachineName  {
    Group TestGroup {
      Ensure ='Present'
      GroupName='TestGroup'
    }
    
    Service WinUpdate {
      Name ='wuauserv'
      StartupType='Automatic'
    }
    
    Script ScriptExample {
      SetScript = {
        $sw = New-Object System.IO.StreamWriter("$env:temp\TestFile.txt")
        $sw.WriteLine('Some sample string')
        $sw.Close()
      }
      TestScript = {Test-Path 'C:\TempFolder\TestFile.txt'}
      GetScript={ <# This must return a hash table #>}
    }
    
    Registry RegistryExample {
      Ensure ='Present' # You can also set Ensure to "Absent"
      Key ='HKEY_LOCAL_MACHINE\SOFTWARE\ExampleKey'
      ValueName='TestValue'
      ValueData='TestData'
    }
    
    Environment EnvironmentExample {
      Ensure ='Present' # You can also set Ensure to "Absent"
      Name ='TestEnvironmentVariable'
      Value ='TestValue'
    }
  }
}
$null = mkdir C:\dscconfig -ErrorAction SilentlyContinue
MyTestConfig -MachineName $env:COMPUTERNAME -OutputPath c:\dscconfig
Start-DscConfiguration -Wait -Path c:\dscconfig

Configuration CoreDSC {
  Node ('CS-RDS1','CS-VMM') {
    WindowsFeature Backup {
      Name = 'Windows-Server-Backup'
      Ensure = 'Present'
    }
    WindowsFeature IIS {    # Install the IIS Role
      Ensure = 'Present'
      Name = 'Web-Server'
    }
    WindowsFeature AspNet45 {
      Ensure = 'Present'
      Name = 'Web-Asp-Net45'
    }
    File Work {
      Type = 'Directory'
      Ensure = 'Present'
      DestinationPath = 'C:\Work'
      
    } #file work
    File Scripts {
      Type = 'Directory'
      Ensure = 'Present'
      DestinationPath = 'C:\Scripts'
      
    } #file scripts
    File Reports {
      Type = 'Directory'
      Ensure = 'Present'
      DestinationPath = 'C:\Reports'
    } #file reports
  } #node
} #close configuration

CoreDSC -outputpath c:\scripts
Start-DSCConfiguration -path c:\scripts -wait   #oder
CoreDSC
Start-DSCConfiguration -path $PSScriptRoot\CoreDSC -wait -Verbose -Force

Configuration CoreDSC1 {
  param (
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string[]] $Nodename,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $WebSiteName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $SourcePath,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $DestinationPath
  )
  Node $Nodename {
    WindowsFeature IIS {    # Install the IIS Role
      Ensure = 'Present'
      Name = 'Web-Server'
    }
    WindowsFeature AspNet45 {
      Ensure = 'Present'
      Name = 'Web-Asp-Net45'
    }
    Website DefaultSite {  #Stop the default Web Site
      Ensure = 'Present'
      Name = 'Default Web Site'
      State = 'Stopped'
      PhysicalPath = 'C:\Intetpub\wwwroot'
      Requires = '[WindowsFeature]IIS'
    }
    File WebContent {
      Ensure = 'Present'
      SourcePath = $SourcePath
      DestinationPath = $DestinataionPath
      Recurse = $true
      Type = 'Directory'
    }
    WebSite BakeryWebSite {
      Ensure = 'Present'
      Name = $WebSiteName
      State = 'Started'
      PhysicalPath = $DestinationPath
      Requires  = '[File]WebContent'
    }
  } 
} #close configuration

#Using the Credential attribute of DSC File Resource
$ConfigurationData = @{
  AllNodes = @(
    @{
      NodeName='*'
      PSDscAllowPlainTextPassword=$true
    }
    @{
      NodeName='SRV2-WS2012R2'
    }
    @{
      NodeName='SRV3-WS2012R2'
    }
  )
}

Configuration CopyDSCResource {
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$SourcePath,
    
    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential,
    
    [Parameter(Mandatory=$false)]
    [String]$ModulePath = "${PSHOME}\modules\PSDesiredStateConfiguration\PSProviders"
  )
  
  Node $AllNodes.NodeName {
    File DSCResourceFolder {
      SourcePath = $SourcePath
      DestinationPath = $ModulePath
      Recurse = $true
      Type = 'Directory'
      Credential = $Credential
      MatchSource = $true
    }
  }
}
CopyDSCResource -ConfigurationData $configurationData -SourcePath '\\10.10.10.101\DSCResources' -Credential (Get-Credential)