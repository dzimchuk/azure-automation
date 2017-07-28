param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$scaleSetName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


# Get current scale set
$scaleset = Get-AzureRmVmss `
  -ResourceGroupName $resourceGroupName `
  -VMScaleSetName $scaleSetName

# Loop through the instanaces in your scale set
for ($i=0; $i -le ($scaleset.Sku.Capacity - 1); $i++) {
    Get-AzureRmVmssVM -ResourceGroupName $resourceGroupName `
      -VMScaleSetName $scaleSetName `
      -InstanceId $i
}