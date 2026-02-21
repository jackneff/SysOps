<#
.SYNOPSIS
    Finds large files in a directory.

.DESCRIPTION
    Searches for files larger than a specified threshold.

.PARAMETER Path
    Directory to search.

.PARAMETER MinimumSizeMB
    Minimum file size in MB (default: 100).

.PARAMETER Top
    Number of largest files to return.

.EXAMPLE
    .\Find-LargeFiles.ps1 -Path "C:\" -MinimumSizeMB 500 -Top 10
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [int]$MinimumSizeMB = 100,
    
    [int]$Top = 20
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Path is not a directory: $Path"
    exit 1
}

$MinimumBytes = $MinimumSizeMB * 1MB

Write-Host "Searching for files larger than $MinimumSizeMB MB in $Path..." -ForegroundColor Cyan

$Files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -ge $MinimumBytes } |
    Sort-Object Length -Descending |
    Select-Object -First $Top

$Results = @()
foreach ($File in $Files) {
    $Results += [PSCustomObject]@{
        Name     = $File.Name
        FullPath = $File.FullName
        SizeMB   = [math]::Round($File.Length / 1MB, 2)
        SizeGB   = [math]::Round($File.Length / 1GB, 2)
        Modified = $File.LastWriteTime
    }
}

Write-Host "`nLargest Files:" -ForegroundColor Green
$Results | Format-Table -AutoSize

return $Results
