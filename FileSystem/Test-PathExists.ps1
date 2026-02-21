<#
.SYNOPSIS
    Tests if a path exists.

.DESCRIPTION
    Checks whether a file or directory exists at the specified path.

.PARAMETER Path
    Path to test.

.EXAMPLE
    .\Test-PathExists.ps1 -Path "C:\Logs"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = "Stop"

$Exists = Test-Path -Path $Path -ErrorAction SilentlyContinue

$Result = [PSCustomObject]@{
    Path      = $Path
    Exists    = $Exists
    IsFile    = if ($Exists) { (Get-Item $Path -ErrorAction SilentlyContinue).PSIsContainer -eq $false } else { $null }
    IsDirectory = if ($Exists) { (Get-Item $Path -ErrorAction SilentlyContinue).PSIsContainer } else { $null }
}

if ($Exists) {
    Write-Host "Path exists: $Path" -ForegroundColor Green
}
else {
    Write-Host "Path does not exist: $Path" -ForegroundColor Red
}

$Result | Format-List
return $Result
