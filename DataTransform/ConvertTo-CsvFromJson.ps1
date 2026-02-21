<#
.SYNOPSIS
    Converts JSON file to CSV.

.PARAMETER InputFile
    Path to JSON file.

.PARAMETER OutputFile
    Path to output CSV file.

.EXAMPLE
    .\ConvertTo-CsvFromJson.ps1 -InputFile "data.json" -OutputFile "data.csv"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,
    [Parameter(Mandatory = $true)]
    [string]$OutputFile
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    exit 1
}

$JsonContent = Get-Content $InputFile -Raw | ConvertFrom-Json

$JsonContent | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Converted $InputFile to $OutputFile" -ForegroundColor Green

return $OutputFile
