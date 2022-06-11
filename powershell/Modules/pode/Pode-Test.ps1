Import-Module Pode 
Import-Module PSWriteHTML   #-MaximumVersion 0.0.125

Start-PodeServer -Threads 4 {
    Add-PodeEndpoint -Address 127.0.0.1 -Port 7777 -Protocol Http
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    Add-PodeRoute -Method Get -Path '/tasks' -ScriptBlock {
        Write-PodeHtmlResponse -Value (
            New-HTML -TitleText 'Processes' {
                New-HTMLSection -HeaderText 'My Process' -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable (Get-Process | Select-Object -First 20)
                    }
                }
            }
        )
    }
}