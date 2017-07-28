param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$scaleSetName,
  [Parameter(Mandatory = $true)]
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Define your scale set information
$mySubscriptionId = (Get-AzureRmSubscription).SubscriptionId


# Create a scale up rule to increase the number instances after 60% average CPU usage exceeded for a 5 minute period
$myRuleScaleUp = New-AzureRmAutoscaleRule `
  -MetricName "Percentage CPU" `
  -MetricResourceId /subscriptions/$mySubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$scaleSetName `
  -Operator GreaterThan `
  -MetricStatistic Average `
  -Threshold 60 `
  -TimeGrain 00:01:00 `
  -TimeWindow 00:05:00 `
  -ScaleActionCooldown 00:05:00 `
  -ScaleActionDirection Increase `
  -ScaleActionValue 1

# Create a scale down rule to decrease the number of instances after 30% average CPU usage over a 5 minute period
$myRuleScaleDown = New-AzureRmAutoscaleRule `
  -MetricName "Percentage CPU" `
  -MetricResourceId /subscriptions/$mySubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$scaleSetName `
  -Operator LessThan `
  -MetricStatistic Average `
  -Threshold 30 `
  -TimeGrain 00:01:00 `
  -TimeWindow 00:05:00 `
  -ScaleActionCooldown 00:05:00 `
  -ScaleActionDirection Decrease `
  -ScaleActionValue 1

# Create a scale profile with your scale up and scale down rules
$myScaleProfile = New-AzureRmAutoscaleProfile `
  -DefaultCapacity 2  `
  -MaximumCapacity 10 `
  -MinimumCapacity 2 `
  -Rules $myRuleScaleUp,$myRuleScaleDown `
  -Name "autoprofile"

# Apply the autoscale rules
Add-AzureRmAutoscaleSetting `
  -Location $location `
  -Name "autosetting" `
  -ResourceGroup $resourceGroupName `
  -TargetResourceId /subscriptions/$mySubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$scaleSetName `
  -AutoscaleProfiles $myScaleProfile