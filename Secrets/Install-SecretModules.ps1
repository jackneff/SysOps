<#
.SYNOPSIS
    Installs required modules and tools for secrets management.

.DESCRIPTION
    Installs PowerShell modules and CLI tools needed for secure credential management.
    Includes: CredentialManager, SecretManagement, SecretStore, and bw CLI.

.EXAMPLE
    .\Install-SecretModules.ps1
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "=== Installing Secrets Management Prerequisites ===" -ForegroundColor Cyan
Write-Host ""

$ModulesToInstall = @(
    @{ Name = "CredentialManager"; Source = "PSGallery"; Description = "Windows Credential Manager integration" }
    @{ Name = "Microsoft.PowerShell.SecretManagement"; Source = "PSGallery"; Description = "Secret management framework" }
    @{ Name = "Microsoft.PowerShell.SecretStore"; Source = "PSGallery"; Description = "Local secret vault" }
)

Write-Host "Installing PowerShell Modules..." -ForegroundColor Yellow
Write-Host ""

foreach ($Module in $ModulesToInstall) {
    Write-Host "  Checking: $($Module.Name)..." -ForegroundColor Cyan
    
    $Existing = Get-Module -ListAvailable -Name $Module.Name -ErrorAction SilentlyContinue
    
    if ($Existing -and -not $Force) {
        Write-Host "    Already installed (version $($Existing[0].Version))" -ForegroundColor Green
    }
    else {
        try {
            Install-Module -Name $Module.Name -Source $Module.Source -Force:$Force -AllowClobber -ErrorAction Stop
            Write-Host "    Installed successfully" -ForegroundColor Green
        }
        catch {
            Write-Warning "    Failed to install: $($_.Exception.Message)"
        }
    }
}

Write-Host ""
Write-Host "Checking for bw CLI (Vaultwarden/Bitwarden)..." -ForegroundColor Yellow

$BwPath = Get-Command bw -ErrorAction SilentlyContinue

if ($BwPath) {
    Write-Host "  bw CLI found: $($BwPath.Source)" -ForegroundColor Green
    $BwVersion = bw --version 2>&1
    Write-Host "  Version: $BwVersion" -ForegroundColor Cyan
}
else {
    Write-Host "  bw CLI not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install bw CLI, run one of the following:" -ForegroundColor Cyan
    Write-Host "  Option 1: winget install Bitwarden.CLI" -ForegroundColor White
    Write-Host "  Option 2: Download from https://github.com/bitwarden/clients/releases" -ForegroundColor White
    Write-Host ""
    Write-Host "After installation, configure Vaultwarden URL:" -ForegroundColor Yellow
    Write-Host "  bw config server https://vault.yourcompany.com" -ForegroundColor White
}

Write-Host ""
Write-Host "Checking for Azure CLI..." -ForegroundColor Yellow

$AzPath = Get-Command az -ErrorAction SilentlyContinue

if ($AzPath) {
    Write-Host "  Azure CLI found: $($AzPath.Source)" -ForegroundColor Green
    $AzVersion = az --version 2>&1 | Select-Object -First 1
    Write-Host "  Version: $AzVersion" -ForegroundColor Cyan
}
else {
    Write-Host "  Azure CLI not found (optional for Azure Key Vault)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Copy .env.example to .env and configure" -ForegroundColor White
Write-Host "  2. Run 'bw login --apikey' to authenticate Vaultwarden" -ForegroundColor White
Write-Host "  3. Use New-StoredCredential.ps1 to create credentials" -ForegroundColor White
