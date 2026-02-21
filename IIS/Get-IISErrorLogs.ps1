<#
.SYNOPSIS
    Gets IIS error logs (5xx errors).

.PARAMETER ComputerName
    Target server.

.PARAMETER LogPath
    Path to IIS log files.

.PARAMETER Hours
    Hours to look back.

.EXAMPLE
    .\Get-IISErrorLogs.ps1 -ComputerName "WebServer01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [string]$LogPath = "",
    [int]$Hours = 24
)

$ErrorActionPreference = "Stop"

if (-not $LogPath) {
    $LogPath = "$env:SystemDrive\inetpub\logs\LogFiles"
}

$ScriptBlock = {
    param($LogPath, $Hours)
    
    $CutoffTime = (Get-Date).AddHours(-$Hours)
    $LogFiles = Get-ChildItem -Path $LogPath -Filter "*.log" -Recurse | Where-Object { $_.LastWriteTime -gt $CutoffTime }
    
    $Errors = @()
    
    foreach ($File in $LogFiles) {
        $Content = Get-Content $File.FullName -Tail 1000
        
        foreach ($Line in $Content) {
            if ($Line -match '^\d{4}-\d{2}-\d{2}' -and $Line -match ' 5\d{2} ') {
                $Parts = $Line -split ' '
                $Errors += [PSCustomObject]@{
                    DateTime    = $Parts[0] + " " + $Parts[1]
                    SiteName    = $Parts[2]
                    StatusCode  = $Parts[3]
                    UriStem     = $Parts[6]
                    UriQuery    = $Parts[7]
                }
            }
        }
    }
    
    $Errors | Sort-Object DateTime -Descending | Select-Object -First 50
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock $LogPath $Hours
}
else {
    $Results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $LogPath, $Hours
}

Write-Host "IIS Errors on: $ComputerName (Last $Hours hours)" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results
