# Sign in to Azure.
Login-AzureRmAccount

# If you have multiple subscriptions, uncomment and set to the subscription you want to work with:
# $subscriptionId = "xxx"
# Set-AzureRmContext -SubscriptionId $subscriptionId

# Provide these values for your new Azure AD app:
# $appName (display name for your app, must be unique in your directory)
# $uri (it cannot be real)
# $secret (password for your app)
$appName = "yourapp"
$uri = "http://yourapp"
$secret = ConvertTo-SecureString "YourPassword" -AsPlainText -Force

# Create the Azure AD app
$azureAdApplication = New-AzureRmADApplication -DisplayName $appName -HomePage $Uri -IdentifierUris $Uri -Password $secret

# Create a Service Principal for the app
$svcprincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId

# Assign the Contributor RBAC role to the service principal
$roleassignment = New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $azureAdApplication.ApplicationId.Guid

# Display the values for your application
Write-Output "Save these values for using them in your application"
Write-Output "Subscription ID:" (Get-AzureRmContext).Subscription.SubscriptionId
Write-Output "Tenant ID:" (Get-AzureRmContext).Tenant.TenantId
Write-Output "Application ID:" $azureAdApplication.ApplicationId.Guid
Write-Output "Application Secret:" $secret