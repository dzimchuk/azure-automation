$disks = Get-Disk | Where partitionstyle -eq 'raw' 
# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

if($disks -ne $null)
{
    # Create a new storage pool using all available disks 
    New-StoragePool –FriendlyName "VMStoragePool" `
        –StorageSubsystemFriendlyName "Storage Spaces*" `
        –PhysicalDisks (Get-PhysicalDisk –CanPool $True)

    # Return all disks in the new pool
    $disks = Get-StoragePool –FriendlyName "VMStoragePool" `
	        -IsPrimordial $false | 
	        Get-PhysicalDisk

    # Create a new virtual disk 
    New-VirtualDisk –FriendlyName "DataDisk" `
                -ResiliencySettingName Simple `
		        –NumberOfColumns $disks.Count `
		        –UseMaximumSize –Interleave 256KB `
		        -StoragePoolFriendlyName "VMStoragePool" 

    # Format the disk using NTFS and mount it as the F: drive
    Get-Disk | 
    Where partitionstyle -eq 'raw' |
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -DriveLetter "F" -UseMaximumSize |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk" -Confirm:$false
}