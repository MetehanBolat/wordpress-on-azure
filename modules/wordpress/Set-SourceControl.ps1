Param (
    [Parameter(Mandatory = $true)]
    [String]$webAppName,
    [string]$appResourceGroupName,
    [string]$repoUrl,
    [string]$scmBranch
)
## Script defaults
$apiVersion = "2022-03-01"
$resourceType = "Microsoft.Web/sites"

#Script uses Azure CLI Login credentials to forward access_token to Powershell

$subscriptions = (az account list -o json 2> $null | ConvertFrom-Json)
$subscriptionId= $subscriptions | Where-Object isDefault -like true
$accountId = $subscriptionId.user.name
$tenantId = $subscriptionId.tenantId
$adTokenRegistry = (az account get-access-token | ConvertFrom-Json)
$accessToken = $adtokenregistry.accessToken

Login-AzAccount -AccessToken $accessToken -tenantid $tenantId -accountid $accountId

Write-Host "Getting App information"
$webApp = Get-AzResource -ResourceName $webAppName -ResourceType "$resourceType" -ApiVersion $apiVersion -ResourceGroupName $appResourceGroupName

$webAppConfig = Get-AzResource `
  -ResourceType      "$resourceType/config" `
  -ApiVersion        $apiVersion `
  -ResourceName      "$($webAppName)/web" `
  -ResourceGroupName $appResourceGroupName
$currentScmType = $webAppConfig.Properties.scmType

if($null -ne $currentScmType -and $currentScmType -ne "None")
{
  Write-Host "Already setup with scmType $currentScmType"
	# App is already configured with source control,  we cannot add again.
	return
}

$propertiesObject = @{
  repourl             = "$repoUrl"
  branch              = "$scmBranch"
  isManualIntegration = "true" 
}
 
New-AzResource `
  -ResourceType      "$resourceType/SourceControls" `
  -ApiVersion        $apiVersion `
  -ResourceName      "$webAppName/web" `
  -ResourceGroupName $appResourceGroupName `
  -Properties        $propertiesObject -Force -ErrorAction SilentlyContinue