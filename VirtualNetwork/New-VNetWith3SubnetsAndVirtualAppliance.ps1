param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vNetName,
  [Parameter(Mandatory = $true)]  
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$cred = Get-Credential

# resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction Ignore
if (-Not $resourceGroup)
{
    $resourceGroup = New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

# vNet
$vnet = New-AzureRmVirtualNetwork `
    -Name $vNetName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AddressPrefix 192.168.0.0/16

Add-AzureRmVirtualNetworkSubnetConfig `
    -Name DMZ `
    -VirtualNetwork $vnet `
    -AddressPrefix 192.168.0.0/24

Add-AzureRmVirtualNetworkSubnetConfig `
    -Name FrontEnd `
    -VirtualNetwork $vnet `
    -AddressPrefix 192.168.1.0/24

Add-AzureRmVirtualNetworkSubnetConfig `
    -Name BackEnd `
    -VirtualNetwork $vnet `
    -AddressPrefix 192.168.2.0/24

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# create virtual appliance VM
$VMName = "FW1"

$subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -Name DMZ -VirtualNetwork $vnet

$nicName = $VMName + 'NIC'
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup.ResourceGroupName -Location $location `
    -SubnetId $subnetConfig.Id

$vm = New-AzureRmVMConfig -VMName $VMName -VMSize Standard_D1

$vm = Set-AzureRmVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName $VMName `
    -Credential $cred `
    -ProvisionVMAgent -EnableAutoUpdate

$vm = Set-AzureRmVMSourceImage `
    -VM $vm `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest

$osDiskName = $VMName + 'OsDisk'
$vm = Set-AzureRmVMOSDisk `
    -VM $vm `
    -Name $osDiskName `
    -DiskSizeInGB 128 `
    -CreateOption FromImage `
    -Caching ReadWrite `
    -StorageAccountType StandardLRS

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

New-AzureRmVM -ResourceGroupName $resourceGroup.ResourceGroupName -Location $location -VM $vm