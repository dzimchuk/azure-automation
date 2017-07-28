param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$scaleSetName,
  [Parameter(Mandatory = $true)]
  [int]$vmCount
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


# Get current scale set
$scaleset = Get-AzureRmVmss `
  -ResourceGroupName $resourceGroupName `
  -VMScaleSetName $scaleSetName

$scaleset.Sku.Capacity = $vmCount

Update-AzureRmVmss -ResourceGroupName $resourceGroupName -VirtualMachineScaleSet $scaleset -Name $scaleSetName
