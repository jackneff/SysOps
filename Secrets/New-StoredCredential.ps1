<#
.SYNOPSIS
    Creates a stored credential XML file for secure password management.

.DESCRIPTION
    Creates an encrypted credential file that can be used in PowerShell scripts
    without hardcoding passwords. Supports DPAPI (Windows encryption) and AES
    (cross-machine) encryption methods.

    SECURITY: 
    - DPAPI: Tied to user account and machine - NOT portable
    - AES: Uses encryption key stored in Vaultwarden for portability

.PARAMETER TargetName
    Name for the credential (e.g., "SQLServer01-Admin")

.PARAMETER OutputPath
    Directory to save credential file.

.PARAMETER EncryptionMethod
    "DPAPI" (default) or "AES"

.PARAMETER Username
    Username (optional - will prompt if not provided)

.PARAMETER UseVaultwardenForKey
    Store/retrieve AES key from Vaultwarden.

.PARAMETER ConfigPath
    Path to .env config file.

.EXAMPLE
    # DPAPI encryption (same user/machine)
    .\New-StoredCredential.ps1 -TargetName "SQLServer01-Admin" -OutputPath "C:\Scripts\Secrets"

    # AES encryption with Vaultwarden key storage
    .\New-StoredCredential.ps1 -TargetName "SQLServer01-Admin" -OutputPath "C:\Scripts\Secrets" -EncryptionMethod AES -UseVaultwardenForKey
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetName,
    
    [string]$OutputPath = "",
    
    [ValidateSet("DPAPI", "AES")]
    [string]$EncryptionMethod = "DPAPI",
    
    [string]$Username = "",
    
    [switch]$UseVaultwardenForKey,
    
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot

if (-not $OutputPath) {
    if (Test-Path "$ScriptRoot\..\Config\settings.json") {
        $Config = Get-Content "$ScriptRoot\..\Config\settings.json" -Raw | ConvertFrom-Json
        $OutputPath = $Config.SecretsPath
    }
    if (-not $OutputPath) {
        $OutputPath = "C:\Scripts\Secrets"
    }
}

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "Created secrets directory: $OutputPath" -ForegroundColor Yellow
}

if (-not $Username) {
    Write-Host ""
    Write-Host "Enter credentials for: $TargetName" -ForegroundColor Cyan
    $Credential = Get-Credential -Message "Enter username and password"
}
else {
    Write-Host ""
    Write-Host "Enter password for: $Username" -ForegroundColor Cyan
    $SecurePassword = Read-Host "Password" -AsSecureString
    $Credential = New-Object PSCredential($Username, $SecurePassword)
}

$OutputFile = Join-Path -Path $OutputPath -ChildPath "$TargetName.xml"

Write-Host ""
Write-Host "Creating credential file: $OutputFile" -ForegroundColor Cyan
Write-Host "Encryption Method: $EncryptionMethod" -ForegroundColor Cyan

if ($EncryptionMethod -eq "DPAPI") {
    $Credential | Export-Clixml -Path $OutputFile -ErrorAction Stop
    Write-Host "Credential saved successfully (DPAPI encryption)" -ForegroundColor Green
    Write-Host ""
    Write-Host "SECURITY NOTE: This credential is encrypted with DPAPI" -ForegroundColor Yellow
    Write-Host "  - Only works on the same machine" -ForegroundColor Yellow
    Write-Host "  - Only works for the same user account" -ForegroundColor Yellow
}
elseif ($EncryptionMethod -eq "AES") {
    if ($UseVaultwardenForKey) {
        Write-Host "Generating AES-256 key..." -ForegroundColor Cyan
        $AesKey = New-Object byte[] 32
        $Rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $Rng.GetBytes($AesKey)
        
        $KeyBase64 = [Convert]::ToBase64String($AesKey)
        
        Write-Host "Storing AES key in Vaultwarden..." -ForegroundColor Cyan
        $KeyVaultName = "AES-Key-$TargetName"
        
        $BwSession = $null
        
        try {
            $BwCheck = bw login --check 2>&1
            if ($BwCheck -notmatch "You are not logged in") {
                Write-Host "  Already logged into Vaultwarden" -ForegroundColor Green
            }
            else {
                $EnvPath = "$ScriptRoot\.env"
                if (Test-Path $EnvPath) {
                    . $EnvPath
                }
                if ($env:VAULTWARDEN_CLIENT_ID -and $env:VAULTWARDEN_CLIENT_SECRET) {
                    $env:BW_CLIENTID = $env:VAULTWARDEN_CLIENT_ID
                    $env:BW_CLIENTSECRET = $env:VAULTWARDEN_CLIENT_SECRET
                    bw login --apikey 2>&1 | Out-Null
                    Write-Host "  Logged into Vaultwarden" -ForegroundColor Green
                }
                else {
                    Write-Warning "Vaultwarden credentials not configured in .env"
                    Write-Host "Please run: bw login --apikey" -ForegroundColor Yellow
                }
            }
            
            $ExistingItem = bw list items --search $KeyVaultName 2>&1
            if ($ExistingItem -match $KeyVaultName) {
                Write-Host "  Updating existing key in Vaultwarden" -ForegroundColor Yellow
                $ItemId = ($ExistingItem | ConvertFrom-Json | Where-Object { $_.name -eq $KeyVaultName }).id
                bw edit item $ItemId --json "{\"name\":\"$KeyVaultName\",\"password\":\"$KeyBase64\"}" 2>&1 | Out-Null
            }
            else {
                Write-Host "  Creating new key in Vaultwarden" -ForegroundColor Cyan
                $ItemJson = @{
                    name = $KeyVaultName
                    password = $KeyBase64
                    type = 1
                    notes = "AES-256 key for credential: $TargetName"
                } | ConvertTo-Json
                bw create item $ItemJson 2>&1 | Out-Null
            }
            
            Write-Host "  AES key stored in Vaultwarden: $KeyVaultName" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to store key in Vaultwarden: $($_.Exception.Message)"
        }
    }
    
    $PasswordBytes = [System.Text.Encoding]::UTF8.GetBytes($Credential.GetNetworkCredential().Password)
    $AesKey = [System.Convert]::FromBase64String($KeyBase64)
    
    $Aes = [System.Security.Cryptography.Aes]::Create()
    $Aes.Key = $AesKey
    $Aes.GenerateIV()
    
    $Encryptor = $Aes.CreateEncryptor()
    $EncryptedBytes = $Encryptor.TransformFinalBlock($PasswordBytes, 0, $PasswordBytes.Length)
    
    $EncryptedData = @{
        AesIV = [System.Convert]::ToBase64String($Aes.IV)
        EncryptedPassword = [System.Convert]::ToBase64String($EncryptedData)
        Username = $Credential.UserName
        KeyStorage = if ($UseVaultwardenForKey) { "Vaultwarden" } else { "Manual" }
    }
    
    $EncryptedData | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
    
    Write-Host "Credential saved successfully (AES encryption)" -ForegroundColor Green
    Write-Host ""
    Write-Host "SECURITY NOTE: This credential uses AES-256 encryption" -ForegroundColor Yellow
    Write-Host "  - AES key is stored in Vaultwarden" -ForegroundColor Yellow
    Write-Host "  - Credential can be decrypted on any machine with Vaultwarden access" -ForegroundColor Yellow
}

$Acl = Get-Acl -Path $OutputFile
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Acl.SetAccessRuleProtection($true, $false)
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $CurrentUser,
    "FullControl",
    "Allow"
)
$Acl.AddAccessRule($Rule)
Set-Acl -Path $OutputFile -AclObject $Acl

Write-Host ""
Write-Host "File permissions secured (current user only)" -ForegroundColor Green
Write-Host "Credential file created: $OutputFile" -ForegroundColor Green
