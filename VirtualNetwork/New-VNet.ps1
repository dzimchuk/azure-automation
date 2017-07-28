$rg = Get-AzureRmResourceGroup -Name TestNETRG

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name default -AddressPrefix 10.1.0.0/24

$vnet = New-AzureRmVirtualNetwork `
    -Name WEVNet `
    -ResourceGroupName `
    $rg.ResourceGroupName `
    -Location 'west europe' `
    -AddressPrefix 10.1.0.0/16 `
    -Subnet $subnetConfig
