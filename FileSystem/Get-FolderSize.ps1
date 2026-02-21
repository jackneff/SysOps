<#
.SYNOPSIS
    Gets the size of a folder recursively.

.DESCRIPTION
    Calculates the total size of a folder including all subdirectories.

.PARAMETER Path
    Folder path to measure.

.PARAMETER IncludeHidden
    Include hidden files and folders.

.EXAMPLE
    .\Get-FolderSize.ps1 -Path "C:\Logs"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [switch]$IncludeHidden
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Path is not a directory: $Path"
    exit 1
}

Write-Host "Calculating folder size: $Path" -ForegroundColor Cyan

$Folder = Get-Item -Path $Path -Force:$IncludeHidden

$SizeParams = @{
    Path        = $Path
    Recurse     = $true
    File        = $true
    ErrorAction = "SilentlyContinue"
}

if ($IncludeHidden) {
    $SizeParams.Force = $true
}

$Files = Get-ChildItem @SizeParams

$TotalSize = ($Files | Measure-Object -Property Length -Sum).Sum
$FileCount = $Files.Count
$FolderCount = (Get-ChildItem -Path $Path -Recurse -Directory -ErrorAction SilentlyContinue).Count

$TotalSizeGB = [math]::Round($TotalSize / 1GB, 2)
$TotalSizeMB = [math]::Round($TotalSize / 1MB, 2)

$Result = [PSCustomObject]@{
    Path           = $Path
    TotalBytes    = $TotalSize
    TotalGB       = $TotalSizeGB
    TotalMB       = $TotalSizeMB
    FileCount     = $FileCount
    FolderCount   = $FolderCount
}

Write-Host "`nFolder Size Report:" -ForegroundColor Green
$Result | Format-List

return $Result
