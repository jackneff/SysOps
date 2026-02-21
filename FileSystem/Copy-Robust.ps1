<#
.SYNOPSIS
    Robust file copy using Robocopy.

.DESCRIPTION
    Copies files and folders using Robocopy with retry logic, logging, and verification.

.PARAMETER SourcePath
    Source directory path.

.PARAMETER DestinationPath
    Destination directory path.

.PARAMETER Mirror
    Mirror source to destination (exact match, deletes extra files).

.PARAMETER MirrorMode
    Mirror with retry on failure.

.PARAMETER RetryCount
    Number of retries on failure (default: 3).

.PARAMETER RetryWaitSeconds
    Seconds to wait between retries (default: 30).

.PARAMETER Subfolders
    Include subdirectories.

.PARAMETER ExcludeFiles
    Array of file patterns to exclude (e.g., "*.tmp", "*.log").

.PARAMETER ExcludeFolders
    Array of folder names to exclude (e.g., "temp", "cache").

.PARAMETER LogPath
    Path to save Robocopy log file.

.PARAMETER ShowProgress
    Show progress during copy.

.EXAMPLE
    .\Copy-Robust.ps1 -SourcePath "C:\Data" -DestinationPath "D:\Backup\Data" -Subfolders
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory = $true)]
    [string]$DestinationPath,
    
    [switch]$Mirror,
    
    [int]$RetryCount = 3,
    
    [int]$RetryWaitSeconds = 30,
    
    [switch]$Subfolders,
    
    [string[]]$ExcludeFiles = @(),
    
    [string[]]$ExcludeFolders = @(),
    
    [string]$LogPath = "",
    
    [switch]$ShowProgress
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $SourcePath)) {
    Write-Error "Source path not found: $SourcePath"
    exit 1
}

if (-not (Test-Path -Path $DestinationPath)) {
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
}

if ($LogPath -eq "") {
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $LogPath = "$DestinationPath\Robocopy_$Timestamp.log"
}

$RobocopyArgs = @(
    $SourcePath,
    $DestinationPath,
    "/E"
)

if ($Mirror) {
    $RobocopyArgs += "/MIR"
}

$RobocopyArgs += @(
    "/R:$RetryCount",
    "/W:$RetryWaitSeconds",
    "/MT:8",
    "/NP",
    "/LOG+:$LogPath",
    "/TEE",
    "/BYTES"
)

if ($ExcludeFiles.Count -gt 0) {
    foreach ($Pattern in $ExcludeFiles) {
        $RobocopyArgs += "/XF $Pattern"
    }
}

if ($ExcludeFolders.Count -gt 0) {
    foreach ($Folder in $ExcludeFolders) {
        $RobocopyArgs += "/XD $Folder"
    }
}

if (-not $ShowProgress) {
    $RobocopyArgs += "/NJH /NJS"
}

Write-Host "=== Robust File Copy ===" -ForegroundColor Cyan
Write-Host "Source:      $SourcePath" -ForegroundColor Cyan
Write-Host "Destination: $DestinationPath" -ForegroundColor Cyan
Write-Host "Log:        $LogPath" -ForegroundColor Cyan
Write-Host "Retries:    $RetryCount (wait $RetryWaitSeconds seconds)" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Yellow

$Success = $false
$Attempt = 0

while (-not $Success -and $Attempt -lt $RetryCount) {
    $Attempt++
    
    if ($Attempt -gt 1) {
        Write-Host "Retry attempt $Attempt of $RetryCount..." -ForegroundColor Yellow
        Start-Sleep -Seconds $RetryWaitSeconds
    }
    
    Write-Host "Starting copy (Attempt $Attempt)..." -ForegroundColor Cyan
    
    $RobocopyProcess = Start-Process -FilePath "robocopy.exe" -ArgumentList $RobocopyArgs -NoNewWindow -Wait -PassThru
    
    $ExitCode = $RobocopyProcess.ExitCode
    
    $SuccessCodes = @(0, 1, 2, 3, 4, 5, 6, 7, 8)
    if ($SuccessCodes -contains $ExitCode) {
        $Success = $true
    }
    elseif ($ExitCode -eq 16) {
        Write-Error "Robocopy fatal error (exit code: $ExitCode)"
        exit 1
    }
    else {
        Write-Warning "Robocopy completed with exit code: $ExitCode"
    }
}

if (Test-Path $LogPath) {
    $LogContent = Get-Content $LogPath -Tail 30
    Write-Host "`n=== Recent Log Output ===" -ForegroundColor Cyan
    $LogContent | Select-Object -Last 20 | ForEach-Object { Write-Host $_ }
    
    $Summary = Select-String -Path $LogPath -Pattern "Ended :"
    if ($Summary) {
        Write-Host "`n$Summary" -ForegroundColor Green
    }
}

if ($Success) {
    Write-Host "`nCopy completed successfully!" -ForegroundColor Green
    
    $SourceSize = (Get-ChildItem -Path $SourcePath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $DestSize = (Get-ChildItem -Path $DestinationPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    
    $VerifyMatch = $SourceSize -eq $DestSize
    
    $Result = [PSCustomObject]@{
        SourcePath      = $SourcePath
        DestinationPath = $DestinationPath
        Success         = $true
        Attempts        = $Attempt
        SourceSizeMB    = [math]::Round($SourceSize / 1MB, 2)
        DestSizeMB      = [math]::Round($DestSize / 1MB, 2)
        Verified        = $VerifyMatch
        LogPath         = $LogPath
    }
    
    if (-not $VerifyMatch) {
        Write-Warning "Warning: Source and destination sizes do not match!"
    }
    
    return $Result
}
else {
    Write-Error "Copy failed after $RetryCount attempts"
    exit 1
}
