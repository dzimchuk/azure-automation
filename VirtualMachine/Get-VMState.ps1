Get-AzureRmVM `
    -ResourceGroupName TestVMRG./ `
    -Name myVM `
    -Status | Select @{n="Status"; e={$_.Statuses[1].Code}}

#Stop-AzureRmVM -ResourceGroupName TestVMRG -Name "myVM" -Force
#Stop-AzureRmVM -ResourceGroupName TestVMRG -Name "myVM" -Force -StayProvisioned

#Start-AzureRmVM -ResourceGroupName TestVMRG -Name myVM