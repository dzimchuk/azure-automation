param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$newAvailSetName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$subnetName,
  [Parameter(Mandatory = $true)]  
  [string]$loadBalancerPrivateIpAddress,
  [Parameter(Mandatory = $true)]  
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# VM credentials
$cred = Get-Credential

# resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction Ignore
if (-Not $resourceGroup)
{
    $resourceGroup = New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

# availability set
$availSet = Get-AzureRmAvailabilitySet -ResourceGroupName $resourceGroupName -Name $newAvailSetName -ErrorAction Ignore
if (-Not $availSet) 
{
    $availset = New-AzureRmAvailabilitySet `
        -ResourceGroupName $resourceGroupName `
        -Name $newAvailSetName `
        -Location $location `
        -Managed `
        -PlatformUpdateDomainCount 2 `
        -PlatformFaultDomainCount 2
}


# subnet
$subnetConfig = Get-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig `
    -Name $subnetName

# load balancer
$frontEndIP = New-AzureRmLoadBalancerFrontendIpConfig -Name BackEndIPConfig -PrivateIpAddress $loadBalancerPrivateIpAddress -SubnetId $subnetConfig.Id
$backendPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name BackEndPool

# health probe
$probe = New-AzureRmLoadBalancerProbeConfig -Name AppProbe -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2

# load balancing rule
$lbRule = New-AzureRmLoadBalancerRuleConfig `
  -Name AppLBRule `
  -FrontendIpConfiguration $frontEndIP `
  -BackendAddressPool $backendPool `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $probe

# NAT rules
$inboundNATRule1= New-AzureRmLoadBalancerInboundNatRuleConfig `
    -Name "RDP1" `
    -FrontendIpConfiguration $frontEndIP `
    -Protocol TCP `
    -FrontendPort 3441 `
    -BackendPort 3389

$inboundNATRule2= New-AzureRmLoadBalancerInboundNatRuleConfig `
    -Name "RDP2" `
    -FrontendIpConfiguration $frontEndIP `
    -Protocol TCP `
    -FrontendPort 3442 `
    -BackendPort 3389

# create load balancer
$lb = New-AzureRmLoadBalancer `
    -Name BackEndLB `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -FrontendIpConfiguration $frontEndIP `
    -BackendAddressPool $backendPool `
    -InboundNatRule $inboundNATRule1,$inboundNATRule2 `
    -LoadBalancingRule $lbRule `
    -Probe $probe


# network interfaces
for ($i=1; $i -le 2; $i++)
{
   New-AzureRmNetworkInterface `
     -ResourceGroupName $resourceGroupName `
     -Name FrontEndNIC$i `
     -Location $location `
     -Subnet $subnetConfig `
     -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] `
     -LoadBalancerInboundNatRule $lb.InboundNatRules[$i]
}

# VMs
for ($i=1; $i -le 2; $i++)
{
  $vm = New-AzureRmVMConfig `
    -VMName FrontEndVM$i `
    -VMSize Standard_D1 `
    -AvailabilitySetId $availSet.Id

  $vm = Set-AzureRmVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName FrontEndVM$i `
    -Credential $cred `
    -ProvisionVMAgent `
    -EnableAutoUpdate

  $vm = Set-AzureRmVMSourceImage `
    -VM $vm `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest

  $vm = Set-AzureRmVMOSDisk `
    -VM $vm `
    -Name FrontEndOsDisk$i `
    -DiskSizeInGB 128 `
    -CreateOption FromImage `
    -Caching ReadWrite

  $nic = Get-AzureRmNetworkInterface `
    -ResourceGroupName $resourceGroupName `
    -Name FrontEndNIC$i

  $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
  
  New-AzureRmVM `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -VM $vm
}

# intall IIS and update home page
for ($i=1; $i -le 2; $i++)
{
   Set-AzureRmVMExtension `
     -ResourceGroupName $resourceGroupName `
     -ExtensionName IIS `
     -VMName FrontEndVM$i `
     -Publisher Microsoft.Compute `
     -ExtensionType CustomScriptExtension `
     -TypeHandlerVersion 1.4 `
     -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
     -Location $location
}
