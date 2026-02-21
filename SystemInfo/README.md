# System Info Examples

This folder contains scripts for retrieving system information.

## Get-SystemUptime.ps1

Get system uptime.

```powershell
# Check local server
.\Get-SystemUptime.ps1

# Check remote server
.\Get-SystemUptime.ps1 -ComputerName "Server01"
```

**Example Output:**
```
=== System Uptime: Server01 ===

ComputerName   : Server01
LastBootTime   : 2024-01-10 06:30:00
UptimeDays    : 5
UptimeHours   : 12
UptimeMinutes : 45
UptimeString  : 5d 12h 45m
```

## Get-SystemUptimeRemote.ps1

Get uptime from multiple servers.

```powershell
# Check multiple servers
.\Get-SystemUptimeRemote.ps1 -ComputerName "Server01","Server02","Server03"
```

**Example Output:**
```
Checking: Server01
Checking: Server02
Checking: Server03

=== System Uptime ===

ComputerName LastBootTime         UptimeDays UptimeHours UptimeMinutes UptimeString
------------ --------------         ---------- ----------- ------------- ------------
Server01    2024-01-10 06:30:00  5          12          45            5d 12h 45m
Server02    2024-01-01 00:00:00  14         8           30            14d 8h 30m
Server03    2024-01-15 14:00:00  0          2           15            0d 2h 15m
```

## Get-WindowsRoles.ps1

List installed Windows Server roles and features.

```powershell
# List all roles
.\Get-WindowsRoles.ps1

# List specific server
.\Get-WindowsRoles.ps1 -ComputerName "Server01"

# Only installed roles
.\Get-WindowsRoles.ps1 -ComputerName "Server01" -ExportInstalled
```

**Example Output:**
```
Checking roles on: Server01

=== Installed Roles/Features ===

ComputerName Name                                   DisplayName                              State
------------ ----                                   -----------                              -----
Server01    AD-CDS                                 Active Directory Domain Services        Installed
Server01    AD-CDS-VerificationTools                AD DS Verification Tools                Installed
Server01    ADDS-ADAM                              AD Lightweight Directory Services      Installed
Server01    ADDS-IdentityManagement                Identity Management for UNIX            Installed
Server01    DNS                                    DNS Server                              Installed
Server01    DHCPServer                             DHCP Server                             Installed
Server01    FileAndStorage-Services                File and Storage Services               Installed
Server01    FS-DFS-Namespace                       DFS Namespaces                          Installed
Server01    FS-DFS-Replication                    DFS Replication                        Installed
Server01    FS-FileServer                          File Server                             Installed
Server01    IIS                                   Web Server (IIS)                       Installed
Server01    NET-Framework-45-Features              .NET Framework 4.5 Features           Installed
Server01    Remote-Desktop-Services                Remote Desktop Services                Installed
Server01    Server-Media-Foundation                Server Media Foundation                Installed
Server01    WAS                                   Windows Process Activation Service     Installed
Server01    WDS                                   Windows Deployment Services            Installed

Total Installed: 45
Total Available: 120
```
