param
(
  [Parameter(Mandatory = $true)]  
  [string]$rg,
  [Parameter(Mandatory = $true)]  
  [string]$vmName,
  [Parameter(Mandatory = $true)]  
  [string]$newAvailSetName,
  [Parameter(Mandatory = $true)]  
  [string]$storageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$storageAccountName,
  [Parameter(Mandatory = $true)]  
  [string]$location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


#Create new availability set if it does not exist
$availSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $newAvailSetName -ErrorAction Ignore
if (-Not $availSet) {
$availset = New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $newAvailSetName -Location $location
}


# Get the existing storage account  
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storageAccountResourceGroupName `
                                        -Name $storageAccountName

$blobEndpoint = $storageAccount.PrimaryEndpoints.Blob.ToString()
$osDiskName = $vmName + 'OsDisk'
$osDiskUri = $blobEndpoint + "vhds/" + $osDiskName  + ".vhd"


#Create the basic configuration for the replacement VM
$newVM = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_D1 -AvailabilitySetId $availSet.Id
Set-AzureRmVMOSDisk -VM $newVM -VhdUri $osDiskUri -Name $osDiskName -CreateOption Attach -Windows -Caching ReadWrite

$nicName = $vmName + 'NIC'
$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rg

Add-AzureRmVMNetworkInterface -VM $newVM -Id $nic.Id

#Create the VM
New-AzureRmVM -ResourceGroupName $rg -Location $location -VM $newVM

