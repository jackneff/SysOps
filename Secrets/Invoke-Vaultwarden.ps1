<#
.SYNOPSIS
    Wrapper for Vaultwarden/Bitwarden CLI operations.

.DESCRIPTION
    Provides PowerShell functions to interact with Vaultwarden for
    storing and retrieving secrets programmatically.

    SECURITY: Uses API key authentication which is designed for automation.
    Master password is NOT required when using API key.

.PARAMETER Command
    Operation to perform: GetPassword, GetField, List, Login, Logout, Lock, Unlock, Sync

.PARAMETER SecretName
    Name of the secret to retrieve.

.PARAMETER FieldName
    Custom field name (for GetField command).

.PARAMETER ConfigPath
    Path to .env configuration file.

.EXAMPLE
    # Get a password
    $Password = & ".\Invoke-Vaultwarden.ps1" -Command GetPassword -SecretName "Database-Password"

    # Get a custom field
    $ApiKey = & ".\Invoke-Vaultwarden.ps1" -Command GetField -SecretName "AWS-Credentials" -FieldName "AccessKey"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("GetPassword", "GetField", "List", "Login", "Logout", "Lock", "Unlock", "Sync", "Test")]
    [string]$Command,
    
    [string]$SecretName = "",
    
    [string]$FieldName = "",
    
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

function Test-BwInstalled {
    $BwCommand = Get-Command bw -ErrorAction SilentlyContinue
    if (-not $BwCommand) {
        Write-Error "bw CLI not found. Install from: https://github.com/bitwarden/clients/releases"
        exit 1
    }
    return $BwCommand
}

function Connect-Vaultwarden {
    if ($env:VAULTWARDEN_URL) {
        bw config server $env:VAULTWARDEN_URL 2>&1 | Out-Null
    }
    
    $Check = bw login --check 2>&1
    
    if ($Check -match "You are not logged in") {
        if ($env:VAULTWARDEN_CLIENT_ID -and $env:VAULTWARDEN_CLIENT_SECRET) {
            $env:BW_CLIENTID = $env:VAULTWARDEN_CLIENT_ID
            $env:BW_CLIENTSECRET = $env:VAULTWARDEN_CLIENT_SECRET
            bw login --apikey 2>&1 | Out-Null
            Write-Host "Logged into Vaultwarden via API key" -ForegroundColor Green
        }
        else {
            Write-Error "Not logged in and API credentials not configured in .env"
            Write-Host "Run 'bw login --apikey' or configure .env file" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "Already logged into Vaultwarden" -ForegroundColor Green
    }
    
    $Unlocked = bw lock --check 2>&1
    if ($Unlocked -match "Vault is locked") {
        Write-Host "Vault is locked - attempting unlock" -ForegroundColor Yellow
        if ($env:BW_MASTER_PASSWORD) {
            $env:BW_MASTER_PASSWORD = $env:BW_MASTER_PASSWORD
            bw unlock --passwordenv BW_MASTER_PASSWORD --raw 2>&1 | Out-Null
        }
        else {
            Write-Warning "Master password needed. Set BW_MASTER_PASSWORD in .env or run interactively"
        }
    }
}

function Get-VaultwardenSecret {
    param(
        [string]$Name,
        [string]$Field
    )
    
    Connect-Vaultwarden
    
    $Session = bw unlock --check 2>&1
    if ($Session -match "Vault is locked") {
        Write-Error "Vault is locked. Unlock first with master password."
        return $null
    }
    
    if ($Field) {
        $Result = bw get item $Name --session $env:BW_SESSION 2>&1
    }
    else {
        $Result = bw get password $Name --raw 2>&1
    }
    
    if ($LASTEXITCODE -eq 0) {
        if ($Field) {
            $Item = $Result | ConvertFrom-Json
            $FieldValue = ($Item.login.fields | Where-Object { $_.name -eq $Field }).value
            return $FieldValue
        }
        return $Result
    }
    else {
        Write-Error "Secret not found: $Name"
        return $null
    }
}

function Get-VaultwardenList {
    Connect-Vaultwarden
    
    $Result = bw list items 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $Items = $Result | ConvertFrom-Json
        return $Items | Select-Object name, id, @{N="Type";E={$_.type}}
    }
    return @()
}

Test-BwInstalled

switch ($Command) {
    "Test" {
        Connect-Vaultwarden
        Write-Host "Vaultwarden connection: OK" -ForegroundColor Green
    }
    
    "Login" {
        Connect-Vaultwarden
    }
    
    "Logout" {
        bw logout 2>&1 | Out-Null
        Write-Host "Logged out of Vaultwarden" -ForegroundColor Green
    }
    
    "Lock" {
        bw lock 2>&1 | Out-Null
        Write-Host "Vault locked" -ForegroundColor Green
    }
    
    "Unlock" {
        Connect-Vaultwarden
    }
    
    "Sync" {
        Connect-Vaultwarden
        bw sync 2>&1 | Out-Null
        Write-Host "Sync complete" -ForegroundColor Green
    }
    
    "GetPassword" {
        if (-not $SecretName) {
            Write-Error "SecretName is required for GetPassword"
            exit 1
        }
        return Get-VaultwardenSecret -Name $SecretName
    }
    
    "GetField" {
        if (-not $SecretName -or -not $FieldName) {
            Write-Error "SecretName and FieldName are required for GetField"
            exit 1
        }
        return Get-VaultwardenSecret -Name $SecretName -Field $FieldName
    }
    
    "List" {
        return Get-VaultwardenList
    }
}
