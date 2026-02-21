<#
.SYNOPSIS
    Queries Active Directory for users.

.DESCRIPTION
    Retrieves AD users with various filter options.

.PARAMETER Identity
    Specific user identity (SAMAccountName or DN).

.PARAMETER Filter
    LDAP filter string.

.PARAMETER SearchBase
    OU to search in.

.PARAMETER Enabled
    Filter by enabled/disabled accounts.

.PARAMETER Properties
    Additional properties to retrieve.

.EXAMPLE
    .\Get-ADUser.ps1 -Enabled

.EXAMPLE
    .\Get-ADUser.ps1 -SearchBase "OU=Finance,DC=domain,DC=com"
#>

[CmdletBinding()]
param(
    [string]$Identity = "",
    [string]$Filter = "*",
    [string]$SearchBase = "",
    [bool]$Enabled = $null,
    [string[]]$Properties = @("SamAccountName", "DisplayName", "EmailAddress", "Enabled", "LastLogonDate", "PasswordExpired", "LockedOut")
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available. Install RSAT-AD-PowerShell."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

$Params = @{
    Filter = $Filter
    Properties = $Properties
}

if ($Identity) {
    $Params.Identity = $Identity
}
if ($SearchBase) {
    $Params.SearchBase = $SearchBase
}
if ($Enabled -ne $null) {
    $Params.Filter = if ($Enabled) { "Enabled -eq `$true" } else { "Enabled -eq `$false" }
}

$Users = Get-ADUser @Params -ErrorAction Stop

$Results = $Users | Select-Object @(
    @{N = "SamAccountName"; E = { $_.SamAccountName }},
    @{N = "DisplayName"; E = { $_.DisplayName }},
    @{N = "EmailAddress"; E = { $_.EmailAddress }},
    @{N = "Enabled"; E = { $_.Enabled }},
    @{N = "LastLogonDate"; E = { $_.LastLogonDate }},
    @{N = "PasswordExpired"; E = { $_.PasswordExpired }},
    @{N = "LockedOut"; E = { $_.LockedOut }}
)

$Results | Format-Table -AutoSize
return $Results
