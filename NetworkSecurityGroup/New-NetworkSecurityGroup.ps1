$rg = Get-AzureRmResourceGroup -Name TestNETRG

$rdpRule = New-AzureRmNetworkSecurityRuleConfig `
  -Name rdpRule `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 1002 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389 `
  -Access Allow

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

$nsg = New-AzureRmNetworkSecurityGroup `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location 'west europe' `
    -Name TestNSG `
    -SecurityRules $rdpRule,$webRule