<#
.SYNOPSIS
    Converts JSON file to XML.

.PARAMETER InputFile
    Path to JSON file.

.PARAMETER OutputFile
    Path to output XML file.

.EXAMPLE
    .\ConvertTo-XmlFromJson.ps1 -InputFile "data.json" -OutputFile "data.xml"
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

$XmlContent = $JsonContent | ConvertTo-Xml -NoTypeInformation

$XmlContent.Save($OutputFile)

Write-Host "Converted $InputFile to $OutputFile" -ForegroundColor Green

return $OutputFile
