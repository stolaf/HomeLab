# ImportExcel 

git clone https://github.com/dfinke/ImportExcel.git

Install-Module -Name 'ImportExcel' -Scope AllUsers -force

## Allgemeines
Get-Command -Module ImportExcel -CommandType Function
Get-Help Export-Excel -Examples
Get-Help Export-Excel -ShowWindow

Get-ExcelFileSummary -Path $ExcelFileName  
Remove-Worksheet -FullName $ExcelFileName -WorksheetName 'Summarum' -ErrorAction SilentlyContinue

## Charts

