param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetName,
  [Parameter(Mandatory = $true)]  
  [string]$subNetName,
  [Parameter(Mandatory = $true)]  
  [string]$addressPrefix
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$vnet = Get-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName

Add-AzureRmVirtualNetworkSubnetConfig `
    -Name $subNetName `
    -VirtualNetwork $vnet `
    -AddressPrefix $addressPrefix

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
