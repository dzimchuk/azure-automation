$rg = Get-AzureRmResourceGroup -Name TestVMRG

Set-AzureRmVMExtension -ResourceGroupName $rg.ResourceGroupName `
    -ExtensionName IIS `
    -VMName myVM `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
    -Location 'west europe'

#Set-AzureRmVMCustomScriptExtension -ResourceGroupName myResourceGroup `
#    -VMName myVM `
#    -Location 'west europe' `
#    -FileUri myURL `
#    -Run 'myScript.ps1' `
#    -Name DemoScriptExtension