# Disk Space Examples

This folder contains scripts for monitoring disk space.

## Get-DiskSpace.ps1

Get disk space information.

```powershell
# Check local server
.\Get-DiskSpace.ps1

# Check remote server
.\Get-DiskSpace.ps1 -ComputerName "Server01"
```

**Example Output:**
```
=== Disk Space ===

ComputerName Drive UsedGB FreeGB TotalGB PercentUsed
------------ ----- ------- ------ ------- -----------
localhost   C     180.50  75.50  256.00  70.5
localhost   D     500.00  500.00 1000.00 50.0
```

## Get-DiskSpaceRemote.ps1

Get disk space from multiple remote servers.

```powershell
# Check multiple servers
.\Get-DiskSpaceRemote.ps1 -ComputerName "Server01","Server02","Server03"

# Use servers from config
.\Get-DiskSpaceRemote.ps1 -ComputerName $config.Servers
```

**Example Output:**
```
Checking: Server01
Checking: Server02
Checking: Server03

ComputerName Drive UsedGB FreeGB TotalGB PercentUsed
------------ ----- ------- ------ ------- -----------
Server01    C     180.50  75.50  256.00  70.5
Server01    D     500.00  500.00 1000.00 50.0
Server02    C     220.00  36.00  256.00  85.9
Server02    D     100.00  900.00 1000.00 10.0
Server03    C     50.00   206.00 256.00  19.5
Server03    D     0.00    500.00 500.00  0.0
```

## Get-DiskSpaceThresholdReport.ps1

Get disk space with threshold alerts.

```powershell
# Alert when drives above 80%
.\Get-DiskSpaceThresholdReport.ps1 -ComputerName "Server01" -ThresholdPercent 80

# Alert when drives above 90%
.\Get-DiskSpaceThresholdReport.ps1 -ComputerName "Server01","Server02" -ThresholdPercent 90
```

**Example Output:**
```
=== All Drives ===

ComputerName Drive UsedGB FreeGB TotalGB PercentUsed
------------ ----- ------- ------ ------- -----------
Server01    C     180.50  75.50  256.00  70.5
Server01    D     500.00  500.00 1000.00 50.0
Server02    C     220.00  36.00  256.00  85.9
Server02    D     100.00  900.00 1000.00 10.0

=== Drives Above Threshold (80%) ===

ComputerName Drive UsedGB FreeGB TotalGB PercentUsed
------------ ----- ------- ------ ------- -----------
Server02    C     220.00  36.00  256.00  85.9
```
