# SQL Examples

This folder contains scripts for SQL Server administration.

## Get-DatabaseSchema.ps1

Get database schema.

```powershell
# Get schema for a database
.\Get-DatabaseSchema.ps1 -ServerName "SQLServer01" -DatabaseName "MyDatabase" -UseIntegratedSecurity
```

**Example Output:**
```
=== Database Schema: MyDatabase ===
TABLE_TYPE TABLE_NAME
---------- ----------
TABLE      Customers
TABLE      Orders
TABLE      OrderItems
VIEW       vw_CustomerOrders
PROCEDURE  sp_GetCustomerById
```

## Get-TableSchema.ps1

Get table schema.

```powershell
# Get schema for a specific table
.\Get-TableSchema.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -TableName "Customers" -UseIntegratedSecurity
```

**Example Output:**
```
=== Table Schema: Customers ===
COLUMN_NAME      DATA_TYPE  IS_NULLABLE IS_PRIMARY_KEY
-----------      ---------  ----------- --------------
CustomerId       int        NO          YES
CustomerName     nvarchar   NO          NO
Email            nvarchar   YES         NO
Phone           nvarchar   YES         NO
CreatedDate      datetime   NO          NO
```

## Get-SQLData.ps1

Execute a SELECT query.

```powershell
# Get data from a table
.\Get-SQLData.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -Query "SELECT TOP 10 * FROM Customers" -UseIntegratedSecurity

# Query with WHERE clause
.\Get-SQLData.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -Query "SELECT COUNT(*) AS Total FROM Orders WHERE OrderDate > '2024-01-01'" -UseIntegratedSecurity
```

## Get-ActiveConnections.ps1

List active database connections.

```powershell
# Get all active connections
.\Get-ActiveConnections.ps1 -ServerName "SQLServer01" -UseIntegratedSecurity

# Filter by database
.\Get-ActiveConnections.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -UseIntegratedSecurity
```

**Example Output:**
```
=== Active Connections on SQLServer01 ===
SPID LoginName    HostName   ProgramName              Status   DatabaseName
---- ---------    --------   -----------              ------   ------------
55   sa          DEV01      SSMS                     Running  MyDB
56   domain\user DEV02      Application Pool         Idle     Master
```

## Get-BlockedThreads.ps1

List blocked processes.

```powershell
.\Get-BlockedThreads.ps1 -ServerName "SQLServer01" -UseIntegratedSecurity
```

**Example Output:**
```
=== Blocked Processes on SQLServer01 ===
BlockedSPID BlockingSPID BlockedLogin BlockingHost WaitResource
----------- ------------ ------------ ------------ -------------
65          42           sa           APP01       KEY: 5:281...
```

## Backup-Database.ps1

Create database backup.

```powershell
# Full backup
.\Backup-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -BackupPath "C:\Backups"

# Differential backup
.\Backup-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -BackupPath "C:\Backups" -BackupType Differential

# Log backup
.\Backup-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -BackupPath "C:\Backups" -BackupType Log
```

**Example Output:**
```
Starting full backup of 'MyDB' to C:\Backups\MyDB_Full_20240115_143000.bak
Backup completed successfully!
Backup file: C:\Backups\MyDB_Full_20240115_143000.bak
Backup size: 1024.50 MB
```

## Get-DatabaseBackups.ps1

List backup history.

```powershell
# List all backups
.\Get-DatabaseBackups.ps1 -ServerName "SQLServer01"

# List backups for specific database
.\Get-DatabaseBackups.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -Days 30
```

**Example Output:**
```
=== Database Backups ===
DatabaseName BackupStartDate         BackupSizeMB BackupTypeDescription
------------ -----------------         ------------ --------------------
MyDB         2024-01-15 14:30:00    1024.50      Full
MyDB         2024-01-15 10:00:00    256.30       Differential
MyDB         2024-01-15 06:00:00    512.00       Log
```

## Restore-Database.ps1

Restore database from backup.

```powershell
# Restore database
.\Restore-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB_Restored" -BackupFilePath "C:\Backups\MyDB_Full_20240115_143000.bak"

# Restore with recovery (make available immediately)
.\Restore-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB_Restored" -BackupFilePath "C:\Backups\MyDB_Full_20240115_143000.bak" -WithRecovery

# Restore and replace existing
.\Restore-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -BackupFilePath "C:\Backups\MyDB_Full_20240115_143000.bak" -Replace
```

**Example Output:**
```
Starting full restore of 'MyDB_Restored'
Backup file: C:\Backups\MyDB_Full_20240115_143000.bak
Restore completed successfully!

Database Status:
ServerName      : SQLServer01
DatabaseName    : MyDB_Restored
State           : ONLINE
RecoveryModel   : FULL
```
