# Baseline Examples

This folder contains scripts for creating and comparing server baselines.

## New-ServerBaseline.ps1

Record a baseline snapshot of a server.

```powershell
# Create baseline for a server
.\New-ServerBaseline.ps1 -ComputerName "Server01"

# Use config baseline path
.\New-ServerBaseline.ps1 -ComputerName "Server01" -UseConfig

# Create baseline for multiple servers
.\New-ServerBaseline.ps1 -ComputerName "WebServer01"
.\New-ServerBaseline.ps1 -ComputerName "SQLServer01"
```

**Example Output:**
```
Recording baseline for: Server01
  - Checking services...
  - Checking ports...
  - Checking disk space...
  - Checking uptime...
  - Checking certificates...
  - Checking IIS...

Baseline saved to: C:\Scripts\Baselines\Server01-20240115-143000.json
```

## Get-ServerBaseline.ps1

List stored baselines.

```powershell
# List all baselines
.\Get-ServerBaseline.ps1

# Filter by computer name
.\Get-ServerBaseline.ps1 -ComputerName "Server01"
```

**Example Output:**
```
=== Available Baselines ===
ComputerName Timestamp            FilePath
------------ ---------            --------
Server01     2024-01-15 14:30:00  C:\Scripts\Baselines\Server01-20240115-143000.json
Server01     2024-01-10 09:15:00  C:\Scripts\Baselines\Server01-20240110-091500.json
WebServer01  2024-01-14 16:00:00  C:\Scripts\Baselines\WebServer01-20240114-160000.json
```

## Compare-Baseline.ps1

Compare current server state to baseline.

```powershell
# Compare to latest baseline
.\Compare-Baseline.ps1 -ComputerName "Server01"

# Compare to specific baseline
.\Compare-Baseline.ps1 -ComputerName "Server01" -BaselineFile "C:\Scripts\Baselines\Server01-20240110-091500.json"
```

**Example Output (when everything matches):**
```
Loading baseline: C:\Scripts\Baselines\Server01-20240115-143000.json
Recording current state...

=== Comparing Current State vs Baseline ===
Baseline: 2024-01-15 14:30:00
Current:  2024-01-15 16:00:00

=== Comparison Complete ===
```

**Example Output (when changes detected):**
```
--- Service Changes ---
  W3SVC: Running -> Stopped

--- New Ports ---
  New Port: 8080 (java)

--- Removed Ports ---
  Removed Port: 3306 (mysqld)

=== Comparison Complete ===
```

## Remove-ServerBaseline.ps1

Delete stored baselines.

```powershell
# Delete all baselines for a server
.\Remove-ServerBaseline.ps1 -ComputerName "Server01"

# Confirm deletion
.\Remove-ServerBaseline.ps1 -ComputerName "Server01" -Confirm
```

**Example Output:**
```
Found 2 baseline(s):

Name                                    LastWriteTime
----                                    -------------
Server01-20240115-143000.json           1/15/2024 2:30:00 PM
Server01-20240110-091500.json           1/10/2024 9:15:00 AM

Delete these 2 baseline(s)? (Y/N): Y
Deleted: Server01-20240115-143000.json
Deleted: Server01-20240110-091500.json
```

## Usage Workflow

1. **Create baseline when server is healthy:**
   ```powershell
   .\New-ServerBaseline.ps1 -ComputerName "Server01"
   ```

2. **When issues occur, compare current state:**
   ```powershell
   .\Compare-Baseline.ps1 -ComputerName "Server01"
   ```

3. **Review changes to identify the problem:**
   - Stopped services
   - New/removed ports
   - Disk space changes
   - Certificate changes
   - IIS site/app pool changes
