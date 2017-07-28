param
(
  [Parameter(Mandatory = $true)]  
  [string]$rg,
  [Parameter(Mandatory = $true)]  
  [string]$vmName,
  [Parameter(Mandatory = $true)]  
  [string]$newAvailSetName,
  [Parameter(Mandatory = $true)]  
  [string]$outFile
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


#Get VM Details
$OriginalVM = get-azurermvm -ResourceGroupName $rg -Name $vmName

#Output VM details to file
"VM Name: " | Out-File -FilePath $outFile 
$OriginalVM.Name | Out-File -FilePath $outFile -Append

"Extensions: " | Out-File -FilePath $outFile -Append
$OriginalVM.Extensions | Out-File -FilePath $outFile -Append

"VMSize: " | Out-File -FilePath $outFile -Append
$OriginalVM.HardwareProfile.VmSize | Out-File -FilePath $outFile -Append

"NIC: " | Out-File -FilePath $outFile -Append
$OriginalVM.NetworkProfile.NetworkInterfaces[0].Id | Out-File -FilePath $outFile -Append

"OSType: " | Out-File -FilePath $outFile -Append
$OriginalVM.StorageProfile.OsDisk.OsType | Out-File -FilePath $outFile -Append

"OS Disk: " | Out-File -FilePath $outFile -Append
$OriginalVM.StorageProfile.OsDisk.Vhd.Uri | Out-File -FilePath $outFile -Append

if ($OriginalVM.StorageProfile.DataDisks) {
"Data Disk(s): " | Out-File -FilePath $outFile -Append
$OriginalVM.StorageProfile.DataDisks | Out-File -FilePath $outFile -Append
}

#Remove the original VM
Remove-AzureRmVM -ResourceGroupName $rg -Name $vmName

#Create new availability set if it does not exist
$availSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $newAvailSetName -ErrorAction Ignore
if (-Not $availSet) {
$availset = New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $newAvailSetName -Location $OriginalVM.Location
}

#Create the basic configuration for the replacement VM
$newVM = New-AzureRmVMConfig -VMName $OriginalVM.Name -VMSize $OriginalVM.HardwareProfile.VmSize -AvailabilitySetId $availSet.Id
Set-AzureRmVMOSDisk -VM $newVM -VhdUri $OriginalVM.StorageProfile.OsDisk.Vhd.Uri  -Name $OriginalVM.Name -CreateOption Attach -Windows

#Add Data Disks
foreach ($disk in $OriginalVM.StorageProfile.DataDisks ) { 
Add-AzureRmVMDataDisk -VM $newVM -Name $disk.Name -VhdUri $disk.Vhd.Uri -Caching $disk.Caching -Lun $disk.Lun -CreateOption Attach -DiskSizeInGB $disk.DiskSizeGB
}

#Add NIC(s)
foreach ($nic in $OriginalVM.NetworkInterfaceIDs) {
    Add-AzureRmVMNetworkInterface -VM $newVM -Id $nic
}

#Create the VM
New-AzureRmVM -ResourceGroupName $rg -Location $OriginalVM.Location -VM $NewVM -DisableBginfoExtension

#NOTE, fails with:
# ErrorMessage: Required parameter 'networkProfile' is missing (null).
