param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$nicName,
  [Parameter(Mandatory = $true)]  
  [string]$lbName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$lb = Get-AzureRmLoadBalancer -ResourceGroupName $resourceGroupName -Name $lbName

$nic = Get-AzureRmNetworkInterface `
    -ResourceGroupName $resourceGroupName `
    -Name $nicName

$nic.Ipconfigurations[0].LoadBalancerBackendAddressPools=$lb.BackendAddressPools[0]

Set-AzureRmNetworkInterface -NetworkInterface $nic