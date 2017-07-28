param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$nicName,
  [Parameter(Mandatory = $true)]  
  [string]$dnsServerIpAddress,
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

$nic.DnsSettings.DnsServers.Add($dnsServerIpAddress)

Set-AzureRmNetworkInterface -NetworkInterface $nic