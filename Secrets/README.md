# Secrets Management Examples

This folder contains scripts for secure credential management in PowerShell.

## Why Secure Credential Management?

**NEVER store passwords in plain text in scripts!** This is a critical security vulnerability that can lead to:
- Unauthorized access to systems
- Data breaches
- Compliance violations
- Security audit failures

This section provides multiple approaches to securely store and retrieve credentials.

---

## Understanding the Encryption Methods

### DPAPI (Data Protection API)
- **How it works:** Uses Windows built-in encryption tied to user account and machine
- **Pros:** No additional setup required, built into Windows
- **Cons:** Only works on the same machine with the same user account
- **Best for:** Single-server scripts, development
- **Security:** High - credentials encrypted by Windows OS

### AES-256 Encryption
- **How it works:** Uses AES-256 algorithm with an encryption key
- **Pros:** Cross-machine compatible, key can be stored separately
- **Cons:** Requires key management
- **Best for:** Multi-server automation, team environments
- **Security:** Very High - industry-standard encryption

### Vaultwarden (Self-hosted Bitwarden)
- **How it works:** Secrets stored in your Vaultwarden server
- **Pros:** Centralized, team sharing, audit logs, API key auth
- **Cons:** Requires Vaultwarden server
- **Best for:** Team environments, cross-machine scripts
- **Security:** High - your own password manager

### Azure Key Vault
- **How it works:** Cloud-hosted secrets by Microsoft
- **Pros:** Enterprise-ready, Managed Identity (no credentials), compliance
- **Cons:** Requires Azure subscription
- **Best for:** Azure workloads, hybrid environments
- **Security:** Very High - Microsoft-managed encryption

---

## Installation

### Install Required Modules

```powershell
.\Secrets\Install-SecretModules.ps1
```

This installs:
- `CredentialManager` - Windows Credential Manager integration
- `Microsoft.PowerShell.SecretManagement` - Secret framework
- `Microsoft.PowerShell.SecretStore` - Local vault
- Checks for `bw` CLI (Vaultwarden)

### Configure Environment

1. Copy `.env.example` to `.env`
2. Fill in your configuration:

```powershell
# Edit .env file with your values
VAULTWARDEN_URL=https://vault.yourcompany.com
VAULTWARDEN_CLIENT_ID=your-client-id
VAULTWARDEN_CLIENT_SECRET=your-client-secret
```

---

## Creating Credentials

### New-StoredCredential.ps1

Creates an encrypted XML credential file.

```powershell
# DPAPI encryption (same machine only)
.\Secrets\New-StoredCredential.ps1 -TargetName "SQLServer01-Admin" -OutputPath "C:\Scripts\Secrets"

# AES encryption with key stored in Vaultwarden
.\Secrets\New-StoredCredential.ps1 -TargetName "SQLServer01-Admin" -OutputPath "C:\Scripts\Secrets" -EncryptionMethod AES -UseVaultwardenForKey
```

**Example Output:**
```
Enter credentials for: SQLServer01-Admin
Credential created: john.smith

Creating credential file: C:\Scripts\Secrets\SQLServer01-Admin.xml
Encryption Method: DPAPI
Credential saved successfully (DPAPI encryption)

SECURITY NOTE: This credential is encrypted with DPAPI
  - Only works on the same machine
  - Only works for the same user account

File permissions secured (current user only)
Credential file created: C:\Scripts\Secrets\SQLServer01-Admin.xml
```

### New-EncryptedPassword.ps1

Encrypts individual secrets (API keys, tokens).

```powershell
.\Secrets\New-EncryptedPassword.ps1 -SecretName "AWS-API-Key" -OutputPath "C:\Scripts\Secrets"
```

---

## Using Credentials in Scripts

### Get-StoredCredential.ps1

Load a stored credential.

```powershell
# Load credential
$Cred = & ".\Secrets\Get-StoredCredential.ps1" -Path "C:\Scripts\Secrets\SQLServer01-Admin.xml"

# Use in SQL
Invoke-Sqlcmd -ServerInstance "SQLServer01" -Credential $Cred -Database "Master" -Query "SELECT @@VERSION"

# Use for remote connection
Enter-PSSession -ComputerName "Server01" -Credential $Cred

# Use with any cmdlet that accepts -Credential
```

**Example Output:**
```
Loading credential from: C:\Scripts\Secrets\SQLServer01-Admin.xml
Credential loaded successfully
Username: john.smith
```

---

## Vaultwarden Integration

### Invoke-Vaultwarden.ps1

Retrieve secrets directly from Vaultwarden.

```powershell
# Test connection
.\Secrets\Invoke-Vaultwarden.ps1 -Command Test

# Get password
$Password = & ".\Secrets\Invoke-Vaultwarden.ps1" -Command GetPassword -SecretName "Database-Password"

# Get custom field (API key, token, etc.)
$ApiKey = & ".\Secrets\Invoke-Vaultwarden.ps1" -Command GetField -SecretName "AWS-Credentials" -FieldName "AccessKey"

# List all items
$Items = & ".\Secrets\Invoke-Vaultwarden.ps1" -Command List
$Items | Format-Table
```

**Example Output:**
```
Checking: Vaultwarden
Vaultwarden connection: OK

# Get password
$Password = & ".\Secrets\Invoke-Vaultwarden.ps1" -Command GetPassword -SecretName "Production-DB"
Password123!

# Get custom field
$ApiKey = & ".\Secrets\Invoke-Vaultwarden.ps1" -Command GetField -SecretName "AWS-Production" -FieldName "SecretKey"
akia1234567890abcdef
```

---

## Azure Key Vault Integration

### Invoke-AzureKeyVault.ps1

Retrieve secrets from Azure Key Vault.

```powershell
# Test connection (using Managed Identity)
.\Secrets\Invoke-AzureKeyVault.ps1 -Command Test -VaultName "ProductionVault"

# Get secret
$Secret = & ".\Secrets\Invoke-AzureKeyVault.ps1" -Command GetSecret -VaultName "ProductionVault" -SecretName "DatabasePassword"

# List secrets
$Secrets = & ".\Secrets\Invoke-AzureKeyVault.ps1" -Command List -VaultName "ProductionVault"
$Secrets | Format-Table
```

**Example Output:**
```
Checking: Azure Key Vault
Connected using Managed Identity
Azure Key Vault connection: OK

# Get secret
$Secret = & ".\Secrets\Invoke-AzureKeyVault.ps1" -Command GetSecret -VaultName "ProdVault" -SecretName "ConnectionString"
Server=prod.database.com;Database=MyDB;User=admin;Password=P@ssw0rd;

# List secrets
$Secrets = & ".\Secrets\Invoke-AzureKeyVault.ps1" -Command List -VaultName "ProdVault"

Name                  Id                                    Enabled Expires
----                  --                                    ------- --------
DatabasePassword      https://prodvault.vault.azure.net/... True    12/31/2025
API-Key               https://prodvault.vault.azure.net/... True    Never
```

---

## Unified Interface

### Get-Secret.ps1

Single interface for all sources.

```powershell
# From file
$Cred = & ".\Secrets\Get-Secret.ps1" -Source File -Name "SQLServer01-Admin" -Path "C:\Scripts\Secrets"

# From Vaultwarden
$Password = & ".\Secrets\Get-Secret.ps1" -Source Vaultwarden -Name "Database-Password"

# From Azure Key Vault
$Secret = & ".\Secrets\Get-Secret.ps1" -Source AzureKeyVault -Name "ApiKey"
```

---

## Windows Credential Manager

### Get-WindowsCredential.ps1

Use Windows built-in credential manager.

```powershell
# Store a credential
.\Secrets\Get-WindowsCredential.ps1 -TargetName "SQLServer01" -StoreCredential

# Retrieve
$Cred = & ".\Secrets\Get-WindowsCredential.ps1" -TargetName "SQLServer01"
```

---

## Complete Usage Examples

### Example 1: SQL Server Connection

```powershell
# At the top of your script
$SqlCred = & ".\Secrets\Get-StoredCredential.ps1" -Path "C:\Scripts\Secrets\Production-SQL.xml"

# Use for SQL operations
$Server = "Production-SQL01"
$Database = "Master"

# Query
$Result = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Credential $SqlCred `
    -Query "SELECT @@VERSION, DB_NAME()"

# Backup
Backup-SqlDatabase -ServerInstance $Server -Database "UserDB" -Credential $SqlCred `
    -BackupFile "\\BackupServer\Backups\UserDB.bak"
```

### Example 2: Remote Server Management

```powershell
# Get credential
$AdminCred = & ".\Secrets\Get-StoredCredential.ps1" -Path "C:\Scripts\Secrets\Domain-Admin.xml"

# Create session
$Session = New-PSSession -ComputerName "Server01" -Credential $AdminCred

# Run commands remotely
Invoke-Command -Session $Session -ScriptBlock {
    Get-Service -Name MSSQLSERVER
    Get-Process | Where-Object { $_.Name -like "*sql*" }
}

# Remove session
Remove-PSSession $Session
```

### Example 3: API Call with Token

```powershell
# Get API key from Vaultwarden
$ApiKey = & ".\Secrets\Invoke-Vaultwarden.ps1" -Command GetPassword -SecretName "External-API-Key"

# Use in request
$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

$Response = Invoke-RestMethod -Uri "https://api.example.com/data" -Headers $Headers

# Clear sensitive data from memory
Remove-Variable ApiKey
```

### Example 4: Azure Deployment

```powershell
# Using Managed Identity (no credentials needed!)
$DbPassword = & ".\Secrets\Invoke-AzureKeyVault.ps1" `
    -Command GetSecret `
    -VaultName "ProductionVault" `
    -SecretName "DBPassword"

# Use in ARM template or deployment
$Params = @{
    ResourceGroupName = "Prod-RG"
    VmName = "WebServer01"
    AdminPassword = $DbPassword
}

# Deploy
New-AzVM @Params
```

---

## Security Best Practices Checklist

- [ ] **NEVER commit credentials to version control** - Add `.env` and credential files to `.gitignore`
- [ ] **Store credentials outside project directory** - Use `C:\Scripts\Secrets\` not project folder
- [ ] **Use DPAPI for single-machine scripts** - Works with Windows security
- [ ] **Use AES + Vaultwarden for cross-machine** - Most flexible for automation
- [ ] **Use Managed Identity for Azure** - No credentials to manage
- [ ] **Restrict file permissions** - Only the service account should access credential files
- [ ] **Rotate credentials regularly** - Update stored passwords periodically
- [ ] **Audit access** - Log who uses which credentials and when
- [ ] **Use least privilege** - Don't use domain admin credentials unless necessary
- [ ] **Clear sensitive data** - Remove variables containing passwords after use

---

## Troubleshooting

### "Credential file not found"
- Verify the path is correct
- Check that `.env` configuration points to the right location

### "Vaultwarden not logged in"
- Run `bw login --apikey` interactively first
- Or ensure `.env` has API credentials configured

### "Azure Managed Identity not available"
- Ensure script runs on Azure VM with Managed Identity enabled
- Or use Service Principal authentication

### "DPAPI decryption failed"
- Credential was created on different machine or user account
- Use AES encryption for portable credentials
