$rg = Get-AzureRmResourceGroup -Name TestNETRG

$vnet = Get-AzureRmVirtualNetwork -Name WEVNet -ResourceGroupName $rg.ResourceGroupName
$subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name default

$nsg = Get-AzureRmNetworkSecurityGroup -Name TestNSG -ResourceGroupName $rg.ResourceGroupName

Set-AzureRmVirtualNetworkSubnetConfig `
    -Name $subnetConfig.Name `
    -VirtualNetwork $vnet `
    -AddressPrefix $subnetConfig.AddressPrefix `
    -NetworkSecurityGroup $nsg

# instead we could just:
# $subnetConfig.NetworkSecurityGroup = $nsg

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet