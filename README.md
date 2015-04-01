# SQLHelper.psm1

A single lightweight powershell module with cmdlets to query/update databases with any .net provider: SQL/OLEDB/ODBC/...

## Query

```powershell

# Query a SQL database File

$dataSet = Invoke-SQLCommand -executeType "QueryAsDataSet" -connectionString "<connStr>" -commandText "select * from [dbo].[Table]"

# Query a Excel File

$dataSet = Invoke-SQLCommand -executeType "QueryAsDataSet" -providerName "System.Data.OleDb" -connectionString "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='$currentPath\ExcelData.xlsx';Extended Properties=Excel 12.0" -commandText "select * from [Sheet1$]" -verbose

```

## Insert/Update

```powershell

# Insert row into a SQL database

$numRows = Invoke-SQLCommand -providerName "System.Data.SqlClient" -connectionString "<connStr>" -executeType "NonQuery" -commandText "insert into dbo.Products values (@id, @name, @datecreated)" -parameters @{"@id"=1;"@name"='NewProduct';"@datecreated"=[datetime]::Now}

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

$sourceConnStr = "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=AdventureWorksDW2012;Data Source=.\sql2014"

$destinationConnStr = "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=DestinationDB;Data Source=.\sql2014"

$tables = @("[dbo].[DimProduct]", "[dbo].[FactInternetSales]")

$steps = $tables.Count
$i = 1;

$tables |% {
		
	$sourceTableName = $_
	$destinationTableName = $sourceTableName
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Executing source query over '$sourceTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	$sourceTable = Invoke-SQLCommand -executeType QueryAsTable -connectionString $sourceConnStr -commandText "select * from $sourceTableName" -Verbose
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Creating destination table '$destinationTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	New-SQLTable -connectionString $destinationConnStr -data $sourceTable -tableName $destinationTableName -force -Verbose
	
	Write-Progress -activity "Tables Copy" -CurrentOperation "Loading destination table '$destinationTableName'" -PercentComplete (($i / $steps)  * 100) -Verbose
	
	Invoke-SQLBulkCopy -connectionString $destinationConnStr -data $sourceTable -tableName $destinationTableName -Verbose
	
	$i++;
}

Write-Progress -activity "Tables Copy" -Completed

```


