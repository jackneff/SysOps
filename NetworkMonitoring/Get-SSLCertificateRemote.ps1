<#
.SYNOPSIS
    Gets SSL certificate from remote server.

.PARAMETER ComputerName
    Target server.

.PARAMETER Port
    SSL port.

.EXAMPLE
    .\Get-SSLCertificateRemote.ps1 -ComputerName "WebServer01" -Port 443
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [int]$Port = 443
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($Port)
    
    try {
        $TcpClient = New-Object System.Net.Sockets.TcpClient
        $TcpClient.Connect("localhost", $Port)
        $TcpClient.Close()
        
        $SslStream = New-Object System.Net.Security.SslStream($TcpClient, $false, { $true })
        $SslStream.AuthenticateAsClient("localhost")
        
        $Certificate = $SslStream.RemoteCertificate
        $X509Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Certificate)
        
        $DaysUntilExpiry = ($X509Cert.NotAfter - (Get-Date)).Days
        
        [PSCustomObject]@{
            ComputerName      = $env:COMPUTERNAME
            Port              = $Port
            Subject           = $X509Cert.Subject
            Issuer            = $X509Cert.Issuer
            Thumbprint        = $X509Cert.Thumbprint
            NotBefore         = $X509Cert.NotBefore
            NotAfter          = $X509Cert.NotAfter
            DaysUntilExpiry   = $DaysUntilExpiry
        }
        
        $SslStream.Close()
    }
    catch {
        [PSCustomObject]@{
            ComputerName      = $env:COMPUTERNAME
            Port              = $Port
            Subject           = "Error"
            Issuer            = "N/A"
            Thumbprint        = "N/A"
            NotBefore         = "N/A"
            NotAfter          = "N/A"
            DaysUntilExpiry   = $null
            Error             = $_.Exception.Message
        }
    }
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Result = & $ScriptBlock $Port
}
else {
    $Result = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $Port
}

Write-Host "=== SSL Certificate: $ComputerName`:$Port ===" -ForegroundColor Cyan
$Result | Format-List

return $Result
