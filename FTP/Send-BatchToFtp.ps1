<#
.SYNOPSIS
    Batch uploads multiple files to FTP/SFTP.

.DESCRIPTION
    Uses WinSCP to upload multiple files matching a pattern to an FTP or SFTP server.

.PARAMETER SessionUrl
    WinSCP session URL.

.PARAMETER LocalPath
    Local folder or file path (supports wildcards).

.PARAMETER RemotePath
    Remote destination folder.

.PARAMETER RemoveSource
    Delete local files after successful upload.

.EXAMPLE
    .\Send-BatchToFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -LocalPath "C:\upload\*" -RemotePath "/upload/"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SessionUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$LocalPath,
    
    [Parameter(Mandatory = $true)]
    [string]$RemotePath,
    
    [switch]$RemoveSource
)

$ErrorActionPreference = "Stop"

Add-Type -Path "$env:ProgramFiles (x86)\WinSCP\WinSCPnet.dll"

try {
    $SessionOptions = New-Object WinSCP.SessionOptions
    $SessionOptions.ParseUrl($SessionUrl)
    
    $Session = New-Object WinSCP.Session
    $Session.Open($SessionOptions)
    
    $TransferOptions = New-Object WinSCP.TransferOptions
    $TransferOptions.TransferMode = [WinSCP.TransferMode]::Automatic
    
    Write-Host "Uploading files from: $LocalPath" -ForegroundColor Cyan
    Write-Host "To: $RemotePath" -ForegroundColor Cyan
    
    $TransferResult = $Session.PutFiles($LocalPath, $RemotePath, $RemoveSource, $TransferOptions)
    
    $SuccessCount = 0
    $FailCount = 0
    
    foreach ($Transfer in $TransferResult.Transfers) {
        if ($Transfer.Error -eq $null) {
            Write-Host "[OK] $($Transfer.FileName)" -ForegroundColor Green
            $SuccessCount++
        }
        else {
            Write-Host "[FAIL] $($Transfer.FileName): $($Transfer.Error.Message)" -ForegroundColor Red
            $FailCount++
        }
    }
    
    Write-Host "`nTransfer Summary:" -ForegroundColor Cyan
    Write-Host "  Successful: $SuccessCount" -ForegroundColor Green
    Write-Host "  Failed: $FailCount" -ForegroundColor Red
    
    $Session.Close()
}
catch {
    Write-Error "Batch upload failed: $($_.Exception.Message)"
}
finally {
    if ($Session) { $Session.Dispose() }
}
