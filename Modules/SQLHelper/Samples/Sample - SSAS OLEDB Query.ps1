cls

$ErrorActionPreference = "Stop"

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition –Parent)

Import-Module "$currentPath\..\SQLHelper.psm1" -Force

$sourceConnStr = "Provider=MSOLAP.5;Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=AdventureWorks;Data Source=.\sql2014;MDX Compatibility=1;Safety Options=2;MDX Missing Member Mode=Error;Update Isolation Level=2"

# Execute the query

$result = Invoke-SQLQuery -providerName "System.Data.OleDb" -connectionString $sourceConnStr -query "select [Measures].[Internet Sales Amount] on 0, [Product].[Product Categories].[Category] on 1 from [Adventure Works]"

$result | Out-GridView



