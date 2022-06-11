#region Excel

Start-Process -FilePath 'C:\Program*\MicrosoftOffice\Office*\EXCEL.EXE'
#ExcelCookBook
iexplore.exe http://theolddogscriptingblog.wordpress.com/2010/06/01/powershell-excel-cookbook-ver-2/

$begin = {
  '<table>'
  '<tr>'
  '<th>DisplayName</th><th>Status</th><th>Required</th><th>Dependent</th>'
  '</tr>'
}
$process = {
  if ($_.Status -eq 'Running') {
    $style = '<td style="color:green; ; font-family:Segoe UI; font-size:14pt">'
  } else {
    $style = '<td style="color:red; font-family:Segoe UI; font-size:14pt">'
  }
  '<tr>'
  '{0}{1}</td><td>{2}</td><td>{3}</td><td>{4}</td>' -f $style, $_.DisplayName, $_.Status, ($_.RequiredServices -join ','), ($_.DependentServices -join ',')
  '</tr>'
}
$end = {
  '</table>'
}
$Path = "$env:temp\tempfile.html"

Get-Service | ForEach-Object -Begin $begin -Process $process -End $end | Set-Content -Path $Path -Encoding UTF8
Start-Process -FilePath 'C:\Program Files*\Microsoft Office\Office*\EXCEL.EXE' -ArgumentList $Path
#endregion Excel
#region Outlook
$subject = 'Sending via MAPI client'
$body = 'My Message'
$to = 'tobias@powertheshell.com'
$mail = "mailto:$to&subject=$subject&body=$body"
Start-Process -FilePath $mail

function Get-MAPIClient {
  function Remove-Argument {
    param ($CommandLine)
    $divider = ' '
    if ($CommandLine.StartsWith('"')) { 
      $divider = '"'
      $CommandLine = $CommandLine.SubString(1)
    }
    $CommandLine.Split($divider)[0]
  } 
  
  $path = 'Registry::HKEY_CLASSES_ROOT\mailto\shell\open\command'
  $returnValue = 1 | Select-Object -Property HasMapiClient, Path, MailTo
  $returnValue.hasMAPIClient = Test-Path -Path $path
  
  if ($returnValue.hasMAPIClient) {
    $values = Get-ItemProperty -Path $path
    $returnValue.MailTo = $values.'(default)'
    $returnValue.Path = Remove-Argument $returnValue.MailTo 
    if ((Test-Path -Path $returnValue.Path) -eq $false) {
      $returnValue.hasMAPIClient = $true
    }
  }
  $returnValue
} 
Get-MAPIClient

#List Outlook Contacts
$Outlook=NEW-OBJECT -comobject Outlook.Application
$Contacts=$Outlook.session.GetDefaultFolder(10).items
$Contacts | Format-Table FullName,MobileTelephoneNumber,Email1Address

$outlookApplication = New-Object -ComObject Outlook.Application
$outlookApplication.Application.DefaultProfileName

#It will not work when Outlook has not yet been started.
#Start-Process Outlook

$o = New-Object -com Outlook.Application
$mail = $o.CreateItem(0)
$mail.subject = 'Test message'
$mail.body = "First line`nSecond Line`nThird line"
$mail.To = 'Olaf.Stagge@lbb.de'
#$mail.Attachments.Add("C:\somefile.txt")
$mail.Send()
$o.Quit()
#endregion Outlook
#region Winword
function Out-Winword {
# Get-Process | Out-Winword -Font Consolas -FontSize 14 -Title 'ProcessList' -Landscape
  param (
    $Text = $null,
    $Title = $null,
    $Font = 'Courier',
    $FontSize = 12,
    $Width = 80,
    [switch] $Print,
    [switch] $Landscape
  )

  if ($Text -eq $null) {
    $Text = $Input | Out-String -Width $Width
  }

  $Wordobj = New-Object -ComObject Word.Application
  $document = $Wordobj.Documents.Add()
  $document.PageSetup.Orientation = [Int][bool] $Landscape
  $document.Content.Text = $Text
  $document.Content.Font.Size = $FontSize
  $document.Content.Font.Name = $Font

  if ($Title -ne $null) {
    $Wordobj.Selection.Font.Name = $Font
    $Wordobj.Selection.Font.Size = 20
    $Wordobj.Selection.TypeText($Title)
    $Wordobj.Selection.ParagraphFormat.Alignment = 1
    $Wordobj.Selection.TypeParagraph()
    $Wordobj.Selection.TypeParagraph()
  }
  if ($Print) {
    $Wordobj.PrintOut()
    $wdDoNotSaveChanges = 0
    $Wordobj.NormalTemplate.Saved = $true
    $Wordobj.Visible = $false
    $document.Close([ref]$wdDoNotSaveChanges)
    $Wordobj.Quit([ref]$wdDoNotSaveChanges)
  } Else {
    $Wordobj.Visible = $true
  }
}
#To convert a whole folder full of MS Word documents to PDF, here's a function that might help:
function Export-WordToPDF {
  param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('FullName')]
    $path,
  $pdfpath = $null)
  
  process {
    if (!$pdfpath) {
      $pdfpath = [System.IO.Path]::ChangeExtension($path, '.pdf')
    }
    $word = New-Object -ComObject Word.Application
    $word.displayAlerts = $false
    $word.Visible = $true
    $doc = $word.Documents.Open($path)
    #$doc.TrackRevisions = $false
    $null = $word.ActiveDocument.ExportAsFixedFormat($pdfpath, 17, $false, 1)
    $word.ActiveDocument.Close()
    $word.Quit()
  }
}
Get-ChildItem c:\folder -Filter *.doc | Export-WordToPDF
#endregion Winword

#find Office Installation Path
Resolve-Path 'C:\Program Files*\Microsoft Office\Office*\Excel.exe' | Select-Object -ExpandProperty Path

