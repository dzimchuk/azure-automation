# IP forwarding enables the VM a NIC is attached to:
# Receive network traffic not destined for one of the IP addresses assigned to any of the IP configurations assigned to the NIC.
# Send network traffic with a different source IP address than the one assigned to one of a NIC's IP configurations.

param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$nicName,
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

$nic.EnableIPForwarding = 1

Set-AzureRmNetworkInterface -NetworkInterface $nic