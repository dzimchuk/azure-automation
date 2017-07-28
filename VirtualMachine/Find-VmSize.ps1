# Find available VM sizes in a region
#Get-AzureRmVMSize -Location 'west europe'

# Find available VM sizes for a machine
# When resizing if the size if available then the machine size can be changed without deprovisioning
Get-AzureRmVMSize -ResourceGroupName TestVMRG -VMName Web1VM

# Find available VM sizes in availability set
Get-AzureRmVMSize `
   -AvailabilitySetName FrontEndAvailabilitySet `
   -ResourceGroupName TestVMRG
