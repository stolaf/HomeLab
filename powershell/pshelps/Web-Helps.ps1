break

#How to disable SSL 2.0 or SSL 3.0 from IIS Server
https://blogs.msdn.microsoft.com/webapps/2014/10/29/how-to-disable-ssl-2-0-or-ssl-3-0-from-iis-server/

#region WebPI#
#http://www.powershellmagazine.com/2014/02/27/using-powershell-and-web-platform-installer-to-install-azure-powershell-cmdlets/
$null = [reflection.assembly]::LoadWithPartialName('Microsoft.Web.PlatformInstaller')
$ProductManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager
$ProductManager.Load()
$ProductManager.Products | Select-Object Title, Version, Author | Out-GridView
$ProductManager.Products | Where-Object { $_.ProductId -like '*PowerShell*' } | Select-Object Title, Version | Out-GridView
$product = $ProductManager.Products | Where-Object {$_.ProductId -eq 'WindowsAzurePowerShell'}
$InstallManager = New-Object Microsoft.Web.PlatformInstaller.InstallManager
$Language = $ProductManager.GetLanguage('en')
$installertouse = $product.GetInstaller($Language)
$installer = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Installer]'
$installer.Add($installertouse)
$InstallManager.Load($installer)
$failureReason=$null
foreach ($installerContext in $InstallManager.InstallerContexts) {
  $InstallManager.DownloadInstallerFile($installerContext, [ref]$failureReason)
}
$InstallManager.StartInstallation()
$Product.Installers[0].LogFiles
#endregion WebPI

#region Mail
$SMTPServer = '10.43.10.23'   #mail.fs01.vwf.vwfs-ad
$SMTPServer = 'mail.fs01.vwf.vwfs-ad'
$From = 'HyperV-Report@vwfs.com'
$To = 'extern.Olaf.Stagge@vwfs.com'
Send-MailMessage -From $From -SmtpServer $SMTPServer -Body 'Hallo Olaf' -Subject 'Das ist ein Test' -To $To -BodyAsHtml -DeliveryNotificationOption OnFailure,OnSuccess -Attachments 'scom_agents_without_failover.xml'

#required Powershell v3
Send-MailMessage -Body 'My mail message can contain special characters: äöüß' -From olaf.stagge@hotmail.de -to olaf.stagge@hotmail.de -Credential olaf.stagge@hotmail.de -SmtpServer smtp.live.com -Subject 'Sending Mail from PowerShell' -Encoding ([System.Text.Encoding]::UTF8) -UseSsl
Send-MailMessage -Body 'My mail message can contain special characters: äöüß' -From olaf.stagge@hotmail.de -to olaf.stagge@hotmail.de -Credential $My_HotMailCredential -SmtpServer smtp.live.com -Subject 'Sending Mail from PowerShell' -Encoding 'UTF8' -UseSsl
Send-MailMessage -From someone@email.de -To someone@email.de, anotherone@scriptinternals.de -Subject Testmessage -Body 'A test message' -SmtpServer smtp.web.de -Credential (Get-Credential)

Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Subject 'Daily report' -Body 'This is a daily report of server uptime'
Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>', 'Manager2 <Manager2@xyz.com>' -CC 'Manager 3 <Manager3@xyz.com>', 'Manager4 <Manager4@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Subject 'Daily report sent to multiple managers' -Body 'This is a daily report of servers uptime'
Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Subject 'Daily report' -Body 'Attached file has uptime details of all servers' -Attachments 'c:\temp\uptime-report.txt'
#Multiple Attachements
Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Subject 'Daily report' -Body 'Attached file has uptime details of all servers' -Attachments 'c:\temp\server1-uptime-report.txt', 'c:\temp\server2-uptime-report.txt'

# SMTP relay server that requires authentication
Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Credentials (Get-Credential) -Subject 'Daily report' -Body 'This is a daily report of servers uptime'

#Send status of all services in a server as an email
Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Subject 'Services status of Server1' -Body (Get-Service -ComputerName Server1 | Out-String)

#Send high-priority email
Send-MailMessage -To 'Manager 1 <Manager1@xyz.com>' -From 'Reports Admin <Reportadmin@xyx.com>' -SMTPServer smtp1.xyz.com -Subject 'Daily report' -Body 'This is a daily report of servers uptime' -Priority High

<#
    .SYNOPSIS
    Send Mail over Hotmail 
    .DESCRIPTION
    <A detailed description of the script>
    .PARAMETER <paramName>
    <Description of script parameter>
    .EXAMPLE
    Send-My_SMTPMail -From "olaf.stagge@hotmail.de" -To "olaf.stagge@hotmail.de" -Body "Mail from Powershell" -Subject "Test" -Attachment "C:\Users\Olaf\AppData\Local\Temp\Untitled3.ps1" 
#>
function Send-My_SMTPMail {
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]  [String] $From, 
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]  [String[]] $To,
    [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true)]  [String] $Subject,
    [Parameter(Mandatory = $true, Position = 3, ValueFromPipelineByPropertyName = $true)]  [String] $Body,
    [Parameter(Mandatory = $false, Position = 4, ValueFromPipelineByPropertyName = $true)] [String] $Attachment = ''
  )
  
  $SMTPServer = 'smtp.live.com' 
  $SMTPClient = New-Object Net.Mail.SMTPClient( $SmtpServer, 587 )  
  $SMTPClient.EnableSSL = $true 
  $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($My_HotMailCredential.UserName,(new-object System.Management.Automation.PSCredential $My_HotMailCredential.UserName,$My_HotMailCredential.Password).GetNetworkCredential().Password); 
  
  $emailMessage = New-Object System.Net.Mail.MailMessage
  $emailMessage.From = $From
  foreach ( $recipient in $To )
  {
    $emailMessage.To.Add($recipient)
  }
  $emailMessage.Subject = $Subject
  $emailMessage.Body = $Body
  if ($Attachment -ne '') { 
    $emailMessage.Attachments.Add($Attachment)
  }
  $SMTPClient.Send($emailMessage)
}
#endregion Mail
#User Agent String:
[Microsoft.PowerShell.Commands.PSUserAgent].GetProperties() | Select-Object Name, @{n='UserAgent';e={ [Microsoft.PowerShell.Commands.PSUserAgent]::$($_.Name) }}
[Microsoft.PowerShell.Commands.PSUserAgent]::Chrome

#This will download all highres images matching the keyword "PowerShell" to your folder specified in $TargetFolder.
$SearchItem = 'PowerShell'
$TargetFolder = 'c:\webpictures'
if ( (Test-Path -Path $TargetFolder) -eq $false) { mkdir $TargetFolder }
$url = "https://www.google.com/search?q=$SearchItem&espv=210&es_sm=93&source=lnms&tbm=isch&sa=X&tbm=isch&tbs=isz:lt%2Cislt:2mp"
$browserAgent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36'
$page = Invoke-WebRequest -Uri $url -UserAgent $browserAgent
$page.Links | 
Where-Object { $_.href -like '*imgres*' } | 
ForEach-Object { ($_.href -split 'imgurl=')[-1].Split('&')[0]} |
ForEach-Object {
  $file = Split-Path -Path $_ -Leaf
  $path = Join-Path -Path $TargetFolder -ChildPath $file
  Invoke-WebRequest -Uri $_ -OutFile $path
}

#Connected to Internet?
[Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet
Invoke-RestMethod -uri 'https://gdata.youtube.com/feeds/api/videos?v=2&q=Desired+State+Configuration+PowerShell' | % {[PSCustomObject]@{Title=$_.Title; Author=$_.author.name; Link=$_.content.src}} | Format-List

((Invoke-WebRequest -Uri 'http://www.microsoft.com/en-us/download/confirmation.aspx?id=40843').links | Where-Object href -match "exe$|docx$|bin$").href | %{Start-BitsTransfer -Source $_ -Destination 'C:\VHDEVALR2'}
function Download-File {param([String]$url, [String]$destination = $Env:Temp, [String]$proxy = '')  
  $webClient = new-object System.Net.WebClient 
  if ($proxy -ne '') {
    $proxy = new-object System.Net.WebProxy $proxy
    #$proxy.Credentials = New-Object System.Net.NetworkCredential ("ww009\bw1staf0", "<pw>")  
    $webclient.proxy= $proxy
  }
  $webClient.Headers.Add('user-agent', 'Windows Powershell WebClient Header') 
  if ($destiantion -eq '') {
    $filename =$url.Substring($url.LastIndexof('/') +1)
    $webClient.DownloadFile($url, "$destination\$filename") 
  }else{
    $webClient.DownloadFile($url, "$destination")
  }
}

