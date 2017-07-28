$rg = Get-AzureRmResourceGroup -Name TestVMRG

$nsg = Get-AzureRmNetworkSecurityGroup -Name WebNSG -ResourceGroupName $rg.ResourceGroupName

$nic = Get-AzureRmNetworkInterface -Name WebVMNIC -ResourceGroupName $rg.ResourceGroupName

$nic.NetworkSecurityGroup = $nsg

Set-AzureRmNetworkInterface -NetworkInterface $nic