<#
.SYNOPSIS
    Gets all groups a user belongs to (including nested).

.DESCRIPTION
    Retrieves all group membership for a user, including nested group membership.

.PARAMETER Identity
    User identity (SAMAccountName or DN).

.EXAMPLE
    .\Get-ADUserGroups.ps1 -Identity jsmith

.EXAMPLE
    .\Get-ADUserGroups.ps1 -Identity "CN=John Smith,OU=Users,DC=domain,DC=com"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

try {
    $User = Get-ADUser -Identity $Identity -ErrorAction Stop
    $Groups = Get-ADPrincipalGroupMembership -Identity $User.DistinguishedName -ErrorAction Stop
    
    $Results = $Groups | Select-Object Name, GroupCategory, GroupScope, DistinguishedName
    
    Write-Host "Groups for user: $($User.SamAccountName)" -ForegroundColor Cyan
    $Results | Format-Table -AutoSize
    
    return $Results
}
catch {
    Write-Error "Failed to get user groups: $($_.Exception.Message)"
    exit 1
}
