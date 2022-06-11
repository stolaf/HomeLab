# Selenium

## Allgemeines
Mit Selenium kann man Daten von dynamischen Websites ziehen.  
Das Framework benötigt eine Schnittstelle aka einen Driver, um den passenden Browser anzusprechen. Daher gibt es Driver für Firefox, Chrome, Edge und so weiter.  
Auf die richtige Version des Drivers achten!

Automatisch Online-Briefmarken bei der Post bestellen: https://www.heise.de/ratgeber/Python-und-Selenium-Automatisch-Online-Briefmarken-bei-der-Post-bestellen-6131715.html

```Powershell
Install-Module -Name 'Selenium'
Import-Module -Name 'Selenium'
Get-Command -Module 'Selenium'

```

## Start a Browser Driver
```powershell
# Start a driver for a browser of your choise (Chrome/Firefox/Edge/InternetExplorer)
# To start a Firefox Driver
$Driver = Start-SeFirefox 

# To start a Chrome Driver
$Driver = Start-SeChrome

# To start an Edge Driver
$Driver = Start-SeEdge

# Run Chrome in Headless mode 
$Driver = Start-SeChrome -Headless

# Run Chrome in incognito mode
$Driver = Start-SeChrome -Incognito

# Run Chrome with alternative download folder
$Driver = Start-SeChrome -DefaultDownloadPath C:\Temp

# Run Chrome and go to a URL in one command
$Driver = Start-SeChrome -StartURL 'https://www.google.com/ncr'

# Run Chrome with multiple Arguments
$Driver = Start-SeChrome -Arguments @('Incognito','start-maximized')

# Run Chrome with an existing profile.
# The default profile paths are as follows:
# Windows: C:\Users\<username>\AppData\Local\Google\Chrome\User Data
# Linux: /home/<username>/.config/google-chrome
# MacOS: /Users/<username>/Library/Application Support/Google/Chrome
$Driver = Start-SeChrome -ProfileDirectoryPath '/home/<username>/.config/google-chrome'
```

## Navigate to a URL
```powershell
$Driver = Start-SeFirefox 
Enter-SeUrl https://www.poshud.com -Driver $Driver
```

## Find an Element
```powershell
$Driver = Start-SeFirefox 
Enter-SeUrl https://www.poshud.com -Driver $Driver
$Element = Find-SeElement -Driver $Driver -Id "myControl"
```

## Click on an Element/Button
```powershell
$Driver = Start-SeFirefox 
Enter-SeUrl https://www.poshud.com -Driver $Driver
$Element = Find-SeElement -Driver $Driver -Id "btnSend"
Invoke-SeClick -Element $Element
```

## Send Keystrokes
```powershell
$Driver = Start-SeFirefox 
Enter-SeUrl https://www.poshud.com -Driver $Driver
$Element = Find-SeElement -Driver $Driver -Id "txtEmail"
Send-SeKeys -Element $Element -Keys "adam@poshtools.com"
```

## Find and Wait for an element
```powershell
$Driver = Start-SeChrome
Enter-SeUrl 'https://www.google.com/ncr' -Driver $Driver

# Please note that with the -Wait parameter only one element can be returned at a time.
Find-SeElement -Driver $d -Wait -Timeout 10 -Css input[name='q'] 
Find-SeElement -Driver $d -Wait -Timeout 10 -Name q 
```

### Beispiel VWFS WebAccess Automation
```Powershell
$Driver = Start-SeChrome  
Enter-SeUrl 'https://webaccess.vwfs.com/vpn/index.html' -Driver $Driver

$Element = Find-SeElement -Driver $Driver -id "Enter user name" -Wait
Invoke-SeClick -Element $Element
Send-SeKeys -Element $Element -Keys "dkx8zb8"

$Element = Find-SeElement -Driver $Driver -id "passwd" -Wait
Invoke-SeClick -Element $Element
Send-SeKeys -Element $Element -Keys "...."

$Element = Find-SeElement -Driver $Driver -id "passwd1" -Wait
Invoke-SeClick -Element $Element
Send-SeKeys -Element $Element -Keys "...."

$logon = Find-SeElement -Driver $Driver -id "Log_On" -Wait
$logon.click()

$EMEA = (Find-SeElement -Driver $Driver -ClassName "storeapp-details-link")[1]
(Find-SeElement -Driver $Driver -ClassName "storeapp-list")[1]
$EMEA.click()

$Driver.Close()
```

### Corona Dashboard
https://www.heise.de/ratgeber/Scraping-Mit-Python-Daten-von-beliebigen-Websites-auslesen-4659822.html
[https://www.heise.de/ratgeber/Mit-Python-und-Selenium-Corona-Daten-vom-RKI-Dashboard-scrapen-5032291.html?seite=1](https://www.heise.de/ratgeber/Mit-Python-und-Selenium-Corona-Daten-vom-RKI-Dashboard-scrapen-5032291.html?seite=1)
In knapp unter 70 Zeilen haben Sie das Dashboard des RKIs übergangen, einen Roboter durch die quälend langsame Seite geschickt und die Daten schick in der Konsole aufbereitet. Dabei konnten Sie einen kurzen Einblick gewinnen, was mit Selenium möglich ist. Der Umgang mit dem Tool ist aber nur so gut, wie eine vorherige Analyse der Website. Sie sollten die passenden Ankerpunkte im Quelltext finden, um mit Selenium die richtigen Daten aus der Seite zu ziehen. Hier muss man manchmal kreative Wege gehen, um den passenden X-Path oder CSS-Selektor zu formulieren.

Mit Selenium geht natürlich noch viel mehr – gerade für Webanwendungstester. Aber auch als Scraping-Tool macht es eine gute Figur und Sie kommen in wenigen Zeilen Code zum Ziel. Da Javascript nicht so schnell verschwinden wird, werden Sie im Netz immer wieder auf Daten stoßen,  
die Sie über andere Methoden nicht scrapen können. Mit Selenium haben Sie allerdings auch für schwierige Fälle eine mächtige Waffe in der Hinterhand. (str)