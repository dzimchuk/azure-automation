param
(
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vmName,
  [Parameter(Mandatory = $true)]  
  [string]$location,
  [Parameter(Mandatory = $true)]  
  [string]$storageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$storageAccountName,
  [Parameter(Mandatory = $true)]  
  [string]$osDiskName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Get the existing storage account  
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storageAccountResourceGroupName `
                                        -Name $storageAccountName

$blobEndpoint = $storageAccount.PrimaryEndpoints.Blob.ToString()
#$osDiskName = $vmName + 'OsDisk'
$osDiskUri = $blobEndpoint + "vhds/" + $osDiskName  + ".vhd"

# Get the existing VM
$originalVm = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName
$originalVm.Name
$originalVm.HardwareProfile.VmSize

Remove-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName

$newVm = New-AzureRmVMConfig -VMName $originalVm.Name -VMSize $originalVm.HardwareProfile.VmSize
Set-AzureRmVMOSDisk `
    -VM $newVm `
    -Name $osDiskName `
    -VhdUri $osDiskUri `
    -Caching ReadWrite `
    -CreateOption Attach `
    -Windows

foreach($nic in $originalVm.NetworkProfile.NetworkInterfaces)
{
    Add-AzureRmVMNetworkInterface -VM $newVm -Id $nic.Id
}

New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $newVm
