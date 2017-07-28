param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$nicName,
  [ValidateSet('Static','Dynamic')]
  [string]$allocationMethod,
  [string]$privateIpAddress,
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

$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName

$nic.IpConfigurations[0].PrivateIpAllocationMethod = $allocationMethod
if ($allocationMethod -eq 'Static')
{
    $nic.IpConfigurations[0].PrivateIpAddress = $privateIpAddress
}

Set-AzureRmNetworkInterface -NetworkInterface $nic
