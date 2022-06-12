<#
https://home.openweathermap.org/
https://openweathermap.org/current
#>

$APIKey = 'e7f0d67037ec271452c1b5d3ed17b508'

$WebRequest = Invoke-WebRequest -Uri "http://api.openweathermap.org/data/2.5/forecast?q=Braunschweig,de&appid=$APIKey" -UseBasicParsing
$Json = $WebRequest.Content | ConvertFrom-Json
$Json.city
$Json.list[0]


ESP32/WeatherDisplay/OLEDScreen.h
