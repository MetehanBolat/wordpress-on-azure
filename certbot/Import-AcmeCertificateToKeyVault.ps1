param (
    [string] $AcmeDirectory,
    [string] $fqdn,
    [string] $KeyVaultResourceId
    #[string] $subscriptionId
)

function ConvertFrom-Base64Url {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Base64Url,
        [switch]$AsByteArray
    )

    Process {

        # short circuit on empty strings
        if ($Base64Url -eq [string]::Empty) {
            return [string]::Empty
        }

        # put the standard unsafe characters back
        $s = $Base64Url.Replace('-', '+').Replace('_', '/')

        # put the padding back
        switch ($s.Length % 4) {
            0 { break; }             # no padding needed
            2 { $s += '=='; break; } # two pad chars
            3 { $s += '='; break; }  # one pad char
            default { throw "Invalid Base64Url string" }
        }

        # convert it using standard base64 stuff
        if ($AsByteArray) {
            return [Convert]::FromBase64String($s)
        } else {
            return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))
        }
        
    }
    
}

#Select-AzSubscription -Subscription $subscriptionId

# For wildcard certificates, Posh-ACME replaces * with ! in the directory name
$certificateName = $fqdn.Replace('*', '!')

# Set working directory
$workingDirectory = Join-Path -Path "." -ChildPath "pa"

# Set Posh-ACME working directory
$env:POSHACME_HOME = $workingDirectory
Import-Module -Name Posh-ACME -Force  | Out-Null

# Resolve the details of the certificate
#$currentServerName = ((Get-PAServer).location) -split "/" | Where-Object -FilterScript { $_ } | Select-Object -Skip 1 -First 1
$currentAccountName = (Get-PAAccount).id

# Determine paths to resources
$orderDirectoryPath = Join-Path -Path $workingDirectory -ChildPath $AcmeDirectory | Join-Path -ChildPath $currentAccountName | Join-Path -ChildPath $certificateName
$orderDataPath = Join-Path -Path $orderDirectoryPath -ChildPath "order.json"
$pfxFilePath = Join-Path -Path $orderDirectoryPath -ChildPath "fullchain.pfx"

# If we have a order and certificate available
if ((Test-Path -Path $orderDirectoryPath) -and (Test-Path -Path $orderDataPath) -and (Test-Path -Path $pfxFilePath)) {

    # Load order data
    $orderData = Get-Content -Path $orderDataPath -Raw | ConvertFrom-Json

    # Decode PfxPassB64U (BASE64)
    $pfxPass = ConvertFrom-Base64Url $orderData.PfxPassB64U

    # Load PFX
    $certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $pfxFilePath, $pfxPass, 'EphemeralKeySet'

    # Get the current certificate from key vault (if any)
    $azureKeyVaultCertificateName = $certificateName.Replace(".", "-").Replace("!", "star")
    $keyVaultResource = Get-AzResource -ResourceId $KeyVaultResourceId
    $azureKeyVaultCertificate = Get-AzKeyVaultCertificate -VaultName $keyVaultResource.Name -Name $azureKeyVaultCertificateName -ErrorAction SilentlyContinue

    # If we have a different certificate, import it
    If (-not $azureKeyVaultCertificate -or $azureKeyVaultCertificate.Thumbprint -ne $certificate.Thumbprint) {
        Import-AzKeyVaultCertificate -VaultName $keyVaultResource.Name -Name $azureKeyVaultCertificateName -FilePath $pfxFilePath -Password (ConvertTo-SecureString -String $pfxPass -AsPlainText -Force) | Out-Null
    }
}
