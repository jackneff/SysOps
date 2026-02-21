<#
.SYNOPSIS
    Converts XML file to JSON.

.PARAMETER InputFile
    Path to XML file.

.PARAMETER OutputFile
    Path to output JSON file.

.EXAMPLE
    .\ConvertTo-JsonFromXml.ps1 -InputFile "data.xml" -OutputFile "data.json"
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

$JsonContent = $XmlContent | ConvertTo-Json -Depth 10

$JsonContent | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Converted $InputFile to $OutputFile" -ForegroundColor Green

return $OutputFile
