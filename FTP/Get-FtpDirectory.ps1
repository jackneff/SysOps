<#
.SYNOPSIS
    Lists directory contents on FTP/SFTP server.

.DESCRIPTION
    Uses WinSCP to list files and folders on an FTP or SFTP server.

.PARAMETER SessionUrl
    WinSCP session URL (e.g., ftp://user:password@hostname or sftp://user:password@hostname).

.PARAMETER RemotePath
    Remote directory path to list.

.EXAMPLE
    .\Get-FtpDirectory.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -RemotePath "/"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SessionUrl,
    
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
    
    $DirectoryInfo = $Session.ListDirectory($RemotePath)
    
    $Results = @()
    foreach ($Item in $DirectoryInfo.Files) {
        $Results += [PSCustomObject]@{
            Name      = $Item.Name
            IsDirectory = $Item.IsDirectory
            Length    = $Item.Length
            LastModified = $Item.LastWriteTime
            Permissions = $Item.Permissions
        }
    }
    
    $Results | Format-Table -AutoSize
    
    $Session.Close()
    
    return $Results
}
catch {
    Write-Error "FTP directory listing failed: $($_.Exception.Message)"
}
finally {
    if ($Session) { $Session.Dispose() }
}
