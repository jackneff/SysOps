<#
.SYNOPSIS
    Finds old files based on age.

.DESCRIPTION
    Searches for files not modified within specified number of days.

.PARAMETER Path
    Directory to search.

.PARAMETER DaysOld
    Find files not modified in X days.

.PARAMETER Top
    Number of files to return.

.EXAMPLE
    .\Find-OldFiles.ps1 -Path "C:\Temp" -DaysOld 180
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [Parameter(Mandatory = $true)]
    [int]$DaysOld,
    
    [int]$Top = 50
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Path is not a directory: $Path"
    exit 1
}

$CutoffDate = (Get-Date).AddDays(-$DaysOld)

Write-Host "Searching for files older than $DaysOld days in $Path..." -ForegroundColor Cyan

$Files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $CutoffDate } |
    Sort-Object LastWriteTime |
    Select-Object -First $Top

$Results = @()
foreach ($File in $Files) {
    $Age = (Get-Date) - $File.LastWriteTime
    
    $Results += [PSCustomObject]@{
        Name         = $File.Name
        FullPath     = $File.FullName
        SizeMB       = [math]::Round($File.Length / 1MB, 2)
        LastModified = $File.LastWriteTime
        DaysOld      = $Age.Days
    }
}

Write-Host "`nOld Files (Top $Top):" -ForegroundColor Green
$Results | Format-Table -AutoSize

return $Results
