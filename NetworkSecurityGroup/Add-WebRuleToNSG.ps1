$rg = Get-AzureRmResourceGroup -Name TestNETRG

$nsg = Get-AzureRmNetworkSecurityGroup -Name TestNSG -ResourceGroupName $rg.ResourceGroupName

$webRule = New-AzureRmNetworkSecurityRuleConfig `
  -Name webRule `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access Allow

$nsg.SecurityRules.Add($webRule)

Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg
