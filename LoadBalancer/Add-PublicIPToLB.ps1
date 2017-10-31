param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$loadBalancerName,
  [Parameter(Mandatory = $true)]  
  [string]$pipName,
  [Parameter(Mandatory = $true)]  
  [string]$domainNameLabel,
  [Parameter(Mandatory = $true)]  
  [string]$backendPort,
  [Parameter(Mandatory = $true)]  
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$lb = Get-AzureRmLoadBalancer -Name $loadBalancerName -ResourceGroupName $resourceGroupName


$pip = New-AzureRmPublicIpAddress `
    -Name $pipName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AllocationMethod Dynamic `
    -DomainNameLabel $domainNameLabel

$frontEndIpName = $pipName + 'Config'
$frontEndIp = New-AzureRmLoadBalancerFrontendIpConfig `
    -Name $frontEndIpName `
    -PublicIpAddress $pip

$lb.FrontendIpConfigurations.Add($frontEndIp)


$probeName = 'AppProbe_Port_' + $backendPort
$probe = New-AzureRmLoadBalancerProbeConfig `
    -Name $probeName `
    -Protocol Tcp `
    -Port $backendPort `
    -IntervalInSeconds 15 `
    -ProbeCount 2

$lbRuleName = 'AppRule_Port_' + $backendPort
$lbRule = New-AzureRmLoadBalancerRuleConfig `
  -Name $lbRuleName `
  -FrontendIpConfiguration $frontEndIp `
  -BackendAddressPool $lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort $backendPort `
  -Probe $probe

$lb.Probes.Add($probe)
$lb.LoadBalancingRules.Add($lbRule)

Set-AzureRmLoadBalancer -LoadBalancer $lb
