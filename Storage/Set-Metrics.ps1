$SubscriptionName = 'Your subscription name'
$StorageAccountName = 'yourstorageaccount'
Set-AzureSubscription -CurrentStorageAccountName $StorageAccountName -SubscriptionName $SubscriptionName

# Enable storage logging for the Blob service:
Set-AzureStorageServiceLoggingProperty -ServiceType Blob -LoggingOperations Read,Write,Delete -PassThru -RetentionDays 7 -Version 1.0

# Enable storage metrics for the Blob service, making sure to set -MetricsType to Minute (hourly metrics can also be set in Portal):
Set-AzureStorageServiceMetricsProperty -ServiceType Blob -MetricsType Minute -MetricsLevel ServiceAndApi -PassThru -RetentionDays 7 -Version 1.0
