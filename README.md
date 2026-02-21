# SysOps PowerShell Scripts

A comprehensive PowerShell script library for Windows system administrators managing servers in an Active Directory domain.

## Overview

This toolkit provides scripts for daily operations including:
- Service monitoring and health checks
- Web application availability testing
- Event log analysis
- Active Directory management
- IIS administration
- Disk space monitoring
- System uptime tracking
- SQL Server administration
- Network monitoring (ports, SSL, DNS, firewall)
- Data transformation (CSV/JSON/XML)
- Scheduled task management
- Server baseline comparison
- Daily health check reporting
- FTP/SFTP file transfers (via WinSCP)
- File system operations
- Secrets management (DPAPI, AES, Vaultwarden, Azure Key Vault)

## Structure

```
SysOps/
├── Config/                  # Configuration files
│   └── settings.json
├── Modules/                # Shared PowerShell modules
│   └── AdminTools.psm1
├── ServiceMonitoring/      # Service health checks
├── WebMonitoring/          # Web app availability
├── EventLogs/              # Windows event log queries
├── AD/                     # Active Directory management
├── IIS/                    # IIS administration
├── DiskSpace/              # Disk space monitoring
├── SystemInfo/             # System information (uptime)
├── SQL/                   # SQL Server administration
├── NetworkMonitoring/     # Network monitoring scripts
├── DataTransform/         # Data format conversion
├── ScheduledTasks/        # Task scheduling management
├── Baseline/              # Server baseline comparison
├── FTP/                   # FTP/SFTP file transfers
├── FileSystem/            # File system operations
├── Secrets/              # Secure credential management
└── Reports/              # Daily health check reports
```

## Quick Start

### Configuration

Edit `Config/settings.json` to customize:
- Server list
- Critical services to monitor
- Websites to check
- Disk space thresholds
- SQL Server connections
- Email settings for reports

### Running Scripts

```powershell
# Check service health across all servers
.\ServiceMonitoring\Check-ServiceHealth.ps1 -UseConfig

# Test web application availability
.\WebMonitoring\Test-WebApplicationBatch.ps1 -UseConfig

# Get disk space with threshold alerts
.\DiskSpace\Get-DiskSpaceThresholdReport.ps1 -ComputerName "Server01" -ThresholdPercent 80

# Create a server baseline
.\Baseline\New-ServerBaseline.ps1 -ComputerName "Server01"

# Compare current state to baseline
.\Baseline\Compare-Baseline.ps1 -ComputerName "Server01"

# Run daily health check with email
.\Reports\Invoke-DailyHealthCheck.ps1 -UseConfig -SendEmail
```

## Prerequisites

- PowerShell 5.1 or later
- Windows Server 2012 R2 or later
- For remote management: WinRM enabled, appropriate firewall rules
- For AD scripts: Active Directory PowerShell module (RSAT-AD-PowerShell)
- For IIS scripts: WebAdministration module
- For SQL scripts: SqlServer module or dbatools
- For FTP scripts: WinSCP assembly installed (`$env:ProgramFiles (x86)\WinSCP\WinSCPnet.dll`)

## Modules

### AdminTools.psm1

Provides shared functions:
- `Get-Config` - Load configuration
- `Test-ServerReachability` - Ping check
- `Get-RemoteService` - Get service status remotely
- `Invoke-RemoteCommand` - Execute remote commands
- `Write-Log` - Logging function
- `Export-ReportData` - Export to CSV/JSON/XML
- `Send-EmailReport` - Send email reports

## Categories

### Service Monitoring
- `Check-ServiceStatus.ps1` - Check specific service status
- `Check-ServiceHealth.ps1` - Monitor services across servers
- `Monitor-CriticalServices.ps1` - Monitor critical services with alerts
- `Find-DisabledAutoStartServices.ps1` - Find disabled auto-start services
- `Find-HungServices.ps1` - Find hung/stuck services
- `Test-ServiceAccountPermissions.ps1` - Check service account permissions
- `Watch-ServiceStateChanges.ps1` - Watch for service state changes

### Event Logs
- `Get-EventLogErrors.ps1` - Get errors and warnings from event logs
- `Get-SystemRestarts.ps1` - List system restarts (expected vs unexpected)
- `Get-UserLogonEvents.ps1` - List user login events with details

### Web Monitoring
- `Test-WebApplication.ps1` - Test single URL
- `Test-WebApplicationBatch.ps1` - Test multiple URLs

### Active Directory
- `Get-ADUser.ps1` - Query AD users
- `Get-ADGroup.ps1` - Query AD groups
- `Get-ADComputer.ps1` - Query computers
- `Get-ADUserGroups.ps1` - Get user's group membership (recursive)
- `Get-ADLockedAccounts.ps1` - Find locked accounts
- `Get-ADExpiredAccounts.ps1` - Find expired accounts
- `Get-ADInactiveComputers.ps1` - Find stale computers
- `Test-ADReplication.ps1` - Check replication status
- `Test-ADServices.ps1` - Verify AD services

### IIS
- `Test-IISService.ps1` - Check W3SVC service
- `Get-IISSiteStatus.ps1` - List IIS sites
- `Get-IISAppPoolStatus.ps1` - List app pools
- `Test-IISSite.ps1` - Test site via HTTP
- `Get-IISBindings.ps1` - List site bindings
- `Get-IISWorkerProcesses.ps1` - List w3wp processes
- `Get-IISErrorLogs.ps1` - Parse IIS error logs
- `Start-IISSite.ps1` / `Stop-IISSite.ps1` - Control sites
- `Recycle-IISAppPool.ps1` - Recycle app pools

### Disk Space
- `Get-DiskSpace.ps1` - Local disk info
- `Get-DiskSpaceRemote.ps1` - Remote disk info
- `Get-DiskSpaceThresholdReport.ps1` - Alert on threshold

### System Info
- `Get-SystemUptime.ps1` - Local uptime
- `Get-SystemUptimeRemote.ps1` - Remote uptime
- `Get-WindowsRoles.ps1` - List installed roles and features

### SQL
- `Get-DatabaseSchema.ps1` - Database schema
- `Get-TableSchema.ps1` - Table schema
- `Get-SQLData.ps1` - Execute queries
- `Get-ActiveConnections.ps1` - Active connections
- `Get-BlockedThreads.ps1` - Blocked processes
- `Backup-Database.ps1` - Create database backup
- `Get-DatabaseBackups.ps1` - List backup history
- `Restore-Database.ps1` - Restore from backup

### Network Monitoring
- `Get-PortStatus.ps1` - Check port availability
- `Get-ProcessOnPort.ps1` - Find process on port
- `Get-ListeningPorts.ps1` - List all listening ports
- `Test-SSLCertificate.ps1` - Test SSL certificate
- `Get-SSLCertificateRemote.ps1` - Get remote cert
- `Get-ExpiringCertificates.ps1` - Find expiring certs
- `Test-NetworkConnectivity.ps1` - Ping/port tests
- `Test-DNSResolution.ps1` - DNS lookup
- `Test-Traceroute.ps1` - Traceroute
- `Get-NetworkAdapterStatus.ps1` - List adapters
- `Get-FirewallRules.ps1` - List firewall rules
- `Get-GPOFirewallRules.ps1` - GPO-managed rules

### Data Transformation
- `ConvertTo-CsvFromJson.ps1` - JSON to CSV
- `ConvertTo-JsonFromCsv.ps1` - CSV to JSON
- `ConvertTo-XmlFromCsv.ps1` - CSV to XML
- `ConvertTo-CsvFromXml.ps1` - XML to CSV
- `ConvertTo-JsonFromXml.ps1` - XML to JSON
- `ConvertTo-XmlFromJson.ps1` - JSON to XML

### Scheduled Tasks
- `Get-ScheduledTask.ps1` - List tasks
- `New-ScheduledTask.ps1` - Create task
- `Remove-ScheduledTask.ps1` - Delete task
- `Enable-ScheduledTask.ps1` - Enable task
- `Disable-ScheduledTask.ps1` - Disable task
- `Get-ScheduledTaskHistory.ps1` - Task run history

### Baseline
- `New-ServerBaseline.ps1` - Record baseline snapshot
- `Get-ServerBaseline.ps1` - List stored baselines
- `Compare-Baseline.ps1` - Diff current vs baseline
- `Remove-ScheduledTask.ps1` - Delete baseline

### FTP
- `Send-FileToFtp.ps1` - Upload single file
- `Send-BatchToFtp.ps1` - Batch upload files
- `Get-FileFromFtp.ps1` - Download file
- `Get-FtpDirectory.ps1` - List directory contents
- `Test-FtpConnection.ps1` - Test FTP connection

### File System
- `Test-PathExists.ps1` - Test if path exists
- `Get-IsDirectory.ps1` - Check if path is directory
- `Get-FolderSize.ps1` - Get folder size
- `Get-FileDetails.ps1` - Get file details (with optional hash)
- `Get-DirectoryTree.ps1` - List directory structure
- `Find-LargeFiles.ps1` - Find large files
- `Get-FileHash.ps1` - Calculate file hash
- `Compare-FileHash.ps1` - Compare two file hashes
- `Get-FileAge.ps1` - Get file age information
- `Find-OldFiles.ps1` - Find old files
- `Get-DuplicateFiles.ps1` - Find duplicate files
- `Get-FileType.ps1` - Get file type information
- `Get-FilePermissions.ps1` - Get NTFS permissions
- `Copy-Robust.ps1` - Robust file copy using Robocopy

### Secrets
- `Install-SecretModules.ps1` - Install prerequisites
- `New-StoredCredential.ps1` - Create credential XML (DPAPI/AES)
- `Get-StoredCredential.ps1` - Load credential in scripts
- `New-EncryptedPassword.ps1` - Encrypt standalone password
- `Get-WindowsCredential.ps1` - Windows Credential Manager
- `Invoke-Vaultwarden.ps1` - Vaultwarden CLI wrapper
- `Invoke-AzureKeyVault.ps1` - Azure Key Vault integration
- `Get-Secret.ps1` - Unified secret retrieval

## License

MIT License
