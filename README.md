# SQLHelper.psm1

A single lightweight powershell module with cmdlets to query/update databases with any .net provider: SQL/OLEDB/ODBC/...

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

$numRows = Invoke-DBCommand -providerName "System.Data.SqlClient" -connectionString "<connStr>" -executeType "NonQuery" -commandText "insert into dbo.Products values (@id, @name, @datecreated)" -parameters @{"@id"=1;"@name"='NewProduct';"@datecreated"=[datetime]::Now}

```

## Bulk Copy

```powershell

# BulkCopy into a SQL Database

Invoke-SqlBulkCopy -connectionString "<connStr>" `
		-tableName "dbo.Products" `
		-data $dataSet.Tables[0] `
		-columnMappings @{"ProductKey" = "Id"; "EnglishProductName" = "Name"} -verbose

```

## Copy Data between databases

```powershell

$sourceConnStr = "<sourceConnStr>"

$destinationConnStr = "<destinationConnStr>"

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


