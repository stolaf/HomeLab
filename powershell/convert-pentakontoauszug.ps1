<#
> csv Export für Steuerberater anpassen: ","  --> ";"
#>

$Month = 05
$Year = 2022
$StartDate = Get-Date -Year $Year -Month $Month -Day 1 –Hour 0 –Minute 0 –Second 0
$EndDate = ($StartDate).AddMonths(1).AddSeconds(-1)

$Path = "C:\Users\olaf\Documents\elastic-IT\2022\05.2022\Transactions_elastic_it_GmbH_1654509534934.csv"
$NewFileName = "$(Split-Path -Path $Path)" + '\Transactions_elastic_it_GmbH_' + "$(Get-Date -Month $Month -Format 'MM')_$(Get-Date -Year $Year -Format 'yyyy').csv"

$Transactions = Import-Csv -Path $Path -Delimiter ',' -Encoding UTF8

$Transactions = $Transactions | ForEach-Object {
    $ValueDate = [DateTime]::Parse($_.'Buchungsdatum')
    if ($ValueDate -ge $StartDate -and $ValueDate -le $EndDate) { $_ }  
} 
$Transactions | Select-Object * | Sort-Object -Property Buchungsdatum | Format-Table -AutoSize

$Transactions | Select-Object * | Sort-Object -Property Buchungsdatum | Export-Csv -Path $NewFileName -Delimiter ';' -Encoding UTF8 -NoTypeInformation -Force

Remove-Item -Path $Path -Force
code $NewFileName 

