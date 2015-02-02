# sql-powershell-modules
A collection of powerfull but simple powershell cmdlets for working with SQL databases

# SQLHelper.psm1

Examples of usage:

$dataSet = Invoke-DBCommand -providerName "System.Data.OleDb" -connectionString "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='$currentPath\ExcelData.xlsx';Extended Properties=Excel 12.0" -commandText "select * from [Sheet1$]" -verbose

$dataSet.Tables[0].Rows |% {	
	$numRows = Invoke-DBCommand -providerName "System.Data.SqlClient" `
		-connectionString "Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=Dummy;Data Source=.\sql2012" `
		-executeType "NonQuery" `
		-commandText "insert into dbo.Products values (@id, @name, @datecreated)" `
		-parameters @{"@id"=$_.ProductKey;"@name"=$_.EnglishProductName;"@datecreated"=[datetime]::Now}					
}

Invoke-SqlBulkCopy -connectionString "Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=Dummy;Data Source=.\sql2012" `
		-tableName "dbo.Products" `
		-data $dataSet.Tables[0] `
		-columnMappings @{"ProductKey" = "Id"; "EnglishProductName" = "Name"} -verbose
