param
(
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$DiskName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$grant = Grant-AzureRmDiskAccess -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Access Read -DurationInSecond 10800

$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName
$storageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey.Value[0]

$containerName = "vhds"
$container = Get-AzureStorageContainer $containerName -Context $storageContext -ErrorAction Ignore
if ($container -eq $null)
{
    New-AzureStorageContainer $containerName -Context $storageContext
}

$vhd = $DiskName + '.vhd'
$blob = Start-AzureStorageBlobCopy -AbsoluteUri $grant.AccessSAS -DestContainer $containerName -DestBlob $vhd -DestContext $storageContext

$status = $blob | Get-AzureStorageBlobCopyState
$status
                                   
While($status.Status -eq "Pending"){
  Start-Sleep 10
  $status = $blob | Get-AzureStorageBlobCopyState
  $status
}