<#
.SYNOPSIS
    Unified secret retrieval interface.

.DESCRIPTION
    Single interface to retrieve secrets from any configured source:
    - Stored credential files (XML)
    - Vaultwarden
    - Azure Key Vault

    Automatically detects source based on file extension or naming convention.

.PARAMETER Source
    Source type: File, Vaultwarden, AzureKeyVault

.PARAMETER Name
    Secret identifier (file name, Vaultwarden item name, or Azure Key Vault secret name)

.PARAMETER Path
    Path to credential file (for File source)

.PARAMETER ConfigPath
    Path to .env configuration file.

.EXAMPLE
    # From file
    $Cred = & ".\Get-Secret.ps1" -Source File -Name "SQLServer01-Admin" -Path "C:\Scripts\Secrets"

    # From Vaultwarden
    $Password = & ".\Get-Secret.ps1" -Source Vaultwarden -Name "Database-Password"

    # From Azure Key Vault
    $Secret = & ".\Get-Secret.ps1" -Source AzureKeyVault -Name "ApiKey"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("File", "Vaultwarden", "AzureKeyVault")]
    [string]$Source,
    
    [Parameter(Mandatory = $true)]
    [string]$Name,
    
    [string]$Path = "",
    
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot

if (-not $ConfigPath) {
    $ConfigPath = "$ScriptRoot\.env"
}

switch ($Source) {
    "File" {
        if (-not $Path) {
            $ConfigFull = "$ScriptRoot\..\Config\settings.json"
            if (Test-Path $ConfigFull) {
                $Config = Get-Content $ConfigFull -Raw | ConvertFrom-Json
                $Path = $Config.SecretsPath
            }
            if (-not $Path) {
                $Path = "C:\Scripts\Secrets"
            }
        }
        
        $FilePath = Join-Path -Path $Path -ChildPath "$Name.xml"
        
        if (-not (Test-Path $FilePath)) {
            Write-Error "Credential file not found: $FilePath"
            exit 1
        }
        
        Write-Host "Loading from file: $FilePath" -ForegroundColor Cyan
        $Credential = Import-Clixml -Path $FilePath -ErrorAction Stop
        
        Write-Host "Credential loaded: $($Credential.UserName)" -ForegroundColor Green
        return $Credential
    }
    
    "Vaultwarden" {
        Write-Host "Retrieving from Vaultwarden: $Name" -ForegroundColor Cyan
        
        $Params = @{
            Command = "GetPassword"
            SecretName = $Name
            ConfigPath = $ConfigPath
        }
        
        $Password = & "$ScriptRoot\Invoke-Vaultwarden.ps1" @Params
        
        if ($Password) {
            Write-Host "Retrieved from Vaultwarden" -ForegroundColor Green
            return $Password
        }
        else {
            Write-Error "Failed to retrieve from Vaultwarden"
            exit 1
        }
    }
    
    "AzureKeyVault" {
        Write-Host "Retrieving from Azure Key Vault: $Name" -ForegroundColor Cyan
        
        $Params = @{
            Command = "GetSecret"
            SecretName = $Name
            ConfigPath = $ConfigPath
        }
        
        $Secret = & "$ScriptRoot\Invoke-AzureKeyVault.ps1" @Params
        
        if ($Secret) {
            Write-Host "Retrieved from Azure Key Vault" -ForegroundColor Green
            return $Secret
        }
        else {
            Write-Error "Failed to retrieve from Azure Key Vault"
            exit 1
        }
    }
}
