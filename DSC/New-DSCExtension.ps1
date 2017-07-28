param
(
  [Parameter(Mandatory = $true)]  
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$VMName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountName,
  [Parameter(Mandatory = $true)]  
  [string]$Location
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Create archive locally
#Publish-AzureRmVMDscConfiguration -ConfigurationPath 'f:\dev\bitbucket\azure-automation\DSC\iisInstall.ps1' -OutputArchivePath 'f:\test.zip'

#Publish the configuration script into user storage
Publish-AzureRmVMDscConfiguration -ConfigurationPath (Join-Path $PSScriptRoot '.\iisInstall.ps1') -ResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -force

#Set the VM to run the DSC configuration
Set-AzureRmVmDscExtension -Version 2.21 -ResourceGroupName $ResourceGroupName -VMName $VMName -ArchiveResourceGroupName $StorageAccountResourceGroupName -ArchiveStorageAccountName $StorageAccountName -ArchiveBlobName iisInstall.ps1.zip -AutoUpdate:$true -ConfigurationName "IISInstall"
