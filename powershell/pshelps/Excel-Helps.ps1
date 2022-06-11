break

#https://github.com/dfinke/ImportExcel
#https://4sysops.com/archives/read-and-write-excel-spreadsheets-with-the-importexcel-powershell-module/
Import-Module "C:\Users\DKX8ZB8ADM\Documents\WindowsPowerShell\Modules\ImportExcel" -Force
Import-Excel -Path "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_VMs\WebConfigs.xlsx"
Get-ExcelWorkbookInfo -Path "\\fsdebsgv4911\iopi_sources$\Reports\HyperV_VMs\WebConfigs.xlsx"
Get-Command -Module ImportExcel

Remove-Item 'c:\temp\test.xlsx'
#Get-Service | Export-Excel 'c:\temp\test.xlsx' -Show -IncludePivotTable -PivotRows status -PivotData @{status='count'} -FreezeTopRow


#############################
Get-CimInstance win32_service | Select-Object state, accept*, start*, caption | Export-Excel 'c:\temp\test.xlsx' -Show -BoldTopRow -AutoFilter -FreezeTopRow -AutoSize

$ps = Get-Process
$ps | Export-Excel .\testExport.xlsx  -WorkSheetname memory -IncludePivotTable -PivotRows Company -PivotData PM -IncludePivotChart -ChartType PieExploded3D
$ps | Export-Excel .\testExport.xlsx  -WorkSheetname handles -IncludePivotTable -PivotRows Company -PivotData Handles -IncludePivotChart -ChartType PieExploded3D -Show

Get-Service | Export-Excel .\test.xlsx -WorkSheetname Services -BoldTopRow -AutoFilter -AutoSize -FreezeTopRow -Show
Get-ChildItem -file | Export-Excel .\test.xlsx -WorkSheetname Files -BoldTopRow -AutoFilter -AutoSize -FreezeTopRow
Get-Process | Export-Excel .\test.xlsx -WorkSheetname Processes -IncludePivotTable -Show -PivotRows Company -PivotData PM -BoldTopRow -AutoFilter -AutoSize -FreezeTopRow

ConvertFrom-ExcelSheet .\Test.xlsx .\data -Delimiter ';'

$old_Culture = [System.Threading.Thread]::CurrentThread.CurrentCulture
[System.Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'
Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress,InterfaceAlias,ifIndex,PrefixLength| Export-Excel -Path 'C:\Temp\IPAddresses2.xlsx' -WorkSheetname 'IPAddresses' 
[System.Threading.Thread]::CurrentThread.CurrentCulture = $old_Culture

Get-Process | Where-Object Company | Export-Excel C:\Temp\ps.xlsx -Show -IncludePivotTable -PivotRows Company -PivotData @{Handles='sum'} -IncludePivotChart -ChartType PieExploded3D