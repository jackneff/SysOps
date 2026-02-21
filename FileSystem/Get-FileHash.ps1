<#
.SYNOPSIS
    Gets file hash (MD5, SHA1, SHA256, SHA512).

.DESCRIPTION
    Calculates hash of a file using specified algorithm.

.PARAMETER Path
    File path.

.PARAMETER Algorithm
    Hash algorithm (MD5, SHA1, SHA256, SHA512).

.EXAMPLE
    .\Get-FileHash.ps1 -Path "C:\file.zip" -Algorithm SHA256
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [ValidateSet("MD5", "SHA1", "SHA256", "SHA512")]
    [string]$Algorithm = "SHA256"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Leaf)) {
    Write-Error "Path is not a file: $Path"
    exit 1
}

Write-Host "Calculating $Algorithm hash for: $Path" -ForegroundColor Cyan

$Hash = Get-FileHash -Path $Path -Algorithm $Algorithm -ErrorAction Stop

$Result = [PSCustomObject]@{
    Path      = $Path
    Name      = (Get-Item $Path).Name
    Algorithm = $Algorithm
    Hash      = $Hash.Hash
}

Write-Host "`nFile Hash:" -ForegroundColor Green
$Result | Format-List

return $Result
