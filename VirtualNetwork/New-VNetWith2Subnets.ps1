param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetName,
  [Parameter(Mandatory = $true)]  
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction Ignore
if (-Not $resourceGroup)
{
    $resourceGroup = New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

# vNet
$vnet = New-AzureRmVirtualNetwork `
    -Name $vNetName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AddressPrefix 192.168.0.0/16

Add-AzureRmVirtualNetworkSubnetConfig `
    -Name FrontEnd `
    -VirtualNetwork $vnet `
    -AddressPrefix 192.168.1.0/24

Add-AzureRmVirtualNetworkSubnetConfig `
    -Name BackEnd `
    -VirtualNetwork $vnet `
    -AddressPrefix 192.168.2.0/24

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
