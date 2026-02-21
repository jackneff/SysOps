<#
.SYNOPSIS
    Tests FTP/SFTP connection.

.DESCRIPTION
    Uses WinSCP to test connection to an FTP or SFTP server.

.PARAMETER SessionUrl
    WinSCP session URL (e.g., ftp://user:password@hostname or sftp://user:password@hostname).

.PARAMETER TimeoutSeconds
    Connection timeout in seconds.

.EXAMPLE
    .\Test-FtpConnection.ps1 -SessionUrl "ftp://user:password@ftp.example.com"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SessionUrl,
    
    [int]$TimeoutSeconds = 30
)

$ErrorActionPreference = "Stop"

Add-Type -Path "$env:ProgramFiles (x86)\WinSCP\WinSCPnet.dll"

$SessionOptions = New-Object WinSCP.SessionOptions
$SessionOptions.ParseUrl($SessionUrl)

$Session = New-Object WinSCP.Session

try {
    $Session.Open($SessionOptions)
    
    Write-Host "Connection successful!" -ForegroundColor Green
    Write-Host "Protocol: $($Session.Opened)" -ForegroundColor Cyan
    
    $Session.Close()
    
    return $true
}
catch {
    Write-Error "Connection failed: $($_.Exception.Message)"
    return $false
}
finally {
    if ($Session) { $Session.Dispose() }
}
