$wshell = New-Object -ComObject wscript.shell
while ($True) {
  Start-Sleep -Seconds 60
  $wshell.SendKeys("{F15}")
}

