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


$importRequest = New-AzureRmSqlDatabaseImport -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -DatabaseName $databaseName `
   -DatabaseMaxSizeBytes "262144000" `
   -StorageKeyType $storageKeytype `
   -StorageKey $storageKey `
   -StorageUri $bacpacUri `
   -Edition "Standard" `
   -ServiceObjectiveName "P6" `
   -AdministratorLogin $administratorLogin `
   -AdministratorLoginPassword $(ConvertTo-SecureString -String $administratorLoginPassword -AsPlainText -Force)

$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
[Console]::Write("Importing")

while ($importStatus.Status -eq "InProgress")
{
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 10
}

[Console]::WriteLine("")
$importStatus