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
  [string]$Location,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


$cred = Get-Credential


# Get the existing storage account  
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $StorageAccountResourceGroupName `
                                        -Name $StorageAccountName

$blobEndpoint = $storageAccount.PrimaryEndpoints.Blob.ToString()
$osDiskName = $VMName + 'OsDisk'
$osDiskUri = $blobEndpoint + "vhds/" + $osDiskName  + ".vhd"



$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName

$subnetConfig = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig `
    -Name $SubnetName

$pipName = $VMName + 'IP'
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rg.ResourceGroupName -Location $Location `
    -AllocationMethod Static

$nicName = $VMName + 'NIC'
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rg.ResourceGroupName -Location $Location `
    -SubnetId $subnetConfig.Id -PublicIpAddressId $pip.Id

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

$vm = Set-AzureRmVMOSDisk `
    -VM $vm `
    -Name $osDiskName `
    -DiskSizeInGB 128 `
    -CreateOption FromImage `
    -Caching ReadWrite `
    -VhdUri $osDiskUri

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

New-AzureRmVM -ResourceGroupName $rg.ResourceGroupName -Location $Location -VM $vm