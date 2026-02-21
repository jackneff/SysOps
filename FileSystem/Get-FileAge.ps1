<#
.SYNOPSIS
    Gets file age information.

.DESCRIPTION
    Shows how old a file is based on creation and modification dates.

.PARAMETER Path
    File path.

.EXAMPLE
    .\Get-FileAge.ps1 -Path "C:\oldfile.dat"
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

$File = Get-Item -Path $Path -Force

$Now = Get-Date

$CreatedAge = $Now - $File.CreationTime
$ModifiedAge = $Now - $File.LastWriteTime
$AccessedAge = $Now - $File.LastAccessTime

function Get-AgeString {
    param($Span)
    
    if ($Span.Days -gt 365) {
        $Years = [math]::Floor($Span.Days / 365)
        $Months = [math]::Floor(($Span.Days % 365) / 30)
        return "$Years year(s), $Months month(s)"
    }
    elseif ($Span.Days -gt 30) {
        $Months = [math]::Floor($Span.Days / 30)
        $Days = $Span.Days % 30
        return "$Months month(s), $Days day(s)"
    }
    elseif ($Span.Days -gt 0) {
        return "$($Span.Days) day(s)"
    }
    elseif ($Span.Hours -gt 0) {
        return "$($Span.Hours) hour(s)"
    }
    else {
        return "$($Span.Minutes) minute(s)"
    }
}

$Result = [PSCustomObject]@{
    Path               = $Path
    Name               = $File.Name
    CreatedTime        = $File.CreationTime
    CreatedAge         = Get-AgeString $CreatedAge
    CreatedDaysAgo     = $CreatedAge.Days
    ModifiedTime       = $File.LastWriteTime
    ModifiedAge        = Get-AgeString $ModifiedAge
    ModifiedDaysAgo    = $ModifiedAge.Days
    AccessedTime       = $File.LastAccessTime
    AccessedAge        = Get-AgeString $AccessedAge
    AccessedDaysAgo    = $AccessedAge.Days
}

Write-Host "File Age Information:" -ForegroundColor Green
$Result | Format-List

return $Result
