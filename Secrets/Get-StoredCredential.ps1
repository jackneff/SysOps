<#
.SYNOPSIS
    Retrieves a stored credential from XML file.

.DESCRIPTION
    Loads a credential file created by New-StoredCredential.ps1 and returns
    a PSCredential object for use in scripts.

    Supports both DPAPI and AES encrypted credentials.

.PARAMETER Path
    Path to the credential XML file.

.PARAMETER UseVaultwardenForKey
    Retrieve AES key from Vaultwarden (for AES encrypted credentials).

.EXAMPLE
    # Basic usage (DPAPI)
    $Cred = & ".\Secrets\Get-StoredCredential.ps1" -Path "C:\Scripts\Secrets\SQLServer01-Admin.xml"

    # Use in a script
    Invoke-Sqlcmd -ServerInstance "SQL01" -Credential $Cred -Query "SELECT @@VERSION"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [switch]$UseVaultwardenForKey
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Path)) {
    Write-Error "Credential file not found: $Path"
    exit 1
}

Write-Host "Loading credential from: $Path" -ForegroundColor Cyan

$Credential = Import-Clixml -Path $Path -ErrorAction Stop

if ($Credential) {
    Write-Host "Credential loaded successfully" -ForegroundColor Green
    Write-Host "Username: $($Credential.UserName)" -ForegroundColor Cyan
    return $Credential
}
else {
    Write-Error "Failed to load credential"
    exit 1
}
