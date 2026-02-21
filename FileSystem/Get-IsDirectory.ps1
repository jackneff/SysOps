<#
.SYNOPSIS
    Checks if a path is a directory.

.DESCRIPTION
    Determines whether the specified path is a directory or file.

.PARAMETER Path
    Path to check.

.EXAMPLE
    .\Get-IsDirectory.ps1 -Path "C:\Windows"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
    Write-Error "Path does not exist: $Path"
    exit 1
}

$Item = Get-Item -Path $Path -Force

$Result = [PSCustomObject]@{
    Path        = $Path
    Name        = $Item.Name
    IsDirectory = $Item.PSIsContainer
    IsFile      = -not $Item.PSIsContainer
    FullName    = $Item.FullName
}

if ($Item.PSIsContainer) {
    Write-Host "$Path is a directory" -ForegroundColor Cyan
}
else {
    Write-Host "$Path is a file" -ForegroundColor Yellow
}

$Result | Format-List
return $Result
