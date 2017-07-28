param
(
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$DiskName,
  [Parameter(Mandatory = $true)]  
  [string]$Location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$diskConfig = New-AzureRmDiskConfig -Location $Location -DiskSizeGB 128 -CreateOption Empty -AccountType StandardLRS
#$diskConfig = New-AzureRmDiskConfig -Location $Location -DiskSizeGB 128 -CreateOption Empty -AccountType PremiumLRS

$dataDisk = New-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Disk $diskConfig
