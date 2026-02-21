<#
.SYNOPSIS
    Gets file or folder permissions.

.DESCRIPTION
    Retrieves NTFS permissions for a file or folder.

.PARAMETER Path
    File or folder path.

.EXAMPLE
    .\Get-FilePermissions.ps1 -Path "C:\Shared"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path)) {
    Write-Error "Path not found: $Path"
    exit 1
}

Write-Host "Retrieving permissions for: $Path" -ForegroundColor Cyan

$Acl = Get-Acl -Path $Path

$Results = @()

foreach ($Access in $Acl.Access) {
    $Results += [PSCustomObject]@{
        IdentityReference = $Access.IdentityReference
        FileSystemRights  = $Access.FileSystemRights
        AccessControlType = $Access.AccessControlType
        IsInherited       = $Access.IsInherited
    }
}

Write-Host "`nPermissions:" -ForegroundColor Green
$Results | Format-Table -AutoSize

return $Results
