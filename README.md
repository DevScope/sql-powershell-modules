# SQLHelper.psm1
A single lightweight powershell module with cmdlets to query/update databases with any .net provider: SQL/OLEDB/ODBC/...

Samples:

## Query

```powershell

# Query a SQL database File

$dataSet = Invoke-DBCommand -connectionString "<connStr>" -commandText "select * from [dbo].[Table]"

# Query a Excel File

$dataSet = Invoke-DBCommand -providerName "System.Data.OleDb" -connectionString "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='$currentPath\ExcelData.xlsx';Extended Properties=Excel 12.0" -commandText "select * from [Sheet1$]" -verbose

```

## Insert/Update

```powershell

# Insert row into a SQL database

$dataSet.Tables[0].Rows |% {	
	$numRows = Invoke-DBCommand -providerName "System.Data.SqlClient" -connectionString "Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=Dummy;Data Source=.\sql2012" -executeType "NonQuery" -commandText "insert into dbo.Products values (@id, @name, @datecreated)" -parameters @{"@id"=$_.ProductKey;"@name"=$_.EnglishProductName;"@datecreated"=[datetime]::Now}					
}

```

## Bulk Copy

```powershell

# BulkCopy into a SQL Database

Invoke-SqlBulkCopy -connectionString "Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=Dummy;Data Source=.\sql2012" `
		-tableName "dbo.Products" `
		-data $dataSet.Tables[0] `
		-columnMappings @{"ProductKey" = "Id"; "EnglishProductName" = "Name"} -verbose

```

## Copy Data between databases

```powershell

$sourceConnStr = "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=AdventureWorksDW2012;Data Source=.\sql2014"

$destinationConnStr = "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=DestinationDB;Data Source=.\sql2014"

$tables = @("[dbo].[DimProduct]", "[dbo].[FactInternetSales]")

$steps = $tables.Count
$i = 1;

$tables |% {
		
	$sourceTableName = $_
	$destinationTableName = $sourceTableName
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Executing source query over '$sourceTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	$sourceTable = (Invoke-DBCommand -connectionString $sourceConnStr -commandText "select * from $sourceTableName").Tables[0]
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Creating destination table '$destinationTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	Invoke-SQLCreateTable -connectionString $destinationConnStr -table $sourceTable -tableName $destinationTableName -force
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Loading destination table '$destinationTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	Invoke-SQLBulkCopy -connectionString $destinationConnStr -data $sourceTable -tableName $destinationTableName				
	
	$i++;
}

Write-Progress -activity "Tables Copy" -Completed

```


