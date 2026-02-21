<#
.SYNOPSIS
    Converts CSV file to XML.

.PARAMETER InputFile
    Path to CSV file.

.PARAMETER OutputFile
    Path to output XML file.

.EXAMPLE
    .\ConvertTo-XmlFromCsv.ps1 -InputFile "data.csv" -OutputFile "data.xml"
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

$XmlContent = $CsvContent | ConvertTo-Xml -NoTypeInformation

$XmlContent.Save($OutputFile)

Write-Host "Converted $InputFile to $OutputFile" -ForegroundColor Green

return $OutputFile
