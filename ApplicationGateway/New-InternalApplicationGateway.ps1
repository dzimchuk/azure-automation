param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetName,
  [Parameter(Mandatory = $true)]  
  [string]$subNetName,
  [Parameter(Mandatory = $true)]
  [string]$appGatewayName,
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

$subnet = Get-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $vNetResourceGroupName `
    | Get-AzureRmVirtualNetworkSubnetConfig -Name $subNetName


# AppGateway IP config (within its subnet, each instance will get its IP)
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name gatewayIP01 -Subnet $subnet

# Backend IP pool
$pool = New-AzureRmApplicationGatewayBackendAddressPool `
    -Name pool01 `
    -BackendIPAddresses 134.170.185.46, 134.170.188.221, 134.170.185.50

# Backend pool settings
$poolSetting = New-AzureRmApplicationGatewayBackendHttpSettings `
    -Name "besetting01" `
    -Port 80 `
    -Protocol Http `
    -CookieBasedAffinity Disabled `
    -RequestTimeout 120

# AppGateway frontend port
$fp = New-AzureRmApplicationGatewayFrontendPort -Name frontendport01  -Port 80

# AppGateway frontend IP config
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig -Name fipconfig01 -Subnet $subnet -PrivateIPAddress 10.1.10.1
# or dynamic private IP:
# $fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig -Name fipconfig01 -Subnet $subnet

# listener
$listener = New-AzureRmApplicationGatewayHttpListener `
    -Name listener01 `
    -Protocol Http `
    -FrontendIPConfiguration $fipconfig `
    -FrontendPort $fp

# request routing rule
$rule = New-AzureRmApplicationGatewayRequestRoutingRule `
    -Name rule01 `
    -RuleType Basic `
    -BackendHttpSettings $poolSetting `
    -HttpListener $listener `
    -BackendAddressPool $pool

# AppGateway instances (up to 10, Small, Medium, Large)
$sku = New-AzureRmApplicationGatewaySku -Name Standard_Small -Tier Standard -Capacity 2

# AppGateway
$appgw = New-AzureRmApplicationGateway `
    -Name $appGatewayName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -BackendAddressPools $pool `
    -BackendHttpSettingsCollection $poolSetting `
    -FrontendIpConfigurations $fipconfig `
    -GatewayIpConfigurations $gipconfig `
    -FrontendPorts $fp `
    -HttpListeners $listener `
    -RequestRoutingRules $rule `
    -Sku $sku

