# sql-powershell-modules
A collection of powerfull but simple powershell cmdlets for working with SQL databases.

# SQLHelper.psm1
A single lightweight powershell module with cmdlets to query over SQL/OLEDB/ODBC/... databases.

Examples of usage:


```powershell

# Query a SQLDatabase

$dataSet = Invoke-DBCommand -connectionString "<connStr>" -commandText "select * from [dbo].[Table]"

# Query a Excel File

$dataSet = Invoke-DBCommand -providerName "System.Data.OleDb" -connectionString "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='$currentPath\ExcelData.xlsx';Extended Properties=Excel 12.0" -commandText "select * from [Sheet1$]" -verbose

# Insert row into a SQL database

$dataSet.Tables[0].Rows |% {	
	$numRows = Invoke-DBCommand -providerName "System.Data.SqlClient" -connectionString "Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=Dummy;Data Source=.\sql2012" -executeType "NonQuery" -commandText "insert into dbo.Products values (@id, @name, @datecreated)" -parameters @{"@id"=$_.ProductKey;"@name"=$_.EnglishProductName;"@datecreated"=[datetime]::Now}					
}

# BulkCopy into a SQL Database

Invoke-SqlBulkCopy -connectionString "Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=Dummy;Data Source=.\sql2012" `
		-tableName "dbo.Products" `
		-data $dataSet.Tables[0] `
		-columnMappings @{"ProductKey" = "Id"; "EnglishProductName" = "Name"} -verbose

```


