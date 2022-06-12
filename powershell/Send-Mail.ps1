[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$From = "docker@posteo.de"  #"docker-01@posteo.de" funktioniert nicht
$To = "olaf.stagge@posteo.de"
# $Cc = "YourBoss@YourDomain.com"
# $Attachment = "C:\temp\Some random file.txt"
$Subject = "Das ist eine Testmail from raspi-01"
$Body = "Das ist eine Testmail from raspi-01"
$SMTPServer = "posteo.de"
$SMTPPort = "587"
$Credential = Get-Credential -username 'olaf.stagge@posteo.de'   # h3m1WXc2eZr802K9
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credential # -Cc $Cc -Attachments $Attachment

#Besser Modul Mailozaurr verwenden
Install-Module -Name Mailozaurr -AllowClobber -Force
Update-Module -Name Mailozaurr
Send-EmailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credential # -Cc $Cc -Attachments $Attachment


