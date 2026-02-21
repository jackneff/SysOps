<#
.SYNOPSIS
    Retrieves secrets from Azure Key Vault.

.DESCRIPTION
    Provides PowerShell functions to interact with Azure Key Vault.
    Supports multiple authentication methods including Managed Identity,
    Service Principal, and interactive login.

    SECURITY: Best practice is to use Managed Identity on Azure VMs.
    This avoids storing any credentials for Azure access.

.PARAMETER Command
    Operation: GetSecret, GetKey, GetCertificate, Connect, List

.PARAMETER VaultName
    Name of the Azure Key Vault.

.PARAMETER SecretName
    Name of the secret to retrieve.

.PARAMETER KeyName
    Name of the key to retrieve.

.PARAMETER CertificateName
    Name of the certificate to retrieve.

.PARAMETER AuthenticationMethod
    "ManagedIdentity" (default for Azure VMs), "ServicePrincipal", "Interactive"

.PARAMETER ConfigPath
    Path to .env configuration file.

.EXAMPLE
    # Connect using Managed Identity (Azure VM)
    $Secret = & ".\Invoke-AzureKeyVault.ps1" -Command GetSecret -VaultName "ProductionVault" -SecretName "DatabasePassword"

    # Connect using Service Principal
    $Secret = & ".\Invoke-AzureKeyVault.ps1" -Command GetSecret -VaultName "ProductionVault" -SecretName "ApiKey" -AuthenticationMethod ServicePrincipal
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("GetSecret", "GetKey", "GetCertificate", "Connect", "List", "Test")]
    [string]$Command,
    
    [string]$VaultName = "",
    
    [string]$SecretName = "",
    
    [string]$KeyName = "",
    
    [string]$CertificateName = "",
    
    [ValidateSet("ManagedIdentity", "ServicePrincipal", "Interactive")]
    [string]$AuthenticationMethod = "ManagedIdentity",
    
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot

if (-not $ConfigPath) {
    $ConfigPath = "$ScriptRoot\.env"
}

$EnvLoaded = $false
if (Test-Path $ConfigPath) {
    . $ConfigPath
    $EnvLoaded = $true
}

if ($VaultName -and -not $env:AZURE_KEYVAULT_NAME) {
    $env:AZURE_KEYVAULT_NAME = $VaultName
}

function Test-AzModule {
    $AzCommand = Get-Module -ListAvailable -Name Az.KeyVault | Select-Object -First 1
    if (-not $AzCommand) {
        Write-Host "Installing Az.KeyVault module..." -ForegroundColor Yellow
        Install-Module Az.KeyVault -Force -AllowClobber
    }
    Import-Module Az.KeyVault -ErrorAction Stop
}

function Connect-AzureKeyVault {
    param(
        [string]$Method
    )
    
    Test-AzModule
    
    try {
        switch ($Method) {
            "ManagedIdentity" {
                $Identity = Get-AzAccessToken -ResourceUrl "https://vault.azure.net" -ErrorAction SilentlyContinue
                if ($Identity) {
                    Write-Host "Connected using Managed Identity" -ForegroundColor Green
                    return $true
                }
                
                Write-Host "Managed Identity not available (not running on Azure VM?)" -ForegroundColor Yellow
                Write-Host "Falling back to Service Principal..." -ForegroundColor Yellow
                $Method = "ServicePrincipal"
            }
            
            "ServicePrincipal" {
                if ($env:AZURE_TENANT_ID -and $env:AZURE_APPLICATION_ID) {
                    $CredPath = "$ScriptRoot\..\Secrets\sp-credential.xml"
                    
                    if (Test-Path $CredPath) {
                        $Cred = Import-Clixml -Path $CredPath
                        Connect-AzAccount -ServicePrincipal -Tenant $env:AZURE_TENANT_ID -ApplicationId $env:AZURE_APPLICATION_ID -Credential $Cred -ErrorAction Stop | Out-Null
                        Write-Host "Connected using Service Principal" -ForegroundColor Green
                        return $true
                    }
                    else {
                        Write-Warning "Service Principal credential file not found: $CredPath"
                        Write-Host "Using interactive login..." -ForegroundColor Yellow
                        $Method = "Interactive"
                    }
                }
                else {
                    Write-Warning "Service Principal credentials not configured in .env"
                    $Method = "Interactive"
                }
            }
            
            "Interactive" {
                Connect-AzAccount -ErrorAction Stop | Out-Null
                Write-Host "Connected using interactive login" -ForegroundColor Green
                return $true
            }
        }
    }
    catch {
        Write-Error "Failed to connect to Azure: $($_.Exception.Message)"
        return $false
    }
}

function Get-AzureKeyVaultSecret {
    param(
        [string]$Vault,
        [string]$Name
    )
    
    if (-not $Vault) {
        $Vault = $env:AZURE_KEYVAULT_NAME
    }
    
    if (-not $Vault) {
        Write-Error "VaultName is required"
        return $null
    }
    
    $Connected = Connect-AzureKeyVault -Method $AuthenticationMethod
    
    try {
        $Secret = Get-AzKeyVaultSecret -VaultName $Vault -Name $Name -ErrorAction Stop
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secret.SecretValue)
        $PlainValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        
        return $PlainValue
    }
    catch {
        Write-Error "Failed to get secret '$Name' from vault '$Vault': $($_.Exception.Message)"
        return $null
    }
}

function Get-AzureKeyVaultCertificate {
    param(
        [string]$Vault,
        [string]$Name
    )
    
    if (-not $Vault) {
        $Vault = $env:AZURE_KEYVAULT_NAME
    }
    
    $Connected = Connect-AzureKeyVault -Method $AuthenticationMethod
    
    try {
        $Cert = Get-AzKeyVaultCertificate -VaultName $Vault -Name $Name -ErrorAction Stop
        return $Cert
    }
    catch {
        Write-Error "Failed to get certificate '$Name' from vault '$Vault': $($_.Exception.Message)"
        return $null
    }
}

function Get-AzureKeyVaultList {
    param(
        [string]$Vault
    )
    
    if (-not $Vault) {
        $Vault = $env:AZURE_KEYVAULT_NAME
    }
    
    $Connected = Connect-AzureKeyVault -Method $AuthenticationMethod
    
    try {
        $Secrets = Get-AzKeyVaultSecret -VaultName $Vault
        return $Secrets | Select-Object Name, Id, Enabled, Expires, Updated
    }
    catch {
        Write-Error "Failed to list secrets: $($_.Exception.Message)"
        return @()
    }
}

switch ($Command) {
    "Test" {
        $Connected = Connect-AzureKeyVault -Method $AuthenticationMethod
        if ($Connected) {
            Write-Host "Azure Key Vault connection: OK" -ForegroundColor Green
        }
    }
    
    "Connect" {
        Connect-AzureKeyVault -Method $AuthenticationMethod
    }
    
    "GetSecret" {
        if (-not $SecretName) {
            Write-Error "SecretName is required for GetSecret"
            exit 1
        }
        return Get-AzureKeyVaultSecret -Vault $VaultName -Name $SecretName
    }
    
    "GetCertificate" {
        if (-not $CertificateName) {
            Write-Error "CertificateName is required for GetCertificate"
            exit 1
        }
        return Get-AzureKeyVaultCertificate -Vault $VaultName -Name $CertificateName
    }
    
    "List" {
        return Get-AzureKeyVaultList -Vault $VaultName
    }
}
