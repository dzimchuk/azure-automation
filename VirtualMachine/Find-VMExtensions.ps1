Get-AzureRmVmImagePublisher -Location 'west europe' | `
Get-AzureRmVMExtensionImageType | `
Get-AzureRmVMExtensionImage | Select Type, Version