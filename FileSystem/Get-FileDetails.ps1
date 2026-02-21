<#
.SYNOPSIS
    Gets detailed information about a file.

.DESCRIPTION
    Retrieves comprehensive file properties including size, dates, attributes, and hash.

.PARAMETER Path
    File path.

.PARAMETER IncludeHash
    Include file hash (MD5, SHA256).

.EXAMPLE
    .\Get-FileDetails.ps1 -Path "C:\file.txt" -IncludeHash
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [switch]$IncludeHash
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Leaf)) {
    Write-Error "Path is not a file: $Path"
    exit 1
}

$File = Get-Item -Path $Path -Force

$Result = [PSCustomObject]@{
    Name          = $File.Name
    FullName      = $File.FullName
    DirectoryName = $File.DirectoryName
    Extension     = $File.Extension
    SizeBytes     = $File.Length
    SizeKB        = [math]::Round($File.Length / 1KB, 2)
    SizeMB        = [math]::Round($File.Length / 1MB, 2)
    CreatedTime   = $File.CreationTime
    ModifiedTime  = $File.LastWriteTime
    AccessedTime  = $File.LastAccessTime
    IsReadOnly    = $File.IsReadOnly
    Attributes    = $File.Attributes
}

if ($IncludeHash) {
    Write-Host "Calculating file hashes..." -ForegroundColor Cyan
    
    $MD5 = Get-FileHash -Path $Path -Algorithm MD5 -ErrorAction SilentlyContinue
    $SHA256 = Get-FileHash -Path $Path -Algorithm SHA256 -ErrorAction SilentlyContinue
    
    $Result | Add-Member -MemberType NoteProperty -Name MD5Hash -Value $MD5.Hash
    $Result | Add-Member -MemberType NoteProperty -Name SHA256Hash -Value $SHA256.Hash
}

Write-Host "File Details:" -ForegroundColor Green
$Result | Format-List

return $Result
