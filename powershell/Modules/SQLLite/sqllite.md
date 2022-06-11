# sqllite

https://github.com/RamblingCookieMonster/PSSQLite
http://www.spech.de/2016/06/sqlite-mit-der-powershell-nutzen/
http://sqlitebrowser.org/

https://github.com/TobiasPSP/ReallySimpleDatabase
```powershell
# Install-Module -Name ReallySimpleDatabase -Scope CurrentUser
Get-Command -Module ReallySimpleDatabase

#o create a new SQLite database (or open an existing database), use Get-Database
Get-Database -Path $env:temp\mydb.db

Get-Process | Import-Database -Database $database -TableName Processes
Get-Service | Import-Database -Database $database -TableName Services

# add another process to table "processes"
Get-Process -Id $Pid | Import-Database -Database $database -TableName Processes

# List Tables
$database = Get-Database -Path $env:temp\mydb.db
$database.GetTables()

#Read Data
$database = Get-Database -Path $env:temp\mydb.db
$database.InvokeSql('select * from processes where name like "a%"') | Format-Table

#Example: Dump Chrome Passwords  see Github

```

```powershell
Import-Module -Name 'PSSQLite'

Get-Command -Module PSSQLite
Get-Help Invoke-SQLiteQuery -Full

$db = "C:\Temp\db1.SQLite" # oder .SQLite, .SQLite3 oder .db
$query = "CREATE TABLE user (
  UserId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  Firstname NVARCHAR(250) NOT NULL,
  Lastname NVARCHAR(250) NOT NULL,
  Birthdate DATE
)"

# SQLite erstellt die Datei automatisch
Invoke-SqliteQuery -Query $query -DataSource $db

$db = "C:\Temp\db1.SQLite"
$conn = New-SQLiteConnection @Verbose -DataSource $db 
$conn.ConnectionString
$conn.State

$query = "INSERT INTO user(Firstname, Lastname, Birthdate) VALUES (@firstname, @lastname, @birthdate)"
Invoke-SqliteQuery -SQLiteConnection $conn -Query $query -SqlParameters @{
  firstname = 'Larissa'
  lastname = 'Stagge'
  birthdate = '1969-08-01'
}

$conn.Close()

###############
$DataSource = "C:\Temp\db1.SQLite"
Invoke-SqliteQuery -DataSource $DataSource -Query "SELECT * FROM user"


#################
$DataSource = "C:\Temp\Names.SQLite"
$Query = "CREATE TABLE NAMES (fullname VARCHAR(20) PRIMARY KEY, surname TEXT, givenname TEXT, BirthDate DATETIME)"
Invoke-SqliteQuery -Query $Query -DataSource $DataSource
$DataTable = 1..1000 | %{
  [pscustomobject]@{
    fullname = "Name $_"
    surname = "Name"
    givenname = "$_"
    BirthDate = (Get-Date).Adddays(-$_)
  }
} | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $DataTable -DataSource $DataSource -Table Names -NotifyAfter 1000 -verbose
Invoke-SqliteQuery -DataSource $DataSource -Query "SELECT * FROM NAMES"
```

