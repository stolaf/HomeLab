# corona.rki.de
# API Beschreibung: https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/917fc37a709542548cc3be077a786c17_0?geometry=-36.781%2C46.211%2C58.800%2C55.839
# corona Relevant sind alle kleingeschriebenen Attribute
# Anregung aus ct 09/2021 S.160

$fields = @('OBJECTID', 'GEN', 'BEZ', 'cases', 'deaths', 'cases_per_population', 'cases7_per_100k', 'cases7_lk', 'death7_lk', 'cases7_bl_per_100k', 'cases7_bl', 'death7_bl', 'last_update') -join ','

$Uri_BS = "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=17&outFields=$fields&outSR=4326&f=json"
$Uri_WR = "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=372&outFields=$fields&outSR=4326&f=json"
# $Uri_D = "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/rki_key_data_hubv/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"

$WebRequestBS = Invoke-RestMethod -Uri $Uri_BS
$WebRequestWR = Invoke-RestMethod -Uri $Uri_WR
# $WebRequestD = Invoke-RestMethod -Uri $Uri_D

$Liste = @()
$Liste += New-Object PSObject -Property ([ordered]@{
        'Landkreis'     = $WebRequestBS.features.attributes.'GEN'
        'FaelleGesamt'  = $WebRequestBS.features.attributes.'cases'
        'ToteGesamt'    = $WebRequestBS.features.attributes.'deaths'
        'Faelle7Tage'   = $WebRequestBS.features.attributes.'cases7_lk'
        'Tote7Tage'     = $WebRequestBS.features.attributes.'death7_lk'
        'Inzidenz7Tage' = [Math]::Round($WebRequestBS.features.attributes.'cases7_per_100k', 0)
        'LastUpdate'    = $WebRequestBS.features.attributes.'last_update'
    })

$Liste += New-Object PSObject -Property ([ordered]@{
        'Landkreis'     = $WebRequestWR.features.attributes.'GEN'
        'FaelleGesamt'  = $WebRequestWR.features.attributes.'cases'
        'ToteGesamt'    = $WebRequestWR.features.attributes.'deaths'
        'Faelle7Tage'   = $WebRequestWR.features.attributes.'cases7_lk'
        'Tote7Tage'     = $WebRequestWR.features.attributes.'death7_lk'
        'Inzidenz7Tage' = [Math]::Round($WebRequestWR.features.attributes.'cases7_per_100k', 0)
        'LastUpdate'    = $WebRequestWR.features.attributes.'last_update'
    })

'| Landkreis | FaelleGesamt | ToteGesamt | Faelle7Tage | Tote7Tage | Inzidenz7Tage | LastUpdate |'
'| --------- | ------------ | ---------- | ----------- | --------- | ------------- | ---------- |'

$($Liste | ConvertTo-Csv -Delimiter '|' -QuoteFields '' | Select-Object -Skip 1) | ForEach-Object { '|' + $_ + '|' } | ForEach-Object { ($_.Replace('|', ' | ')).TrimStart(' ') }
Write-Host ''

