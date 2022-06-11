break

# INT Z10 VLAN 1808; okay  
"\\fsdebsgv4911\iopi_sources$\PowerShell\[Integration]\[SQL]\FSDEBSYDI50005\FSDEBSYDI50005\FSDEBSYDI50005_VMConfig.xml"
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSYDI50005' -Description 'INT-SQL-Test' -Change 'C123456' -IPv4 @('10.41.29.253') -VMConfigFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\[Integration]\[SQL]' `
-OperatingSystem W2K16-Standard -Domain fs01.vwf.vwfs-ad -InstallSoftware SQL2016Standard -Show -Force

# INT Z00 VLAN 2605
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSYDI50007' -Description 'INT-SQL-Test' -Change 'C123456' -IPv4 @('10.37.4.6') -VMConfigFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\[Integration]\[SQL]' `
-OperatingSystem W2K16-Standard -Domain fs01.vwf.vwfs-ad -InstallSoftware SQL2016Standard -Show -Force

# KONS Z10 VLAN 1807 : okay
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSYDK50005' -Description 'KONS-SQL Test' -Change 'C123456' -IPv4 @('10.41.19.254') -VMConfigFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\[KONS]\[SQL]' `
-OperatingSystem 'W2K16-Standard' -Domain fs01.vwf.vwfs-ad -InstallSoftware SQL2016Standard -Show -Force

# KONS Z00 VLAN 2604 : okay
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSYDK50007' -Description 'KONS-SQL Test' -Change 'C123456' -IPv4 @('10.37.3.254') -VMConfigFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\[KONS]\[SQL]' `
-OperatingSystem 'W2K16-Standard' -Domain 'fs01.vwf.vwfs-ad' -InstallSoftware SQL2016Standard -Show -Force

# PROD Z10 VLAN 1806 : okay
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSYDP50005' -Description 'PROD-SQL Test' -Change 'C123456' -IPv4 @('10.41.19.126') -VMConfigFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\[PROD]\[SQL]' `
-OperatingSystem 'W2K16-Standard'  -Domain 'fs01.vwf.vwfs-ad' -InstallSoftware SQL2016Standard -Show -Force

# PROD Z00 VLAN 2603 : okay
New-IOPI_HyperV_VMConfigFile -VMName 'FSDEBSYDP50007' -Description 'PROD-SQL Test' -Change 'C123456' -IPv4 @('10.37.3.126') -VMConfigFolder '\\fsdebsgv4911\iopi_sources$\PowerShell\[PROD]\[SQL]' `
-OperatingSystem 'W2K16-Standard'  -Domain 'fs01.vwf.vwfs-ad' -InstallSoftware SQL2016Standard -Show -Force

<# Import csv to SQL
  # https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd
  $csvfile='c:\temp\services.csv'
  # Get-Service | Select-Object Name,DisplayName,Status | Export-Csv -Path $csvfile -Delimiter ';' -NoTypeInformation -Force
  $sqlTable='MyDataTable'
  $DataSource='SQLDESCS1P.mgmt.fsadm.vwfs-ad\I01'
  $DataBase='I-SBI'

  $ConnectionString ='Data Source={0}; Database={1}; Trusted_Connection=True;' -f $DataSource,$DataBase
  $csvDataTable = Import-CSV -Path $csvfile -Delimiter ';' | Out-DataTable
  $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($ConnectionString)
  $bulkCopy.DestinationTableName=$sqlTable
  $bulkCopy.WriteToServer($csvDataTable)
#>
 <# ConnectionStrings
  $conn = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$filename;Persist Security Info=False")
  $cmd=$conn.CreateCommand()
  $cmd.CommandText="Select * from table1"
  $conn.open()
  $cmd.ExecuteReader()

  $conn = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;Data Source = $fileName;Extended Properties=Excel 8.0")
#>

function Invoke-SQLNonQuery{
  <#
    .SYNOPSIS
   
    .EXAMPLE
    $cmd=New-Object System.Data.SqlClient.SqlCommand
    $cmd.CommandType=[System.Data.CommandType]::StoredProcedure
    $cmd.CommandText='sp_GetTask '
    $p=$cmd.Parameters.Add('@TaskId',1)
    Invoke-SQLNonQuery -Server omega\sqlexpress -Database issue -command $cmd
  #>

  Param(	
    [string]$Server=$env:COMPUTERNAME,
    [string]$Database='master',
    [System.Data.SqlClient.SqlCommand]$command
  )

  $conn=New-Object System.Data.SqlClient.SqlConnection
  $conn.ConnectionString="Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=$Database;Data Source=$Server"
  $command.Connection=$conn
  $conn.Open()
  $command.ExecuteScalar()
  $conn.Close()
}
function Get-SQLTable {
  [CmdletBinding()]
  Param(
    $server=$env:COMPUTERNAME,
    $instance='SQLExpress',
    $dbname='issue',
    $tablename='Table_1',
    $schema='dbo'
  )

  $sqlConnection="Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=$dbname;Data Source=$server\$instance"

  Try{
    $conn = New-Object System.Data.SqlClient.SqlConnection($sqlConnection)
    [void]$conn.open()
    $adapter=New-Object Data.Sqlclient.SqlDataAdapter("select * from [$schema].[$tablename]", $conn)
    $ds=new-object System.Data.DataTable
    [void]$adapter.Fill($ds)
    $ds
  }

  Catch{
    Write-Host "$_" -ForegroundColor red
  }

  Finally{
    $conn.Close()
  }
}
function Invoke-Sqlcmd2 {
  <# 
    .SYNOPSIS 
    Runs a T-SQL script. 
    .DESCRIPTION 
    Runs a T-SQL script. Invoke-Sqlcmd2 only returns message output, such as the output of PRINT statements when -verbose parameter is specified.
    Paramaterized queries are supported. 

    Help details below borrowed from Invoke-Sqlcmd
    .PARAMETER ServerInstance
    One or more ServerInstances to query. For default instances, only specify the computer name: "MyComputer". For named instances, use the format "ComputerName\InstanceName".
    .PARAMETER Database
    A character string specifying the name of a database. Invoke-Sqlcmd2 connects to this database in the instance that is specified in -ServerInstance.

    If a SQLConnection is provided, we explicitly switch to this database

    .PARAMETER Query
    Specifies one or more queries to be run. The queries can be Transact-SQL (? or XQuery statements, or sqlcmd commands. Multiple queries separated by a semicolon can be specified. Do not specify the sqlcmd GO separator. Escape any double quotation marks included in the string ?). Consider using bracketed identifiers such as [MyTable] instead of quoted identifiers such as "MyTable".

    .PARAMETER InputFile
    Specifies a file to be used as the query input to Invoke-Sqlcmd2. The file can contain Transact-SQL statements, (? XQuery statements, and sqlcmd commands and scripting variables ?). Specify the full path to the file.

    .PARAMETER Credential
    Specifies A PSCredential for SQL Server Authentication connection to an instance of the Database Engine.
        
    If -Credential is not specified, Invoke-Sqlcmd attempts a Windows Authentication connection using the Windows account running the PowerShell session.
        
    SECURITY NOTE: If you use the -Debug switch, the connectionstring including plain text password will be sent to the debug stream.

    .PARAMETER QueryTimeout
    Specifies the number of seconds before the queries time out.

    .PARAMETER ConnectionTimeout
    Specifies the number of seconds when Invoke-Sqlcmd2 times out if it cannot successfully connect to an instance of the Database Engine. The timeout value must be an integer between 0 and 65534. If 0 is specified, connection attempts do not time out.

    .PARAMETER As
    Specifies output type - DataSet, DataTable, array of DataRow, PSObject or Single Value 

    PSObject output introduces overhead but adds flexibility for working with results: http://powershell.org/wp/forums/topic/dealing-with-dbnull/

    .PARAMETER SqlParameters
    Hashtable of parameters for parameterized SQL queries.  http://blog.codinghorror.com/give-me-parameterized-sql-or-give-me-death/

    Example:
    -Query "SELECT ServerName FROM tblServerInfo WHERE ServerName LIKE @ServerName"
    -SqlParameters @{"ServerName = "c-is-hyperv-1"}

    .PARAMETER AppendServerInstance
    If specified, append the server instance to PSObject and DataRow output

    .PARAMETER SQLConnection
    If specified, use an existing SQLConnection.
    We attempt to open this connection if it is closed

    .INPUTS 
    None 
    You cannot pipe objects to Invoke-Sqlcmd2 

    .OUTPUTS
    As PSObject:     System.Management.Automation.PSCustomObject
    As DataRow:      System.Data.DataRow
    As DataTable:    System.Data.DataTable
    As DataSet:      System.Data.DataTableCollectionSystem.Data.DataSet
    As SingleValue:  Dependent on data type in first column.

    .EXAMPLE 
    Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
    
    This example connects to a named instance of the Database Engine on a computer and runs a basic T-SQL query. 
    StartTime 
    ----------- 
    2010-08-12 21:21:03.593 

    .EXAMPLE 
    Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -InputFile "C:\MyFolder\tsqlscript.sql" | Out-File -filePath "C:\MyFolder\tsqlscript.rpt" 
    
    This example reads a file containing T-SQL statements, runs the file, and writes the output to another file. 

    .EXAMPLE 
    Invoke-Sqlcmd2  -ServerInstance "MyComputer\MyInstance" -Query "PRINT 'hello world'" -Verbose 

    This example uses the PowerShell -Verbose parameter to return the message output of the PRINT command. 
    VERBOSE: hello world 

    .EXAMPLE
    Invoke-Sqlcmd2 -ServerInstance MyServer\MyInstance -Query "SELECT ServerName, VCNumCPU FROM tblServerInfo" -as PSObject | ?{$_.VCNumCPU -gt 8}
    Invoke-Sqlcmd2 -ServerInstance MyServer\MyInstance -Query "SELECT ServerName, VCNumCPU FROM tblServerInfo" -as PSObject | ?{$_.VCNumCPU}

    This example uses the PSObject output type to allow more flexibility when working with results.
        
    If we used DataRow rather than PSObject, we would see the following behavior:
    Each row where VCNumCPU does not exist would produce an error in the first example
    Results would include rows where VCNumCPU has DBNull value in the second example

    .EXAMPLE
    'Instance1', 'Server1/Instance1', 'Server2' | Invoke-Sqlcmd2 -query "Sp_databases" -as psobject -AppendServerInstance

    This example lists databases for each instance.  It includes a column for the ServerInstance in question.
    DATABASE_NAME          DATABASE_SIZE REMARKS        ServerInstance                                                     
    -------------          ------------- -------        --------------                                                     
    REDACTED                       88320                Instance1                                                      
    master                         17920                Instance1                                                      
    ...                                                                                              
    msdb                          618112                Server1/Instance1                                                                                                              
    tempdb                        563200                Server1/Instance1
    ...                                                     
    OperationsManager           20480000                Server2                                                            

    .EXAMPLE
    #Construct a query using SQL parameters
    $Query = "SELECT ServerName, VCServerClass, VCServerContact FROM tblServerInfo WHERE VCServerContact LIKE @VCServerContact AND VCServerClass LIKE @VCServerClass"

    #Run the query, specifying values for SQL parameters
    Invoke-Sqlcmd2 -ServerInstance SomeServer\NamedInstance -Database ServerDB -query $query -SqlParameters @{ VCServerContact="%cookiemonster%"; VCServerClass="Prod" }
            
    ServerName    VCServerClass VCServerContact        
    ----------    ------------- ---------------        
    SomeServer1   Prod          cookiemonster, blah                 
    SomeServer2   Prod          cookiemonster                 
    SomeServer3   Prod          blah, cookiemonster                 

    .EXAMPLE
    Invoke-Sqlcmd2 -SQLConnection $Conn -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
    
    This example uses an existing SQLConnection and runs a basic T-SQL query against it

    StartTime 
    ----------- 
    2010-08-12 21:21:03.593 


    .NOTES 
    Version History 
    poshcode.org - http://poshcode.org/4967
    v1.0         - Chad Miller - Initial release 
    v1.1         - Chad Miller - Fixed Issue with connection closing 
    v1.2         - Chad Miller - Added inputfile, SQL auth support, connectiontimeout and output message handling. Updated help documentation 
    v1.3         - Chad Miller - Added As parameter to control DataSet, DataTable or array of DataRow Output type 
    v1.4         - Justin Dearing <zippy1981 _at_ gmail.com> - Added the ability to pass parameters to the query.
    v1.4.1       - Paul Bryson <atamido _at_ gmail.com> - Added fix to check for null values in parameterized queries and replace with [DBNull]
    v1.5         - Joel Bennett - add SingleValue output option
    v1.5.1       - RamblingCookieMonster - Added ParameterSets, set Query and InputFile to mandatory
    v1.5.2       - RamblingCookieMonster - Added DBNullToNull switch and code from Dave Wyatt. Added parameters to comment based help (need someone with SQL expertise to verify these)
                 
    github.com   - https://github.com/RamblingCookieMonster/PowerShell
    v1.5.3       - RamblingCookieMonster - Replaced DBNullToNull param with PSObject Output option. Added credential support. Added pipeline support for ServerInstance.  Added to GitHub
    - Added AppendServerInstance switch.
    - Updated OutputType attribute, comment based help, parameter attributes (thanks supersobbie), removed username/password params
    - Added help for sqlparameter parameter.
    - Added ErrorAction SilentlyContinue handling to Fill method
    v1.6.0                               - Added SQLConnection parameter and handling.  Is there a more efficient way to handle the parameter sets?
    - Fixed SQLConnection handling so that it is not closed (we now only close connections we create)

    .LINK
    https://github.com/RamblingCookieMonster/PowerShell

    .LINK
    New-SQLConnection

    .LINK
    Invoke-SQLBulkCopy

    .LINK
    Out-DataTable

    .FUNCTIONALITY
    SQL
  #>

  [CmdletBinding(DefaultParameterSetName='Ins-Que')]
  [OutputType([System.Management.Automation.PSCustomObject],[System.Data.DataRow],[System.Data.DataTable],[System.Data.DataTableCollection],[System.Data.DataSet])]
  param(
    [Parameter( ParameterSetName='Ins-Que',
        Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        ValueFromRemainingArguments=$false,
    HelpMessage='SQL Server Instance required...' )]
    [Parameter( ParameterSetName='Ins-Fil',
        Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        ValueFromRemainingArguments=$false,
    HelpMessage='SQL Server Instance required...' )]
    [Alias( 'Instance', 'Instances', 'ComputerName', 'Server', 'Servers' )]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $ServerInstance,

    [Parameter( Position=1,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false)]
    [string]
    $Database,
    
    [Parameter( ParameterSetName='Ins-Que',
        Position=2,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [Parameter( ParameterSetName='Con-Que',
        Position=2,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [string]
    $Query,
        
    [Parameter( ParameterSetName='Ins-Fil',
        Position=2,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [Parameter( ParameterSetName='Con-Fil',
        Position=2,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [ValidateScript({ Test-Path $_ })]
    [string]
    $InputFile,
        
    [Parameter( ParameterSetName='Ins-Que',
        Position=3,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false)]
    [Parameter( ParameterSetName='Ins-Fil',
        Position=3,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false)]
    [System.Management.Automation.PSCredential]
    $Credential,

    [Parameter( Position=4,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [Int32]
    $QueryTimeout=600,
    
    [Parameter( ParameterSetName='Ins-Fil',
        Position=5,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [Parameter( ParameterSetName='Ins-Que',
        Position=5,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [Int32]
    $ConnectionTimeout=15,
    
    [Parameter( Position=6,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [ValidateSet('DataSet', 'DataTable', 'DataRow','PSObject','SingleValue')]
    [string]
    $As='DataRow',
    
    [Parameter( Position=7,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
    ValueFromRemainingArguments=$false )]
    [System.Collections.IDictionary]
    $SqlParameters,

    [Parameter( Position=8,
    Mandatory=$false )]
    [switch]
    $AppendServerInstance,

    [Parameter( ParameterSetName = 'Con-Que',
        Position=9,
        Mandatory=$false,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$false,
    ValueFromRemainingArguments=$false )]
    [Parameter( ParameterSetName = 'Con-Fil',
        Position=9,
        Mandatory=$false,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$false,
    ValueFromRemainingArguments=$false )]
    [Alias( 'Connection', 'Conn' )]
    [ValidateNotNullOrEmpty()]
    [System.Data.SqlClient.SQLConnection]
    $SQLConnection
  ) 

  Begin
  {
    if ($InputFile) 
    { 
      $filePath = $(Resolve-Path $InputFile).path 
      $Query =  [System.IO.File]::ReadAllText("$filePath") 
    }

    Write-Verbose "Running Invoke-Sqlcmd2 with ParameterSet '$($PSCmdlet.ParameterSetName)'.  Performing query '$Query'"

    If($As -eq 'PSObject')
    {
      #This code scrubs DBNulls.  Props to Dave Wyatt
      $cSharp = @'
                using System;
                using System.Data;
                using System.Management.Automation;

                public class DBNullScrubber
                {
                    public static PSObject DataRowToPSObject(DataRow row)
                    {
                        PSObject psObject = new PSObject();

                        if (row != null && (row.RowState & DataRowState.Detached) != DataRowState.Detached)
                        {
                            foreach (DataColumn column in row.Table.Columns)
                            {
                                Object value = null;
                                if (!row.IsNull(column))
                                {
                                    value = row[column];
                                }

                                psObject.Properties.Add(new PSNoteProperty(column.ColumnName, value));
                            }
                        }

                        return psObject;
                    }
                }
'@

      Try
      {
        Add-Type -TypeDefinition $cSharp -ReferencedAssemblies 'System.Data','System.Xml' -ErrorAction stop
      }
      Catch
      {
        If(-not $_.ToString() -like "*The type name 'DBNullScrubber' already exists*")
        {
          Write-Warning "Could not load DBNullScrubber.  Defaulting to DataRow output: $_"
          $As = 'Datarow'
        }
      }
    }

    #Handle existing connections
    if($PSBoundParameters.Keys -contains 'SQLConnection')
    {

      if($SQLConnection.State -notlike 'Open')
      {
        Try
        {
          $SQLConnection.Open()
        }
        Catch
        {
          Throw $_
        }
      }

      if($Database -and $SQLConnection.Database -notlike $Database)
      {
        Try
        {
          $SQLConnection.ChangeDatabase($Database)
        }
        Catch
        {
          Throw "Could not change Connection database '$($SQLConnection.Database)' to $Database`: $_"
        }
      }

      if($SQLConnection.state -like 'Open')
      {
        $ServerInstance = @($SQLConnection.DataSource)
      }
      else
      {
        Throw 'SQLConnection is not open'
      }
    }

  }
  Process
  {
    foreach($SQLInstance in $ServerInstance)
    {
      Write-Verbose "Querying ServerInstance '$SQLInstance'"

      if($PSBoundParameters.Keys -contains 'SQLConnection')
      {
        $Conn = $SQLConnection
      }
      else
      {
        if ($Credential) 
        {
          $ConnectionString = "Server={0};Database={1};User ID={2};Password=`"{3}`";Trusted_Connection=False;Connect Timeout={4}" -f $SQLInstance,$Database,$Credential.UserName,$Credential.GetNetworkCredential().Password,$ConnectionTimeout
        }
        else 
        {
          $ConnectionString = 'Server={0};Database={1};Integrated Security=True;Connect Timeout={2}' -f $SQLInstance,$Database,$ConnectionTimeout
        } 
            
        $conn = New-Object System.Data.SqlClient.SQLConnection
        $conn.ConnectionString = $ConnectionString 
        Write-Debug "ConnectionString $ConnectionString"


        Try
        {
          $conn.Open() 
        }
        Catch
        {
          Write-Error $_
          continue
        }
      }

      #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
      if ($PSBoundParameters.Verbose) 
      { 
        $conn.FireInfoMessageEventOnUserErrors=$true 
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] { Write-Verbose "$($_)" } 
        $conn.add_InfoMessage($handler) 
      }
    

      $cmd = New-Object system.Data.SqlClient.SqlCommand($Query,$conn) 
      $cmd.CommandTimeout=$QueryTimeout

      if ($SqlParameters -ne $null)
      {
        $SqlParameters.GetEnumerator() |
        ForEach-Object {
          If ($_.Value -ne $null)
          { $cmd.Parameters.AddWithValue($_.Key, $_.Value) }
          Else
          { $cmd.Parameters.AddWithValue($_.Key, [DBNull]::Value) }
        } > $null
      }
    
      $ds = New-Object system.Data.DataSet 
      $da = New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
    
      Try
      {
        [void]$da.fill($ds)
        $conn.Close()
      }
      Catch
      { 
        $Err = $_
        $conn.Close()

        switch ($ErrorActionPreference.tostring())
        {
          {'SilentlyContinue','Ignore' -contains $_} {}
          'Stop' {     Throw $Err }
          'Continue' { Write-Error $Err}
          Default {    Write-Error $Err}
        }              
      }

      if($AppendServerInstance)
      {
        #Basics from Chad Miller
        $Column =  New-Object Data.DataColumn
        $Column.ColumnName = 'ServerInstance'
        $ds.Tables[0].Columns.Add($Column)
        Foreach($row in $ds.Tables[0])
        {
          $row.ServerInstance = $SQLInstance
        }
      }

      switch ($As) 
      { 
        'DataSet' 
        {
          $ds
        } 
        'DataTable'
        {
          $ds.Tables
        } 
        'DataRow'
        {
          $ds.Tables[0]
        }
        'PSObject'
        {
          #Scrub DBNulls - Provides convenient results you can use comparisons with
          #Introduces overhead (e.g. ~2000 rows w/ ~80 columns went from .15 Seconds to .65 Seconds - depending on your data could be much more!)
          foreach ($row in $ds.Tables[0].Rows)
          {
            [DBNullScrubber]::DataRowToPSObject($row)
          }
        }
        'SingleValue'
        {
          $ds.Tables[0] | Select-Object -ExpandProperty $ds.Tables[0].Columns[0].ColumnName
        }
      }
    }
  }
}
function Out-DataTable {
  <#
    .SYNOPSIS
    Creates a DataTable for an object
    .DESCRIPTION
    Creates a DataTable based on an objects properties.
    .INPUTS
    Object
    Any object can be piped to Out-DataTable
    .OUTPUTS
    System.Data.DataTable
    .EXAMPLE
    $dt = Get-psdrive| Out-DataTable
    This example creates a DataTable from the properties of Get-psdrive and assigns output to $dt variable
    .NOTES
    Adapted from script by Marc van Orsouw see link
    Version History
    v1.0  - Chad Miller - Initial Release
    v1.1  - Chad Miller - Fixed Issue with Properties
    v1.2  - Chad Miller - Added setting column datatype by property as suggested by emp0
    v1.3  - Chad Miller - Corrected issue with setting datatype on empty properties
    v1.4  - Chad Miller - Corrected issue with DBNull
    v1.5  - Chad Miller - Updated example
    v1.6  - Chad Miller - Added column datatype logic with default to string
    v1.7 - Chad Miller - Fixed issue with IsArray
    .LINK
    http://thepowershellguy.com/blogs/posh/archive/2007/01/21/powershell-gui-scripblock-monitor-script.aspx
  #>
  [CmdletBinding()]
  param ([Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)] [PSObject[]]$InputObject)

  Begin {
    function Get-Type {
      param ($type)
      $types = @(
        'System.Boolean',
        'System.Byte[]',
        'System.Byte',
        'System.Char',
        'System.Datetime',
        'System.Decimal',
        'System.Double',
        'System.Guid',
        'System.Int16',
        'System.Int32',
        'System.Int64',
        'System.Single',
        'System.UInt16',
        'System.UInt32',
      'System.UInt64')
    
      if ($types -contains $type) {
        Write-Output "$type"
      } else {
        Write-Output 'System.String'
      }
    }
    $dt = new-object Data.datatable
    $First = $true
  }
  Process {
    foreach ($object in $InputObject) {
      $DR = $DT.NewRow()
      foreach ($property in $object.PsObject.get_properties()) {
        if ($first) {
          $Col = new-object Data.DataColumn
          $Col.ColumnName = $property.Name.ToString()
          if ($property.value) {
            if ($property.value -isnot [System.DBNull]) {
              $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)")
            }
          }
          $DT.Columns.Add($Col)
        }
        if ($property.Gettype().IsArray) {
          $DR.Item($property.Name) = $property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1
        } else {
          $DR.Item($property.Name) = $property.value
        }
      }
      $DT.Rows.Add($DR)
      $First = $false
    }
  }
  End {
    Write-Output @(, ($dt))
  }
} 
function Write-DataTable{
  <#
    .SYNOPSIS
    Writes data only to SQL Server tables.
    .DESCRIPTION
    Writes data only to SQL Server tables. However, the data source is not limited to SQL Server; any data source can be used, as long as the data can be loaded to a DataTable instance or read with a IDataReader instance.
    .INPUTS
    None
    You cannot pipe objects to Write-DataTable
    .OUTPUTS
    None
    Produces no output
    .EXAMPLE
    $dt = Invoke-Sqlcmd2 -ServerInstance "SQLDESCS1P.mgmt.fsadm.vwfs-ad\I01" -Database 'I-SBI' -Query "select *  from SCVMMReports"
    Write-DataTable -ServerInstance "Z003\R2" -Database pubscopy -TableName authors -Data $dt
    This example loads a variable dt of type DataTable from query and write the datatable to another database
    .NOTES
    Write-DataTable uses the SqlBulkCopy class see links for additional information on this class.
    Version History
    v1.0   - Chad Miller - Initial release
    v1.1   - Chad Miller - Fixed error message
    v 1.2  - Jim Vierra  - Modified from Chads code to remove unnecessary items and add truncate switch
    .LINK
    http://msdn.microsoft.com/en-us/library/30c3y597%28v=VS.90%29.aspx
    .LINK 
    https://github.com/RamblingCookieMonster/PowerShell/blob/master/Invoke-Sqlcmd2.ps1
  #>
  [CmdletBinding()]
  param(
    [string]$ServerInstance,
    [string]$Database,
    [string]$TableName,
    [System.Data.DataTable]$Data,
    [string]$Username,
    [string]$Password,
    [Int32]$BatchSize=50000,
    [Int32]$QueryTimeout=0,
    [Int32]$ConnectionTimeout=15,
    [switch]$TruncateTable
  )
    
  if($Username){
    $ConnectionString = 'Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}' -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout 
  }else{
    $ConnectionString = 'Server={0};Database={1};Integrated Security=True;Connect Timeout={2}' -f $ServerInstance,$Database,$ConnectionTimeout
  }

  $conn=new-object System.Data.SqlClient.SQLConnection($ConnectionString)

  try{
    $conn.Open()
		
    if($TruncateTable){
      $cmd=$conn.CreateCommand()
      $cmd.CommandText="truncate table $tablename"
      $cmd.CommandType=''
      $cmd.ExecuteNonQuery()
    }
		
    $bulkCopy = new-object ('Data.SqlClient.SqlBulkCopy') $connectionString
    $bulkCopy.DestinationTableName = $tableName
    $bulkCopy.BatchSize = $BatchSize
    $bulkCopy.BulkCopyTimeout = $QueryTimeOut
    $bulkCopy.WriteToServer($Data)
  }
  catch{
    Throw $_  # rethrow this up thestack
  }
  Finally{		
    Write-Verbose 'Closing connection'
    $conn.Close()
  }

} 


#region Excel2SQL
function Get-ExcelData {
  [CmdletBinding()]
  Param (
    $ExcelFilePath, 
    $ExcelVersion,
    $qry='select * from [sheet1$]'
  )
  
  if (!(Test-Path -Path $ExcelFilePath)) {Write-Error "File '$ExcelFilePath' not exist. Return";return}

  switch ($ExcelVersion) {
    '2003' {$connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=`"$ExcelFilePath`";Extended Properties=`"Excel 8.0;HDR=Yes;IMEX=1`";"}
    '2007' {$connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$ExcelFilePath`";Extended Properties=`"Excel 12.0 Xml;HDR=YES`";"}
    '2010' {$connString = ""}
    '2013' {$connString = "Data Source =`"$ExcelFilePath`";HDR=yes;Format=xls;"}
    '2016' {}
    Default {}
  }
 
  $conn = new-object System.Data.OleDb.OleDbConnection($connString)
  $conn.open()
  $cmd = new-object System.Data.OleDb.OleDbCommand($qry,$conn) 
  $da = new-object System.Data.OleDb.OleDbDataAdapter($cmd) 
  $dt = new-object System.Data.dataTable 
  [void]$da.fill($dt)
  $conn.close()
  $dt
} 
 
function Write-DataTableToDatabase { 
  <#
      .DESCRIPTION
      .SYNOPSIS
      .EXAMPLE
      $dt = Get-ExcelData -ExcelFilePath '' -qry 'select * from [backupset$]'
      Write-DataTableToDatabase -dt $dt -destServer 'Z002\SQLEXPRESS' -destDb 'SQLPSX' -destTbl ExcelData_fill
      
  #>
  [CmdletBinding()]
  Param (
    $dt, $destServer,$destDb,$destTbl
  )

  $connectionString = "Data Source=$destServer;Integrated Security=true;Initial Catalog=$destdb;"
  $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
  $bulkCopy.DestinationTableName = "$destTbl"
  $bulkCopy.WriteToServer($dt)
}
#endregion Excel2SQL

#region csv2SQL
# https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd
$csvfile='c:\temp\services.csv'
# Get-Service | Select-Object Name,DisplayName,Status | Export-Csv -Path $csvfile -Delimiter ';' -NoTypeInformation -Force
$sqlTable='MyDataTable'
$DataSource='SQLDESCS1P.mgmt.fsadm.vwfs-ad\I01'
$DataBase='I-SBI'

$ConnectionString ='Data Source={0}; Database={1}; Trusted_Connection=True;' -f $DataSource,$DataBase
$csvDataTable = Import-CSV -Path $csvfile -Delimiter ';' | Out-DataTable
$bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($ConnectionString)
$bulkCopy.DestinationTableName=$sqlTable
$bulkCopy.WriteToServer($csvDataTable)
#endregion csv2SQL

$Database                       = 'Name_Of_SQLDatabase'
$Server                         = '192.168.100.200'
$UserName                         = 'DatabaseUserName'
$Password                       = 'SecretPassword'
$SqlQuery                       = 'Select * FROM TestTable'

# Accessing Data Base 
$SqlConnection                  = New-Object -TypeName System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;user id=$UserName;pwd=$Password"
$SqlConnection.C
$SqlCmd                         = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText             = $SqlQuery
$SqlCmd.Connection              = $SqlConnection
$SqlAdapter                     = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand       = $SqlCmd
$set                            = New-Object data.dataset

# Filling Dataset 
$SqlAdapter.Fill($set)

# Consuming Data 
$Path = "$env:temp\report.hta"
$set.Tables[0] | ConvertTo-Html | Out-File -FilePath $Path

Invoke-Item -Path $Path 