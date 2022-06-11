# http://logging.apache.org/log4net/release/sdk/log4net.Layout.PatternLayout.html

###### Create the Logger Configuration ######
#Load the assembley from your dll location
[void][Reflection.Assembly]::LoadFrom('C:\log4net\log4net.dll')
 
#Define your logging pattern. See more about it here: http://logging.apache.org/log4net/release/sdk/log4net.Layout.PatternLayout.html
$pattern='%d %w %-5p %c : %m%n'
 
#Reset the log4net configuration
[log4net.LogManager]::ResetConfiguration()
 
#Create the Logging file for every single Datasource based on the Hostname.
$DSHostName = Get-WfaRestParameter 'host'
$logFile=$PSScriptRoot.Substring(0, $($PSScriptRoot.Length - 8)) + '\log\' + $DSHostName +'.log'

#Create the log4net config Appender
$Appender = new-object log4net.Appender.FileAppender
$Appender.File = $logFile
$Appender.Layout = new-object log4net.Layout.PatternLayout($pattern)
$Appender.Threshold = [log4net.Core.Level]::All
$Appender.ActivateOptions()
[log4net.Config.BasicConfigurator]::Configure($Appender)
 
#Create Logger for the DataSource Type Name. You can actually put anything
$log = [log4net.LogManager]::GetLogger('[Person Data source with logging]')

####### Logger is Ready #########
 
$PersonFile = './person.csv'
New-Item -Path $PersonFile -type file -Force
Add-Content $PersonFile ([Byte[]][Char[]] "`\N`tAron`tFinch`t011-12345678`n") -Encoding Byte
Add-Content $PersonFile ([Byte[]][Char[]] "`\N`tDavid`tWarner`t011-12345677`n") -Encoding Byte
Add-Content $PersonFile ([Byte[]][Char[]] "`\N`tSteven`tSmith`t011-12345676`n") -Encoding Byte

#Now log whatever you want.
$log.Info("This is an info message on Host: $DSHostName")
$log.Debug('This is a debug message')
$log.Warn('This is a warning message')
$log.Error('this is an error Message')
$log.Fatal('this is a fatal error Message')