<#
.SYNOPSIS
    Finds duplicate files by hash.

.DESCRIPTION
    Identifies duplicate files by comparing SHA256 hashes.

.PARAMETER Path
    Directory to search.

.PARAMETER MinimumSizeKB
    Minimum file size to check (skip small files).

.EXAMPLE
    .\Get-DuplicateFiles.ps1 -Path "C:\Duplicates" -MinimumSizeKB 100
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [int]$MinimumSizeKB = 1
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Path is not a directory: $Path"
    exit 1
}

$MinimumBytes = $MinimumSizeKB * 1024

Write-Host "Finding duplicate files in $Path..." -ForegroundColor Cyan
Write-Host "This may take a while for large directories..." -ForegroundColor Yellow

$Files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -ge $MinimumBytes }

Write-Host "Checking $($Files.Count) files..." -ForegroundColor Cyan

$HashTable = @{}
$Duplicates = @()

foreach ($File in $Files) {
    $Hash = Get-FileHash -Path $File.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue
    
    if ($Hash) {
        if ($HashTable.ContainsKey($Hash.Hash)) {
            $Duplicates += [PSCustomObject]@{
                OriginalFile  = $HashTable[$Hash.Hash]
                DuplicateFile = $File.FullName
                SizeMB        = [math]::Round($File.Length / 1MB, 2)
                Hash          = $Hash.Hash
            }
        }
        else {
            $HashTable[$Hash.Hash] = $File.FullName
        }
    }
}

if ($Duplicates.Count -gt 0) {
    Write-Host "`nFound $($Duplicates.Count) duplicate files:" -ForegroundColor Red
    $Duplicates | Format-Table -AutoSize
}
else {
    Write-Host "`nNo duplicate files found." -ForegroundColor Green
}

return $Duplicates
