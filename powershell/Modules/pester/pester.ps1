## Update Pester 3 to 5
# Wichtigste Änderungen in Pester v5            
# https://pester.dev/docs/migrations/breaking-changes-in-v5            

# Festlegen des Modulverzeichnisses von Pester            
$module = (Get-Item (Get-Item (Get-Module pester -ListAvailable | Select-Object path).path).Directory).Parent.FullName            

$module = 'C:\Program Files\WindowsPowerShell\Modules\Pester'

# Besitz des Verzeichnisses übernehmen            
# /A = Zuweisen der lokalen Administrator Gruppe            
# /R = Rekursiv            
takeown /F $module /A /R            

# Zugriffsrechte (Access Control List) zurücksetzen            
icacls $module /reset            

# Lokale Gruppe Administratoren (S-1-5-32-544) mit Vollzugriff ausstatten            
# /inheritance:d = Vererbungen deaktivieren und aktuelle ACL kompieren            
# /T = Befehl für sämtliche Dateien und Unterverzeichnisse durchführen (Rekursiv)   
# Get-LocalGroup Administratoren | Select *        # gibt die SID aus
icacls $module /grant "*S-1-5-32-544:F" /inheritance:d /T            

# Entfernen des Modul Ordners ohne Bestätigung und Rekursiv            
Remove-Item -Path $module -Recurse -Force -Confirm:$false            

# Installieren des Pester Modules ab PowerShell Gallery            
Install-Module -Name Pester -Force            

# Aktualisieren des Modules Pester            
Update-Module -Name Pester

## Pester 5
# https://www.youtube.com/watch?v=yd3M5sKW7jA&t=25s

Describe "Allgemein Pester Version 5 muss zum Testen vorhanden sein" -Tag 'Pester' {
    It "Minimum Version 5 vom Pester Modul muss vorhanden sein sonst funktionieren die Befehle nicht" -Tag 'Pester' {
        (Get-Module Pester).Version.Major | Should -BeGreaterOrEqual  5
    }
}

Describe "1. Ziel soll getestet werden" {
    Context "Test mit be stimmen weitgehend bis auf Casesenstive" -Tag 'Umgebung' {
        It "String wird geprüft" { 
            'Aktueller wert' | Should -Be 'aktueller Wert'  #stimmt
        }
    }
    Context "Test mit beacactly müssen ganz genau stimmen auch mit Gross-Kleinschreibung" {
        It "String wird geprüft" { 
            #'Aktueller Wert' | Should -Be 'aktueller Wert'  # stimmt nicht
            'Aktueller Wert' | Should -Be 'Aktueller Wert'  # stimmt
        }
    }
    Context "Test mit BeFalse und BeFalse müssen $false bzw. $true sein" {
        It "Bool wird geprüft" { 
            $false | Should -BeFalse
            $null | Should -BeFalse # stimmt nicht
            $true | Should -BeTrue
            $false | Should -BeTrue
        }
    }
    break
    Context "Zahlen nach Größe vergleichen" {
        It "Zahl wird geprüft" { 
            5 | Should -BeGreaterThan 3
            5 | Should -BeGreaterOrEqual 5
            5 | Should -BeLessOrEqual 4 # false
            2 | Should -BeLessThan 3 
        }
    }
    Context "Arrays können mit BeIn ider Contain getest werden je nach Reihenfolge" {
        It "Array wird geprüft" { 
            'Hallo' | Should -BeIn @('Hallo', 'welt', 'Gruss')  #stimmt
            27 | should -BeIn    (20..30) # stimmt
            'x', 'y', 'z' | Should -Contain 'x' #stimmt
            1..100 | Should -Contain 120  #false
        }
    }
    Context "Prüfen ob eine Datei oder ein Ordner vorhanden ist kann man mit Exist" {
        It "File wird geprüft" { 
            'C:\Program Files\PowerShell\7\pwsh.exe'  | Should -Exist  
            Get-ChildItem 'C:\Temp\data.vhdx'  | Should -Exist  
        }
    }
    Context "Den Dateiinhalt kann auch geprüft werden" {
        It "FileInhalt wird geprüft" { 
            $MeinInhalt = "Hallo Welt"
            $MeineDatei = "($env:Temp\pestertest.txt"
            Set-Content -Path $MeineDatei -Value $MeinInhalt
            $MeineDatei | Should -FileContentMatch "hello welt"  #stimmt
            $MeineDatei | Should -FileContentMatchExactly "hello welt"  #stimmt nicht
            $MeinInhalt = 'Ich bin die erste Zeile. `nIch bin die zweite Zeile'
            Set-Content -Path $MeineDatei -Value $MeinInhalt
            $MeineDatei | Should -FileContentMatchMultiline 'erste Zeile\.\r?nIch' #stimmt mitteles Regex
        }
    }
    Context "Wir können auch mit Platzhaltern * testen" {
        It "BeLike wird geprüft" { 
            'Hallo meine Welt' | Should -BeLike 'Meine*' #stimmt
            'Hallo meine Welt' | Should -BeLikeExactly 'Meine*' 
        }
    }
    Context "Auch auf leeren Inhalt bzw. null können wir testen" {
        It "Null or Empty wird geprüft" { 
            '' | Should -BeNullOrEmpty  #stimmt
            $null | Should -BeNullOrEmpty  #stimmt
            ' ' | Should -BeNullOrEmpty  #stimmt nicht
        }
    }
    Context "Nun prüfen wir ob der Objecttype stimmt" {
        It "Type wird geprüft" { 
            'Hallo Welt' | Should -BeOfType System.String #stimmt
            '1234' | Should -BeOfType System.Int32  #stimmt nicht
            1234 | Should -BeOfType System.Int32  #stimmt 
        (Get-ChildItem 'C:\Temp\data.vhdx').GetType()
            Get-ChildItem 'C:\Temp\data.vhdx' | Should -BeOfType System.IO.FileSystemInfo
            'a', 'b', 'c' | Should -BeOfType System.Array
        }
    }
    Context "Bei Array können wir auch testen ob eine bestimmte Anzahl an Elementen zurückkommt" {
        It "Array Objectanzahl wird geprüft" { 
        (1..3) | Should -HaveCount 3  #stimmt
        }
    }
    Context "Bei Funktionen und Befehlen können wir auf bestimmte Paramtern prüfen" {
        It "CmdLets wird geprüft" { 
            Get-Command Get-ChildItem | Should -HaveParameter Path  #stimmt
            Get-Command Get-ChildItem | Should -HaveParameter Path -Mandatory #stimmt nicht
            Get-Command Get-ChildItem | Should -NOT -HaveParameter HAns #stimmt 
        }
    }
}