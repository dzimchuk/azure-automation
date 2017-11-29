param
(
  [Parameter(Mandatory = $true)]  
  [string]$subscriptionId,
  [Parameter(Mandatory = $true)]  
  [string]$destinationSubscriptionId,
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$destinationResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$destinationLocation
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

if ((Get-AzureRmSubscription -SubscriptionId $subscriptionId).TenantId -ne (Get-AzureRmSubscription -SubscriptionId $destinationSubscriptionId).TenantId)
{
    throw "Source and destination subscriptions are not associated with the same tenant"
}

Set-AzureRmContext -Subscription $destinationSubscriptionId
#Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute
#Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Network
#Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Storage

$rg = Get-AzureRmResourceGroup -Name $destinationResourceGroupName -Location $destinationLocation -ErrorAction Ignore
if (-Not $rg)
{
    $rg = New-AzureRmResourceGroup -Name $destinationResourceGroupName -Location $destinationLocation
}

Set-AzureRmContext -Subscription $subscriptionId

$resources = Get-AzureRmResource -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/resources" `
    | ? { $_.ResourceType -ne 'Microsoft.Compute/virtualMachines/extensions' } `
    | select -ExpandProperty ResourceId
    
Move-AzureRmResource -DestinationSubscriptionId $destinationSubscriptionId -DestinationResourceGroupName $destinationResourceGroupName -ResourceId $resources
