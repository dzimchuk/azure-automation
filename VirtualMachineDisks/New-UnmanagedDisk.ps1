param
(
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountName,
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$DiskName,
  [Parameter(Mandatory = $true)]  
  [string]$VMName,
  [Parameter(Mandatory = $true)]  
  [int]$Lun,
  [Parameter(Mandatory = $true)]  
  [string]$Location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Get the existing storage account  
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $StorageAccountResourceGroupName `
                                        -Name $StorageAccountName

$blobEndpoint = $storageAccount.PrimaryEndpoints.Blob.ToString()

$dataDiskUri = $blobEndpoint + "vhds/" + $DiskName  + ".vhd"

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

# Attach data disk to the VM configuration
Add-AzureRmVMDataDisk -Name $DiskName `
                      -VhdUri $dataDiskUri -Caching None `
                      -DiskSizeInGB 128 -Lun $Lun -CreateOption empty `
                      -VM $vm

Update-AzureRmVM -VM $vm -ResourceGroupName $ResourceGroupName
