param
(
  [Parameter(Mandatory = $true)]  
  [string]$subscriptionId,
  [Parameter(Mandatory = $true)]  
  [string]$destinationSubscriptionId,
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

if ((Get-AzureRmSubscription -SubscriptionId $subscriptionId).TenantId -ne (Get-AzureRmSubscription -SubscriptionId $destinationSubscriptionId).TenantId)
{
    throw "Source and destination subscriptions are not associated with the same tenant"
}

#Set-AzureRmContext -Subscription $destinationSubscriptionId
#Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute
#Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Network
#Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Storage
#Set-AzureRmContext -Subscription $subscriptionId

$resources = Get-AzureRmResource -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/resources" | select -ExpandProperty ResourceId
Move-AzureRmResource -DestinationSubscriptionId $destinationSubscriptionId -DestinationResourceGroupName $resourceGroupName -ResourceId $resources
