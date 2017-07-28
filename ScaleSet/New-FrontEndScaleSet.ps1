param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$scaleSetName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$subnetName,
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

# subnet
$subnetConfig = Get-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig `
    -Name $subnetName



# load balancer
$lb = Get-AzureRmLoadBalancer -Name FrontEndLB -ResourceGroupName $resourceGroupName
if (-Not $lb)
{
    # Create a public IP address
    $publicIP = New-AzureRmPublicIpAddress `
      -ResourceGroupName $resourceGroupName `
      -Location $location `
      -AllocationMethod Static `
      -Name FrontEndIP
    
    # Create a frontend and backend IP pool
    $frontendIP = New-AzureRmLoadBalancerFrontendIpConfig `
      -Name FrontEndPool `
      -PublicIpAddress $publicIP
    
    $backendPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name BackEndPool
    
    # Create the load balancer
    $lb = New-AzureRmLoadBalancer `
      -ResourceGroupName $resourceGroupName `
      -Name FrontEndLB `
      -Location $location `
      -FrontendIpConfiguration $frontendIP `
      -BackendAddressPool $backendPool
    
    # Create a load balancer health probe on port 80
    Add-AzureRmLoadBalancerProbeConfig -Name AppProbe `
      -LoadBalancer $lb `
      -Protocol tcp `
      -Port 80 `
      -IntervalInSeconds 15 `
      -ProbeCount 2
    
    # Create a load balancer rule to distribute traffic on port 80
    Add-AzureRmLoadBalancerRuleConfig `
      -Name AppLBRule `
      -LoadBalancer $lb `
      -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
      -BackendAddressPool $lb.BackendAddressPools[0] `
      -Protocol Tcp `
      -FrontendPort 80 `
      -BackendPort 80
    
    # Update the load balancer configuration
    Set-AzureRmLoadBalancer -LoadBalancer $lb
}


#VMSS

# Create a config object
$vmssConfig = New-AzureRmVmssConfig `
    -Location $location `
    -SkuCapacity 2 `
    -SkuName Standard_D1 `
    -UpgradePolicyMode Automatic

# Define the script for your Custom Script Extension to run
$publicSettings = @{
    "fileUris" = (,"https://raw.githubusercontent.com/iainfoulds/azure-samples/master/automate-iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
}

# Use Custom Script Extension to install IIS and configure basic website
Add-AzureRmVmssExtension -VirtualMachineScaleSet $vmssConfig `
    -Name "customScript" `
    -Publisher "Microsoft.Compute" `
    -Type "CustomScriptExtension" `
    -TypeHandlerVersion 1.8 `
    -Setting $publicSettings


# Reference a virtual machine image from the gallery
Set-AzureRmVmssStorageProfile $vmssConfig `
  -ImageReferencePublisher MicrosoftWindowsServer `
  -ImageReferenceOffer WindowsServer `
  -ImageReferenceSku 2016-Datacenter `
  -ImageReferenceVersion latest

# Set up information for authenticating with the virtual machine
Set-AzureRmVmssOsProfile $vmssConfig `
  -AdminUsername azureuser `
  -AdminPassword P@ssword! `
  -ComputerNamePrefix VM

$ipConfig = New-AzureRmVmssIpConfig `
  -Name "FrontEndIPConfig" `
  -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools[0].Id `
  -SubnetId $subnetConfig.Id

# Attach the virtual network to the config object
Add-AzureRmVmssNetworkInterfaceConfiguration `
  -VirtualMachineScaleSet $vmssConfig `
  -Name "network-config" `
  -Primary $true `
  -IPConfiguration $ipConfig

# Create the scale set with the config object (this step might take a few minutes)
New-AzureRmVmss `
  -ResourceGroupName $resourceGroupName `
  -Name $scaleSetName `
  -VirtualMachineScaleSet $vmssConfig  

