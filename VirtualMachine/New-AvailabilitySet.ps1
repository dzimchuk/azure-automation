param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$avSetName,
  [Parameter(Mandatory = $true)]  
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

New-AzureRmAvailabilitySet `
    -ResourceGroupName $resourceGroupName `
    -Name $avSetName `
    -Location $location `
    -Managed `
    -PlatformUpdateDomainCount 2 `
    -PlatformFaultDomainCount 2

    