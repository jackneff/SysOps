<#
.SYNOPSIS
    Converts XML file to CSV.

.PARAMETER InputFile
    Path to XML file.

.PARAMETER OutputFile
    Path to output CSV file.

.EXAMPLE
    .\ConvertTo-CsvFromXml.ps1 -InputFile "data.xml" -OutputFile "data.csv"
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

[xml]$XmlContent = Get-Content $InputFile -ErrorAction Stop

$Objects = $XmlContent.Objects.Object

$Objects | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Converted $InputFile to $OutputFile" -ForegroundColor Green

return $OutputFile
