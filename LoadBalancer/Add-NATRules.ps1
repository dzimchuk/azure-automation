param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
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

$lb = Get-AzureRmLoadBalancer -Name FrontEndLB -ResourceGroupName $resourceGroupName

for ($i=1; $i -le 2; $i++)
{
    $nic = Get-AzureRmNetworkInterface -Name FrontEndNIC$i -ResourceGroupName $resourceGroupName

    $natRule = New-AzureRmLoadBalancerInboundNatRuleConfig `
        -Name rdpNatRule$i `
        -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
        -Protocol Tcp `
        -BackendPort 3389 `
        -FrontendPort 344$i

    $lb.InboundNatRules.Add($natRule)
    Set-AzureRmLoadBalancer -LoadBalancer $lb

    $nic.IpConfigurations[0].LoadBalancerInboundNatRules.Add($natRule)
    Set-AzureRmNetworkInterface -NetworkInterface $nic
}