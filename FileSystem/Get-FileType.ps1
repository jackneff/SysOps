<#
.SYNOPSIS
    Gets file type information.

.DESCRIPTION
    Returns file type details based on extension and MIME type.

.PARAMETER Path
    File path.

.EXAMPLE
    .\Get-FileType.ps1 -Path "C:\document.pdf"
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

$Extension = $File.Extension.ToLower()

$ExtensionMap = @{
    ".txt" = "Text File"
    ".doc" = "Word Document"
    ".docx" = "Word Document"
    ".xls" = "Excel Spreadsheet"
    ".xlsx" = "Excel Spreadsheet"
    ".ppt" = "PowerPoint Presentation"
    ".pptx" = "PowerPoint Presentation"
    ".pdf" = "PDF Document"
    ".zip" = "ZIP Archive"
    ".rar" = "RAR Archive"
    ".7z" = "7-Zip Archive"
    ".tar" = "TAR Archive"
    ".gz" = "GZIP Archive"
    ".jpg" = "JPEG Image"
    ".jpeg" = "JPEG Image"
    ".png" = "PNG Image"
    ".gif" = "GIF Image"
    ".bmp" = "Bitmap Image"
    ".svg" = "SVG Vector Image"
    ".mp3" = "MP3 Audio"
    ".wav" = "WAV Audio"
    ".mp4" = "MP4 Video"
    ".avi" = "AVI Video"
    ".mkv" = "MKV Video"
    ".exe" = "Executable"
    ".dll" = "Dynamic Link Library"
    ".ps1" = "PowerShell Script"
    ".psm1" = "PowerShell Module"
    ".psd1" = "PowerShell Data File"
    ".bat" = "Batch File"
    ".cmd" = "Command Script"
    ".sh" = "Shell Script"
    ".py" = "Python Script"
    ".js" = "JavaScript"
    ".ts" = "TypeScript"
    ".cs" = "C# Source Code"
    ".java" = "Java Source Code"
    ".html" = "HTML Document"
    ".css" = "Cascading Style Sheet"
    ".json" = "JSON File"
    ".xml" = "XML File"
    ".csv" = "CSV File"
    ".log" = "Log File"
    ".ini" = "INI Configuration"
    ".cfg" = "Configuration File"
    ".config" = "Configuration File"
    ".reg" = "Registry File"
    ".iso" = "Disk Image"
    ".img" = "Disk Image"
    ".vhd" = "Virtual Hard Disk"
    ".vhdx" = "Virtual Hard Disk"
}

$FileType = if ($ExtensionMap.ContainsKey($Extension)) { $ExtensionMap[$Extension] } else { "Unknown" }

$Result = [PSCustomObject]@{
    Path         = $Path
    Name         = $File.Name
    Extension    = $Extension
    FileType     = $FileType
    SizeBytes    = $File.Length
    SizeKB       = [math]::Round($File.Length / 1KB, 2)
    SizeMB       = [math]::Round($File.Length / 1MB, 2)
    IsReadOnly   = $File.IsReadOnly
    Attributes   = $File.Attributes
}

Write-Host "File Type Information:" -ForegroundColor Green
$Result | Format-List

return $Result
