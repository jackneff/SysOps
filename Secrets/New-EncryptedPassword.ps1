<#
.SYNOPSIS
    Encrypts a password for secure storage.

.DESCRIPTION
    Creates an encrypted password file using DPAPI or AES encryption.
    Useful for storing individual passwords (API keys, tokens) securely.

.PARAMETER SecretName
    Name/identifier for the secret.

.PARAMETER OutputPath
    Directory to save encrypted file.

.PARAMETER EncryptionMethod
    "DPAPI" (default) or "AES".

.EXAMPLE
    # Encrypt a password
    .\New-EncryptedPassword.ps1 -SecretName "API-Key-For-ExternalService" -OutputPath "C:\Scripts\Secrets"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SecretName,
    
    [string]$OutputPath = "",
    
    [ValidateSet("DPAPI", "AES")]
    [string]$EncryptionMethod = "DPAPI"
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
}

Write-Host "Enter the secret value to encrypt:" -ForegroundColor Cyan
$SecretValue = Read-Host -AsSecureString "Secret"

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecretValue)
$PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

$OutputFile = Join-Path -Path $OutputPath -ChildPath "$SecretName.enc.xml"

if ($EncryptionMethod -eq "DPAPI") {
    $SecureString = ConvertTo-SecureString -String $PlainText -AsPlainText -Force
    $Encrypted = ConvertFrom-SecureString -SecureString $SecureString
    
    @{
        Method = "DPAPI"
        EncryptedData = $Encrypted
        SecretName = $SecretName
        Created = Get-Date -Format "o"
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
}
else {
    $AesKey = New-Object byte[] 32
    $Rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $Rng.GetBytes($AesKey)
    
    $PasswordBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    
    $Aes = [System.Security.Cryptography.Aes]::Create()
    $Aes.Key = $AesKey
    $Aes.GenerateIV()
    
    $Encryptor = $Aes.CreateEncryptor()
    $EncryptedBytes = $Encryptor.TransformFinalBlock($PasswordBytes, 0, $PasswordBytes.Length)
    
    @{
        Method = "AES"
        EncryptedData = [Convert]::ToBase64String($EncryptedBytes)
        Key = [Convert]::ToBase64String($AesKey)
        IV = [Convert]::ToBase64String($Aes.IV)
        SecretName = $SecretName
        Created = Get-Date -Format "o"
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
}

Write-Host "Encrypted secret saved to: $OutputFile" -ForegroundColor Green
Write-Host "Method: $EncryptionMethod" -ForegroundColor Cyan

Remove-Variable PlainText
Remove-Variable SecretValue
