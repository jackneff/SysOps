<#
.SYNOPSIS
    Sends/uploads a file via FTP/SFTP.

.DESCRIPTION
    Uses WinSCP to upload a file to an FTP or SFTP server.

.PARAMETER SessionUrl
    WinSCP session URL (e.g., ftp://user:password@hostname or sftp://user:password@hostname).

.PARAMETER LocalPath
    Local file path to upload.

.PARAMETER RemotePath
    Remote destination path.

.PARAMETER WinSCPFolder
    Path to WinSCP folder (defaults to Program Files).

.EXAMPLE
    .\Send-FileToFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -LocalPath "C:\file.txt" -RemotePath "/upload/"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SessionUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$LocalPath,
    
    [Parameter(Mandatory = $true)]
    [string]$RemotePath
)

$ErrorActionPreference = "Stop"

Add-Type -Path "$env:ProgramFiles (x86)\WinSCP\WinSCPnet.dll"

try {
    $SessionOptions = New-Object WinSCP.SessionOptions
    $SessionOptions.ParseUrl($SessionUrl)
    
    $Session = New-Object WinSCP.Session
    $Session.Open($SessionOptions)
    
    $TransferResult = $Session.PutFiles($LocalPath, $RemotePath)
    
    foreach ($Transfer in $TransferResult.Transfers) {
        if ($Transfer.Error -eq $null) {
            Write-Host "Uploaded: $($Transfer.FileName)" -ForegroundColor Green
        }
        else {
            Write-Error "Upload failed: $($Transfer.Error.Message)"
        }
    }
    
    $Session.Close()
}
catch {
    Write-Error "FTP upload failed: $($_.Exception.Message)"
}
finally {
    if ($Session) { $Session.Dispose() }
}
