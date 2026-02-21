<#
.SYNOPSIS
    Tests SSL certificate on a specific host:port.

.PARAMETER HostName
    Target hostname.

.PARAMETER Port
    SSL port (default: 443).

.EXAMPLE
    .\Test-SSLCertificate.ps1 -HostName "example.com" -Port 443
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [int]$Port = 443
)

$ErrorActionPreference = "Stop"

try {
    $TcpClient = New-Object System.Net.Sockets.TcpClient
    $TcpClient.Connect($HostName, $Port)
    $TcpClient.Close()
    
    $SslStream = New-Object System.Net.Security.SslStream($TcpClient, $false, { $true })
    $SslStream.AuthenticateAsClient($HostName)
    
    $Certificate = $SslStream.RemoteCertificate
    $X509Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Certificate)
    
    $DaysUntilExpiry = ($X509Cert.NotAfter - (Get-Date)).Days
    
    $Result = [PSCustomObject]@{
        HostName          = $HostName
        Port              = $Port
        Subject           = $X509Cert.Subject
        Issuer            = $X509Cert.Issuer
        Thumbprint        = $X509Cert.Thumbprint
        NotBefore         = $X509Cert.NotBefore
        NotAfter          = $X509Cert.NotAfter
        DaysUntilExpiry   = $DaysUntilExpiry
        IsExpired         = ($DaysUntilExpiry -lt 0)
        IsExpiringSoon    = ($DaysUntilExpiry -lt 30)
    }
    
    $SslStream.Close()
}
catch {
    $Result = [PSCustomObject]@{
        HostName          = $HostName
        Port              = $Port
        Subject           = "N/A"
        Issuer            = "N/A"
        Thumbprint        = "N/A"
        NotBefore         = "N/A"
        NotAfter          = "N/A"
        DaysUntilExpiry   = $null
        IsExpired         = $null
        IsExpiringSoon    = $null
        Error             = $_.Exception.Message
    }
}

Write-Host "=== SSL Certificate: $HostName`:$Port ===" -ForegroundColor Cyan
$Result | Format-List

if ($Result.IsExpired) {
    Write-Host "CERTIFICATE EXPIRED!" -ForegroundColor Red
}
elseif ($Result.IsExpiringSoon) {
    Write-Host "Certificate expires in $DaysUntilExpiry days" -ForegroundColor Yellow
}

return $Result
