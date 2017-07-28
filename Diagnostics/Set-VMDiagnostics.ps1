param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vmName,
  [Parameter(Mandatory = $true)]  
  [string]$storageAccountName,
  [Parameter(Mandatory = $true)]  
  [string]$diagnosticsConfigurationPath
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#$storageAccount = 'ACCOUNT_NAME'
#$storageKey = 'ACCOUNT_KEY'
#$storageContext = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageKey

Set-AzureRmVMDiagnosticsExtension -ResourceGroupName $resourceGroupName -VMName $vmName -DiagnosticsConfigurationPath $diagnosticsConfigurationPath -StorageAccountName $storageAccountName