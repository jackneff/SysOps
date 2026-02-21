# Event Logs Examples

This folder contains scripts for querying Windows Event Logs.

## Get-EventLogErrors.ps1

Query Windows Event Logs for errors and warnings.

```powershell
# Get errors from System log last 24 hours
.\Get-EventLogErrors.ps1 -LogName System

# Get errors from Application log last 12 hours
.\Get-EventLogErrors.ps1 -LogName Application -Hours 12

# Get errors from remote computer
.\Get-EventLogErrors.ps1 -ComputerName "Server01" -LogName Application -MaxEvents 50

# Get Security log errors (requires admin)
.\Get-EventLogErrors.ps1 -ComputerName "DC01" -LogName Security -Hours 48

# Get errors from multiple servers
.\Get-EventLogErrors.ps1 -ComputerName "Server01","Server02","Server03" -LogName System -Hours 6
```

**Example Output:**
```
Querying Application log on localhost...

=== Event Log Errors and Warnings ===

ComputerName   TimeCreated           Id  Level  Source      Message
------------   -----------           --  -----  ------      -------
localhost      2024-01-15 14:30:01  7036 Error  Service...  The Windows Update service...
localhost      2024-01-15 12:15:22  1001 Warning  Windows...  Faulting application name...
localhost      2024-01-15 10:00:05  7036 Error  Service...  The Windows Update service...
```

## Get-SystemRestarts.ps1

Lists system restarts and identifies expected vs unexpected restarts.

```powershell
# Get all restarts from last 30 days
.\Get-SystemRestarts.ps1

# Get restarts from last 7 days
.\Get-SystemRestarts.ps1 -Days 7

# Get only unexpected restarts
.\Get-SystemRestarts.ps1 -ExportUnexpectedOnly

# Get from remote server
.\Get-SystemRestarts.ps1 -ComputerName "Server01" -Days 30
```

**Example Output:**
```
Checking: localhost

=== System Restarts (Last 30 days) ===
Expected: 3 | Unexpected: 1

TimeCreated           EventId RestartType   Expected Reason                          UserName
-----------           ------- -----------   -------- ------                          --------
2024-01-15 08:30:00   1074    Expected     True     Process initiated restart      DOMAIN\Admin
2024-01-14 06:00:00   6005    Expected     True     System started                System
2024-01-10 22:15:00   6006    Expected     True     Clean shutdown                DOMAIN\Admin
2024-01-05 14:22:00   6008    Unexpected   False    Unexpected shutdown            System
2024-01-01 03:45:00   41      Unexpected   False    Kernel power loss / BSOD       System
```

**Event ID Reference:**
| Event ID | Description | Type |
|----------|-------------|------|
| 6005 | System started | Expected |
| 6006 | Clean shutdown | Expected |
| 1074 | Process initiated restart | Expected |
| 6008 | Unexpected shutdown | Unexpected |
| 41 | Kernel power loss / crash | Unexpected |

## Get-UserLogonEvents.ps1

Lists user login events from security logs.

```powershell
# Get logon events from last 7 days
.\Get-UserLogonEvents.ps1

# Get logon events from last 30 days
.\Get-UserLogonEvents.ps1 -Days 30

# Include failed login attempts
.\Get-UserLogonEvents.ps1 -IncludeFailed

# Filter by logon type (Interactive, Network, RemoteInteractive)
.\Get-UserLogonEvents.ps1 -LogonType RemoteInteractive

# Get from domain controller
.\Get-UserLogonEvents.ps1 -ComputerName "DC01" -Days 7
```

**Example Output:**
```
Checking: localhost

=== User Logon Events (Last 7 days) ===
Successful: 150 | Failed: 12

TimeCreated           EventId Status   UserName                 LogonType      IpAddress   Process
-----------           ------- ------   --------                 ---------      ---------   -------
2024-01-15 14:30:00  4624    Success  DOMAIN\jsmith          RemoteInteractive 192.168.1.100 rdpclip.exe
2024-01-15 14:28:00  4624    Success  DOMAIN\jdoe            Network        192.168.1.50  NTLMSSP
2024-01-15 14:25:00  4624    Success  DOMAIN\Administrator    Interactive    LOCAL       Console
2024-01-15 14:20:00  4625    Failed   DOMAIN\baduser         RemoteInteractive 10.0.0.50   rdpwrap.dll
2024-01-15 12:00:00  4624    Success  DOMAIN\serviceaccount  Service        LOCAL       N/A
```

**Logon Type Reference:**
| Type ID | Name | Description |
|---------|------|-------------|
| 2 | Interactive | Local console logon |
| 3 | Network | File/folder access |
| 5 | Service | Windows service |
| 10 | RemoteInteractive | RDP logon |
| 11 | CachedInteractive | Cached credential logon |

**Security Note:** Querying Security log events requires:
- Administrator privileges
- Appropriate Windows Firewall rules (for remote computers)
- PowerShell running as Administrator
