# Run New-VNetWith3SubnetsAndVirtualAppliance.ps1 to set up target environment

# Create the UDR for the front-end subnet
$route = New-AzureRmRouteConfig -Name RouteToBackEnd `
    -AddressPrefix 192.168.2.0/24 -NextHopType VirtualAppliance `
    -NextHopIpAddress 192.168.0.4

$routeTable = New-AzureRmRouteTable -ResourceGroupName TestRG -Location westus `
    -Name UDR-FrontEnd -Route $route

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name FrontEnd `
    -AddressPrefix 192.168.1.0/24 -RouteTable $routeTable

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Create the UDR for the back-end subnet
$route = New-AzureRmRouteConfig -Name RouteToFrontEnd `
    -AddressPrefix 192.168.1.0/24 -NextHopType VirtualAppliance `
    -NextHopIpAddress 192.168.0.4

$routeTable = New-AzureRmRouteTable -ResourceGroupName TestRG -Location westus `
    -Name UDR-BackEnd -Route $route

Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name BackEnd `
    -AddressPrefix 192.168.2.0/24 -RouteTable $routeTable

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Enable IP forwarding on FW1
$nicfw1 = Get-AzureRmNetworkInterface -ResourceGroupName TestRG -Name NICFW1

$nicfw1.EnableIPForwarding = 1
Set-AzureRmNetworkInterface -NetworkInterface $nicfw1
