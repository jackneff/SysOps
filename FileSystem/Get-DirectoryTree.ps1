<#
.SYNOPSIS
    Gets directory tree structure.

.DESCRIPTION
    Lists the folder structure starting from a given path.

.PARAMETER Path
    Root path.

.PARAMETER Depth
    Maximum depth to traverse (default: 3).

.PARAMETER ShowFiles
    Include files in output.

.EXAMPLE
    .\Get-DirectoryTree.ps1 -Path "C:\MyApp" -Depth 2
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [int]$Depth = 3,
    
    [switch]$ShowFiles
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Path is not a directory: $Path"
    exit 1
}

function Get-DirectoryTree {
    param(
        [string]$RootPath,
        [int]$CurrentDepth,
        [int]$MaxDepth,
        [bool]$IncludeFiles,
        [string]$Indent = ""
    )
    
    if ($CurrentDepth -ge $MaxDepth) {
        return
    }
    
    $Items = Get-ChildItem -Path $RootPath -Force -ErrorAction SilentlyContinue | Sort-Object Name
    
    $Counter = 0
    $TotalItems = $Items.Count
    
    foreach ($Item in $Items) {
        $Counter++
        $IsLast = ($Counter -eq $TotalItems)
        
        $Prefix = if ($IsLast) { "└── " } else { "├── " }
        $NewIndent = if ($IsLast) { "$Indent    " } else { "$Indent│   " }
        
        if ($Item.PSIsContainer) {
            Write-Host "$Indent$Prefix$($Item.Name)/" -ForegroundColor Cyan
            Get-DirectoryTree -RootPath $Item.FullName -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth -Indent $NewIndent -IncludeFiles $IncludeFiles
        }
        elseif ($IncludeFiles) {
            $SizeKB = [math]::Round($Item.Length / 1KB, 1)
            Write-Host "$Indent$Prefix$($Item.Name) ($SizeKB KB)" -ForegroundColor White
        }
    }
}

Write-Host "Directory Tree: $Path" -ForegroundColor Green
Write-Host "Depth: $Depth`n" -ForegroundColor Yellow

Write-Host "$Path/" -ForegroundColor Cyan
Get-DirectoryTree -RootPath $Path -CurrentDepth 0 -MaxDepth $Depth -IncludeFiles $ShowFiles
