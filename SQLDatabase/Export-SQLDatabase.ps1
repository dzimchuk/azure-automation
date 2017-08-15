param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$serverName,
  [Parameter(Mandatory = $true)]  
  [string]$databaseName,
  [Parameter(Mandatory = $true)]  
  [string]$storageKeytype,
  [Parameter(Mandatory = $true)]  
  [string]$storageKey,
  [Parameter(Mandatory = $true)]  
  [string]$bacpacUri,
  [Parameter(Mandatory = $true)]  
  [string]$administratorLogin,
  [Parameter(Mandatory = $true)]  
  [string]$administratorLoginPassword
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $resourceGroupName -ServerName $serverName `
  -DatabaseName $databaseName -StorageKeytype $storageKeytype -StorageKey $storageKey -StorageUri $bacpacUri `
  -AdministratorLogin $administratorLogin -AdministratorLoginPassword $(ConvertTo-SecureString -String $administratorLoginPassword -AsPlainText -Force)

$exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
[Console]::Write("Exporting")

while ($exportStatus.Status -eq "InProgress")
{
    $exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 10
}

[Console]::WriteLine("")
$exportStatus