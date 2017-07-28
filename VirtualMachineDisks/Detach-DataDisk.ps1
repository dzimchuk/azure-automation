param
(
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$DiskName,
  [Parameter(Mandatory = $true)]  
  [string]$VMName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

Remove-AzureRmVMDataDisk -VM $vm -DataDiskNames $DiskName

Update-AzureRmVM -VM $vm -ResourceGroupName $ResourceGroupName
