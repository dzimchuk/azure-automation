param
(
  [Parameter(Mandatory = $true)]  
  [string]$keyVaultResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$keyVaultName,
  [Parameter(Mandatory = $true)]  
  [string]$resourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$vmName,
  [Parameter(Mandatory = $true)]  
  [string]$adIdentifierUri,
  [Parameter(Mandatory = $true)]  
  [string]$securePassword,
  [Parameter(Mandatory = $true)]  
  [string]$SubnetName,
  [Parameter(Mandatory = $true)]  
  [string]$Location,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountResourceGroupName,
  [Parameter(Mandatory = $true)]  
  [string]$StorageAccountName
)

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

$app = Get-AzureRmADApplication -IdentifierUri $adIdentifierUri


# Define required information for our Key Vault and keys
$keyVault = Get-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $keyVaultResourceGroupName;
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri;
$keyVaultResourceId = $keyVault.ResourceId;
$keyEncryptionKeyUrl = (Get-AzureKeyVaultKey -VaultName $keyVaultName -Name "vmEncryptionKey").Key.kid;

# Encrypt our virtual machine
Set-AzureRmVMDiskEncryptionExtension `
    -ResourceGroupName $resourceGroupName `
    -VMName $vmName `
    -AadClientID $app.ApplicationId `
    -AadClientSecret $securePassword `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $keyVaultResourceId `
    -KeyEncryptionKeyUrl $keyEncryptionKeyUrl `
    -KeyEncryptionKeyVaultId $keyVaultResourceId

# View encryption status
Get-AzureRmVmDiskEncryptionStatus -ResourceGroupName $resourceGroupName -VMName $vmName
