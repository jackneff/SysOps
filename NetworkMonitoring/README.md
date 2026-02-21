# Network Monitoring Examples

This folder contains scripts for network monitoring.

## Get-PortStatus.ps1

Check if specific ports are listening.

```powershell
# Check common ports
.\Get-PortStatus.ps1 -ComputerName "Server01" -Ports 80,443,1433,3389

# Check single port
.\Get-PortStatus.ps1 -ComputerName "Server01" -Ports 443
```

**Example Output:**
```
=== Port Status: Server01 ===
ComputerName Port IsListening Service
------------ ---- ----------- -------
Server01     80   True        HTTP
Server01     443  True        HTTPS
Server01     1433 True        MSSQL
Server01     3389 True        RDP
```

## Get-ProcessOnPort.ps1

Find process using a specific port.

```powershell
.\Get-ProcessOnPort.ps1 -Port 8080
```

**Example Output:**
```
=== Process on Port 8080 ===
LocalAddress LocalPort State    ProcessId ProcessName
------------ --------- -----    --------- -----------
0.0.0.0      8080      Listen   4524     java
```

## Get-ListeningPorts.ps1

List all listening ports.

```powershell
.\Get-ListeningPorts.ps1 -ComputerName "Server01"
```

**Example Output:**
```
=== Listening Ports on Server01 ===
LocalAddress LocalPort Protocol ProcessId ProcessName
------------ --------- -------- --------- -----------
0.0.0.0      80        TCP      4         httpd
0.0.0.0      443       TCP      4         httpd
0.0.0.0      1433      TCP      4524      sqlservr
127.0.0.1    3306      TCP      5234      mysqld
```

## Test-SSLCertificate.ps1

Test SSL certificate.

```powershell
.\Test-SSLCertificate.ps1 -HostName "www.example.com" -Port 443
```

**Example Output:**
```
=== SSL Certificate: www.example.com:443 ===
HostName          : www.example.com
Port              : 443
Subject           : CN=www.example.com
Issuer            : DigiCert SHA2 Extended Validation Server CA
Thumbprint        : A1B2C3D4E5F6...
NotBefore         : 2024-01-01 00:00:00
NotAfter          : 2025-01-01 00:00:00
DaysUntilExpiry   : 365
```

## Get-SSLCertificateRemote.ps1

Get SSL certificate from remote server.

```powershell
.\Get-SSLCertificateRemote.ps1 -ComputerName "WebServer01" -Port 443
```

## Get-ExpiringCertificates.ps1

Find certificates expiring soon.

```powershell
.\Get-ExpiringCertificates.ps1 -ComputerName "Server01" -Days 30
```

**Example Output:**
```
=== Expiring Certificates (within 30 days) on Server01 ===
Subject                  Thumbprint                    NotAfter      DaysUntilExpiry
-------                  ----------                    --------      ---------------
*.example.com            A1B2C3...                     2024-02-15    15
mail.example.com         D4E5F6...                     2024-02-28    28
```

## Test-NetworkConnectivity.ps1

Test network connectivity.

```powershell
# Ping test
.\Test-NetworkConnectivity.ps1 -ComputerName "Server01","Server02"

# Ping and port test
.\Test-NetworkConnectivity.ps1 -ComputerName "Server01","Server02" -TestPort 443
```

**Example Output:**
```
=== Network Connectivity ===
ComputerName Pingable LatencyMs PortTested PortOpen
------------ -------- ---------- ---------- -------
Server01     True     2          443        True
Server02     True     5          443        True
```

## Test-DNSResolution.ps1

Test DNS resolution.

```powershell
# Forward lookup
.\Test-DNSResolution.ps1 -HostName "example.com"

# Reverse lookup
.\Test-DNSResolution.ps1 -IpAddress "192.168.1.1"

# Both
.\Test-DNSResolution.ps1 -HostName "example.com" -IpAddress "192.168.1.1"
```

**Example Output:**
```
=== DNS Resolution ===
QueryType Input         Result          RecordType Success
--------- -----         ------          ---------- -------
Forward  example.com    93.184.216.34   A          True
Reverse  192.168.1.1    server1.local   PTR        True
```

## Test-Traceroute.ps1

Perform traceroute.

```powershell
.\Test-Traceroute.ps1 -HostName "www.example.com"
```

**Example Output:**
```
=== Traceroute to www.example.com ===
HopNumber Address         Status       RoundTripTime
-------- -------         ------       ------------
1        192.168.1.1     Success      2
2        10.0.0.1        TtlExpired   5
3        172.16.0.1      TtlExpired   10
4        93.184.216.34   Success      25
```

## Get-NetworkAdapterStatus.ps1

List network adapters.

```powershell
.\Get-NetworkAdapterStatus.ps1 -ComputerName "Server01"
```

**Example Output:**
```
=== Network Adapters on Server01 ===
Name           Status LinkSpeed   MacAddress    IPAddress       PrefixLength
----           ------ ---------   ----------    ---------       ------------
Ethernet       Up     1 Gbps      00-15-5D...   192.168.1.100  24
Ethernet 2     Up     1 Gbps      00-15-5D...   192.168.2.100  24
```

## Get-FirewallRules.ps1

List firewall rules.

```powershell
# Get enabled inbound rules
.\Get-FirewallRules.ps1 -Direction Inbound -Enabled

# Get all rules
.\Rules.ps1
Get-Firewall```

**Example Output:**
```
=== Firewall Rules on Server01 ===
Name                      Direction Action Enabled LocalPort Protocol
----                      --------- ------ ------- --------- --------
HTTP                      Inbound   Allow  True    80        TCP
HTTPS                     Inbound   Allow  True    443       TCP
RDP                       Inbound   Allow  True    3389      TCP
```

## Get-GPOFirewallRules.ps1

List GPO-managed firewall rules.

```powershell
.\Get-GPOFirewallRules.ps1 -ComputerName "Server01"
```
