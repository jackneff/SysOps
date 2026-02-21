<#
.SYNOPSIS
    Retrieves/downloads a file via FTP/SFTP.

.DESCRIPTION
    Uses WinSCP to download a file from an FTP or SFTP server.

.PARAMETER SessionUrl
    WinSCP session URL (e.g., ftp://user:password@hostname or sftp://user:password@hostname).

.PARAMETER RemotePath
    Remote file path to download.

.PARAMETER LocalPath
    Local destination path.

.EXAMPLE
    .\Get-FileFromFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -RemotePath "/download/file.txt" -LocalPath "C:\temp\"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SessionUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$RemotePath,
    
    [Parameter(Mandatory = $true)]
    [string]$LocalPath
)

$ErrorActionPreference = "Stop"

Add-Type -Path "$env:ProgramFiles (x86)\WinSCP\WinSCPnet.dll"

try {
    $SessionOptions = New-Object WinSCP.SessionOptions
    $SessionOptions.ParseUrl($SessionUrl)
    
    $Session = New-Object WinSCP.Session
    $Session.Open($SessionOptions)
    
    $TransferResult = $Session.GetFiles($RemotePath, $LocalPath)
    
    foreach ($Transfer in $TransferResult.Transfers) {
        if ($Transfer.Error -eq $null) {
            Write-Host "Downloaded: $($Transfer.FileName)" -ForegroundColor Green
        }
        else {
            Write-Error "Download failed: $($Transfer.Error.Message)"
        }
    }
    
    $Session.Close()
}
catch {
    Write-Error "FTP download failed: $($_.Exception.Message)"
}
finally {
    if ($Session) { $Session.Dispose() }
}
