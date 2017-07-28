#Get-AzureRmVMImagePublisher -Location 'west europe'
#Get-AzureRmVMImageOffer -Location 'west europe' -PublisherName 'MicrosoftWindowsServer'
Get-AzureRmVMImageSku -Location 'west europe' -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer'
