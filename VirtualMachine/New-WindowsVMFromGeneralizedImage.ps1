param
(
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$VMName,
  [Parameter(Mandatory = $true)]  
  [string]$VNetName,
  [Parameter(Mandatory = $true)]  
  [string]$VNetResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$SubnetName,
  [Parameter(Mandatory = $true)]  
  [string]$ImageName,
  [Parameter(Mandatory = $true)]  
  [string]$ImageResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$Location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#$securePassword = ConvertTo-SecureString "Password" -AsPlainText -Force
#$cred = New-Object System.Management.Automation.PSCredential ("username", $securePassword);
$cred = Get-Credential


# resource group
$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Ignore
if (-Not $rg)
{
    $rg = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
}


# network
$subnetConfig = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig `
    -Name $SubnetName

$pipName = $VMName + 'IP'
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rg.ResourceGroupName -Location $Location `
    -AllocationMethod Static


# NIC
$nicName = $VMName + 'NIC'
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rg.ResourceGroupName -Location $Location `
    -SubnetId $subnetConfig.Id -PublicIpAddressId $pip.Id


# VM
$vm = New-AzureRmVMConfig -VMName $VMName -VMSize Standard_A1_v2

$vm = Set-AzureRmVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName $VMName `
    -Credential $cred `
    -ProvisionVMAgent -EnableAutoUpdate

$image = Get-AzureRmImage -ResourceGroupName $ImageResourceGroupName -ImageName $ImageName
$vm = Set-AzureRmVMSourceImage `
    -VM $vm `
    -Id $image.Id

$osDiskName = $VMName + 'OsDisk'
$vm = Set-AzureRmVMOSDisk `
    -VM $vm `
    -Name $osDiskName `
    -DiskSizeInGB 128 `
    -CreateOption FromImage `
    -Caching ReadWrite `
    -StorageAccountType StandardLRS

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

New-AzureRmVM -ResourceGroupName $rg.ResourceGroupName -Location $Location -VM $vm