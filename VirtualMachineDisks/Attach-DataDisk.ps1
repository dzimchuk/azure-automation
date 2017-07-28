param
(
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$DiskName,
  [Parameter(Mandatory = $true)]  
  [string]$VMName,
  [Parameter(Mandatory = $true)]  
  [string]$Location,
  [Parameter(Mandatory = $true)]  
  [int]$Lun
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$dataDisk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

$vm = Add-AzureRmVMDataDisk -VM $vm -Name $DiskName -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun $Lun -Caching ReadWrite

Update-AzureRmVM -VM $vm -ResourceGroupName $ResourceGroupName
