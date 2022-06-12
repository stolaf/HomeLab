# QRCodeGenerator

https://www.powershellgallery.com/packages/QRCodeGenerator
https://github.com/TobiasPSP/Modules.QRCodeGenerator

# Uses binaries from https://github.com/codebude/QRCoder/wiki

Install-Module -Name QRCodeGenerator
Get-Command -Module QRCodeGenerator
Get-Help New-QRCodeVCard -ShowWindow
Get-Help New-PSOneQRCodeGeolocation -ShowWindow
New-QRCodeWifiAccess -SSID 'UNIFI-AP-PRO-BS' -Password 'apEd$tu9dvz%XhY$&tfRKF' -Width 100 -OutPath "UNIFI-AP-PRO-BS.png" 

