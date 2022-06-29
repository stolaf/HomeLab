# QRCodeGenerator

https://www.powershellgallery.com/packages/QRCodeGenerator
https://github.com/TobiasPSP/Modules.QRCodeGenerator

# Uses binaries from https://github.com/codebude/QRCoder/wiki

Install-Module -Name QRCodeGenerator
Get-Command -Module QRCodeGenerator
Get-Help New-QRCodeVCard -ShowWindow
Get-Help New-PSOneQRCodeGeolocation -ShowWindow
New-QRCodeWifiAccess -SSID 'UNIFI-AP-PRO-BS' -Password 'apEd...' -Width 100 -OutPath "UNIFI-AP-PRO-BS.png" 
New-QRCodeWifiAccess -SSID 'UNIFI-U6-LR-WR' -Password 'f39Ey...' -Width 100 -OutPath "UNIFI-U6-LR-WR.png" 

New-QRCodeVCard -FirstName 'Olaf' -LastName 'Stagge' -Company 'elastic-it GmbH' -Email 'info@elastic-it.gmbh' -OutPath "$pwd/myVCard.png" 