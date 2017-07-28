# if new size is unavailable then VM needs to be deprovisioned first
#Stop-AzureRmVM -ResourceGroupName TestVMRG -Name "myVM" -Force

$vm = Get-AzureRmVM -ResourceGroupName TestVMRG  -VMName myVM
$vm.HardwareProfile.VmSize = "Standard_D2"
Update-AzureRmVM -VM $vm -ResourceGroupName TestVMRG 

#Start-AzureRmVM -ResourceGroupName TestVMRG  -Name $vm.name