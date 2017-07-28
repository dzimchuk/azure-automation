param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$nicName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


$nic = Get-AzureRmNetworkInterface `
    -ResourceGroupName $resourceGroupName `
    -Name $nicName

$nic.Ipconfigurations[0].LoadBalancerBackendAddressPools=$null

Set-AzureRmNetworkInterface -NetworkInterface $nic