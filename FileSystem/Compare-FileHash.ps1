<#
.SYNOPSIS
    Compares hashes of two files.

.DESCRIPTION
    Calculates and compares file hashes to verify file integrity.

.PARAMETER Path1
    First file path.

.PARAMETER Path2
    Second file path.

.PARAMETER Algorithm
    Hash algorithm to use.

.EXAMPLE
    .\Compare-FileHash.ps1 -Path1 "C:\file1.zip" -Path2 "C:\backup.zip"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path1,
    
    [Parameter(Mandatory = $true)]
    [string]$Path2,
    
    [ValidateSet("MD5", "SHA1", "SHA256", "SHA512")]
    [string]$Algorithm = "SHA256"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path1)) {
    Write-Error "File not found: $Path1"
    exit 1
}

if (-not (Test-Path -Path $Path2)) {
    Write-Error "File not found: $Path2"
    exit 1
}

Write-Host "Calculating $Algorithm hashes..." -ForegroundColor Cyan

$Hash1 = Get-FileHash -Path $Path1 -Algorithm $Algorithm
$Hash2 = Get-FileHash -Path $Path2 -Algorithm $Algorithm

$Match = $Hash1.Hash -eq $Hash2.Hash

$Result = [PSCustomObject]@{
    File1        = $Path1
    File2        = $Path2
    Algorithm    = $Algorithm
    Hash1        = $Hash1.Hash
    Hash2        = $Hash2.Hash
    Match        = $Match
}

Write-Host "`nHash Comparison:" -ForegroundColor Green
$Result | Format-List

if ($Match) {
    Write-Host "Files match!" -ForegroundColor Green
}
else {
    Write-Host "Files do NOT match!" -ForegroundColor Red
}

return $Result
