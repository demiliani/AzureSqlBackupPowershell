# Sign in to Azure.
Login-AzureRmAccount

# Fill in your subscription and SQL Database details
$resourceGroup = "YourAzureSqlDatabaseResourceGroup"
$server = "YourAzureSqlServerName"
$database = "YourAzureSqlDatabaseName"
$sqlAdminLogin = "AdminUsername"
$sqlPassword = "AdminPassword"

# Custom Filename for the BACPAC
$bacpacFilename = $database + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".bacpac"
#Storage account (container) URI
$baseStorageUri = "https://StorageAccountName.blob.core.windows.net/BlobContainerName/"
# URI for the final bacpac file
$storageUri = $baseStorageUri + $bacpacFilename
# Blob storage access key
$storageKey= "YourStorageAccessKey"


# Tenant ID from the account that created your AAD app:
$tenantId = "YourTenantID"
# This is the Application ID from your AAD app:
$applicationId = "YourApplicationID"
# This is the Secret from your AAD app:
$key = ConvertTo-SecureString "YourAzureADAppPassword" -AsPlainText -Force

# Acquire the authentication context
$authUrl = "https://login.windows.net/${tenantId}"
$authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authUrl
$cred = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential $applicationId,$key
$authresult = $authContext.AcquireToken("https://management.core.windows.net/",$cred)

# Setting the request header with authentication and content type
$authHeader = @{
'Content-Type'='application/json'
'Authorization'=$authresult.CreateAuthorizationHeader()
}
# Creation of the request body with storage details and database login
$body = @{storageKeyType = 'StorageAccessKey'; `
storageKey=$storageKey; `
storageUri=$storageUri;`
administratorLogin=$sqlAdminLogin; `
administratorLoginPassword=$sqlPassword;`
authenticationType='SQL'`
} | ConvertTo-Json

# REST URI to call
$apiURI = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Sql/servers/$server/databases/$database/export?api-version=2014-04-01"

# POST request to the REST API
$result = Invoke-RestMethod -Uri $apiURI -Method POST -Headers $authHeader -Body $body

Write-Output $result