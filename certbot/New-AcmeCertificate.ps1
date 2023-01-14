param (
    [string] $AcmeDirectory,
    [string] $AcmeContact,
    [string] $fqdn,
    [string] $StorageContainerSASToken
    #[string] $subscriptionId
)

# Supress progress messages. Azure DevOps doesn't format them correctly (used by New-PACertificate)
$global:ProgressPreference = 'SilentlyContinue'

#Select-AzSubscription -Subscription $subscriptionId

# Create working directory
$workingDirectory = Join-Path -Path "." -ChildPath "pa"
if (-not (Test-Path $workingDirectory)) {
    New-Item -Path $workingDirectory -ItemType Directory | Out-Null
}

# Sync contents of storage container to working directory
azcopy sync "$StorageContainerSASToken" "$workingDirectory" --recursive=true

# Set Posh-ACME working directory
$env:POSHACME_HOME = $workingDirectory

try { Get-InstalledModule Posh-ACME -ErrorAction Stop }
catch { Install-Module Posh-ACME -AllowClobber -Force -Verbose }

Import-Module Posh-ACME -Force  | Out-Null

# Configure Posh-ACME server
Set-PAServer -DirectoryUrl $AcmeDirectory  | Out-Null

# Configure Posh-ACME account
$account = Get-PAAccount
if (-not $account) {
    # New account
    $account = New-PAAccount -Contact $AcmeContact -AcceptTOS
}
elseif ($account.contact -ne "mailto:$AcmeContact") {
    # Update account contact
    Set-PAAccount -ID $account.id -Contact $AcmeContact  | Out-Null
}

# Acquire access token for Azure (as we want to leverage the existing connection)
$azureContext = Get-AzContext
$currentAzureProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
$currentAzureProfileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($currentAzureProfile);
$azureAccessToken = $currentAzureProfileClient.AcquireAccessToken($azureContext.Tenant.Id).AccessToken;

# Request certificate
$paPluginArgs = @{
    AZSubscriptionId = $azureContext.Subscription.Id
    AZAccessToken    = $azureAccessToken;
}

New-PACertificate -Domain $fqdn -DnsPlugin Azure -PluginArgs $paPluginArgs -AlwaysNewKey

# Sync working directory back to storage container
azcopy sync "$workingDirectory" "$StorageContainerSASToken" --recursive=true