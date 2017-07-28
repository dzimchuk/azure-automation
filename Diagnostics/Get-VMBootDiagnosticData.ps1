param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]
  [string]$vmName,
  [Parameter(Mandatory = $true)]  
  [string]$localPath
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

Get-AzureRmVMBootDiagnosticsData -ResourceGroupName $resourceGroupName -Name $vmName -Windows -LocalPath $localPath
