<#
.SYNOPSIS
    Retrieves credentials from Windows Credential Manager.

.DESCRIPTION
    Uses the CredentialManager module to store and retrieve credentials
    from Windows Credential Manager (used by Windows for stored passwords).

    SECURITY: Uses DPAPI - credentials are encrypted by Windows and tied
    to the user account.

.PARAMETER TargetName
    The target name of the credential to retrieve.

.PARAMETER StoreCredential
    Store a new credential in Windows Credential Manager.

.PARAMETER CredentialUsername
    Username for new credential (used with -StoreCredential).

.PARAMETER CredentialPassword
    Password for new credential (used with -StoreCredential).

.EXAMPLE
    # Retrieve a credential
    $Cred = & ".\Get-WindowsCredential.ps1" -TargetName "MyApplication"

    # Store a new credential
    .\Get-WindowsCredential.ps1 -TargetName "SQLServer01" -StoreCredential -CredentialUsername "admin" -CredentialPassword "P@ssw0rd"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetName,
    
    [switch]$StoreCredential,
    
    [string]$CredentialUsername = "",
    
    [string]$CredentialPassword = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    Write-Host "Installing CredentialManager module..." -ForegroundColor Yellow
    Install-Module CredentialManager -Force -AllowClobber
}

Import-Module CredentialManager

if ($StoreCredential) {
    if (-not $CredentialUsername -or -not $CredentialPassword) {
        Write-Host "Enter credentials to store:" -ForegroundColor Cyan
        $Credential = Get-Credential -Message "Enter credentials to store in Windows Credential Manager"
        $CredentialUsername = $Credential.UserName
        $CredentialPassword = $Credential.GetNetworkCredential().Password
    }
    
    $SecurePassword = ConvertTo-SecureString -String $CredentialPassword -AsPlainText -Force
    $Credential = New-Object PSCredential($CredentialUsername, $SecurePassword)
    
    New-StoredCredential -Target $TargetName -Credential $Credential -Type Generic -Persist LocalMachine -ErrorAction Stop
    
    Write-Host "Credential stored in Windows Credential Manager: $TargetName" -ForegroundColor Green
    return
}

try {
    $StoredCred = Get-StoredCredential -Target $TargetName -ErrorAction Stop
    
    Write-Host "Credential retrieved: $TargetName" -ForegroundColor Green
    return $StoredCred
}
catch {
    Write-Error "Credential not found: $TargetName"
    Write-Host ""
    Write-Host "To store a credential, run with -StoreCredential flag" -ForegroundColor Yellow
    exit 1
}
