<#
.SYNOPSIS
    Converts CSV file to JSON.

.PARAMETER InputFile
    Path to CSV file.

.PARAMETER OutputFile
    Path to output JSON file.

.EXAMPLE
    .\ConvertTo-JsonFromCsv.ps1 -InputFile "data.csv" -OutputFile "data.json"
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

$CsvContent = Import-Csv $InputFile

$CsvContent | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Converted $InputFile to $OutputFile" -ForegroundColor Green

return $OutputFile
