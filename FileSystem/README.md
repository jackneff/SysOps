# File System Examples

This folder contains scripts for file system operations.

## Test-PathExists.ps1

Test if path exists.

```powershell
.\Test-PathExists.ps1 -Path "C:\Logs"
```

**Example Output:**
```
Path exists: C:\Logs
Path      : C:\Logs
Exists    : True
IsFile    : False
IsDirectory : True
```

## Get-IsDirectory.ps1

Check if path is directory.

```powershell
.\Get-IsDirectory.ps1 -Path "C:\Windows"
.\Get-IsDirectory.ps1 -Path "C:\pagefile.sys"
```

**Example Output:**
```
C:\Windows is a directory

Path        : C:\Windows
Name        : Windows
IsDirectory : True
IsFile      : False
FullName    : C:\Windows
```

## Get-FolderSize.ps1

Get folder size.

```powershell
.\Get-FolderSize.ps1 -Path "C:\Logs"

# Include hidden files
.\Get-FolderSize.ps1 -Path "C:\Logs" -IncludeHidden
```

**Example Output:**
```
Calculating folder size: C:\Logs

Folder Size Report:

Path           : C:\Logs
TotalBytes     : 5368709120
TotalGB        : 5.00
TotalMB        : 5120.00
FileCount      : 1523
FolderCount    : 12
```

## Get-FileDetails.ps1

Get file details.

```powershell
.\Get-FileDetails.ps1 -Path "C:\file.zip"

# Include hash
.\Get-FileDetails.ps1 -Path "C:\file.zip" -IncludeHash
```

**Example Output:**
```
File Details:

Name          : file.zip
FullName      : C:\file.zip
Extension     : .zip
SizeBytes     : 104857600
SizeMB        : 100.00
CreatedTime   : 2024-01-15 10:00:00
ModifiedTime  : 2024-01-15 14:30:00
IsReadOnly    : False
Attributes    : Archive
MD5Hash       : A1B2C3D4E5F6...
SHA256Hash    : 1234567890ABCDEF...
```

## Get-DirectoryTree.ps1

Show directory structure.

```powershell
.\Get-DirectoryTree.ps1 -Path "C:\MyApp"

# Show files with 2 levels deep
.\Get-DirectoryTree.ps1 -Path "C:\MyApp" -Depth 2 -ShowFiles
```

**Example Output:**
```
Directory Tree: C:\MyApp
Depth: 3

C:\MyApp/
├── config/
│   ├── app.config
│   └── web.config
├── data/
│   └── backups/
├── src/
│   └── ...
└── logs/
```

## Find-LargeFiles.ps1

Find large files.

```powershell
# Find files over 500MB
.\Find-LargeFiles.ps1 -Path "C:\" -MinimumSizeMB 500 -Top 10
```

**Example Output:**
```
Searching for files larger than 500 MB in C:\...

Largest Files:

Name          FullPath                          SizeMB   Modified
----          ---------                         ------   --------
pagefile.sys  C:\pagefile.sys                  32768.00 2024-01-01
hiberfil.sys  C:\hiberfil.sys                   8192.00  2024-01-01
backup.zip    D:\Backups\backup.zip             2048.00  2024-01-14
```

## Get-FileHash.ps1

Calculate file hash.

```powershell
.\Get-FileHash.ps1 -Path "C:\file.zip" -Algorithm SHA256
```

**Example Output:**
```
Calculating SHA256 hash for: C:\file.zip

File Hash:

Path      : C:\file.zip
Name      : file.zip
Algorithm : SHA256
Hash      : A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6...
```

## Compare-FileHash.ps1

Compare two files.

```powershell
.\Compare-FileHash.ps1 -Path1 "C:\file1.zip" -Path2 "D:\backup.zip"
```

**Example Output:**
```
Calculating SHA256 hashes...

Hash Comparison:

File1        : C:\file1.zip
File2        : D:\backup.zip
Algorithm    : SHA256
Hash1        : A1B2C3...
Hash2        : A1B2C3...
Match        : True

Files match!
```

## Get-FileAge.ps1

Get file age.

```powershell
.\Get-FileAge.ps1 -Path "C:\oldfile.dat"
```

**Example Output:**
```
File Age Information:

Path               : C:\oldfile.dat
Name               : oldfile.dat
CreatedTime        : 2023-06-15 10:00:00
CreatedAge         : 1 year(s), 7 month(s)
CreatedDaysAgo     : 580
ModifiedTime      : 2023-12-01 14:30:00
ModifiedAge       : 1 month(s), 15 day(s)
ModifiedDaysAgo   : 45
```

## Find-OldFiles.ps1

Find old files.

```powershell
# Find files not modified in 180 days
.\Find-OldFiles.ps1 -Path "C:\Temp" -DaysOld 180 -Top 20
```

**Example Output:**
```
Searching for files older than 180 days in C:\Temp...

Old Files (Top 20):

Name         FullPath                    SizeMB   LastModified   DaysOld
----         ---------                    ------   -------------   -------
old1.txt     C:\Temp\old1.txt           0.01     2023-06-01     228
old2.log     C:\Temp\old2.log           10.50    2023-05-15     245
```

## Get-DuplicateFiles.ps1

Find duplicate files.

```powershell
.\Get-DuplicateFiles.ps1 -Path "C:\Duplicates" -MinimumSizeKB 100
```

**Example Output:**
```
Finding duplicate files in C:\Duplicates...
Checking 150 files...

Found 3 duplicate files:

OriginalFile              DuplicateFile               SizeMB Hash
------------              --------------              ------ ----
C:\Duplicates\file1.doc   C:\Duplicates\Copy.doc     5.20  A1B2C3...
C:\Duplicates\file2.zip   C:\Duplicates\backup.zip   102.00 D4E5F6...
```

## Get-FileType.ps1

Get file type.

```powershell
.\Get-FileType.ps1 -Path "C:\document.pdf"
```

**Example Output:**
```
File Type Information:

Path         : C:\document.pdf
Name         : document.pdf
Extension    : .pdf
FileType     : PDF Document
SizeBytes    : 1048576
SizeKB       : 1024.00
SizeMB       : 1.00
IsReadOnly   : False
Attributes   : Normal
```

## Get-FilePermissions.ps1

Get NTFS permissions.

```powershell
.\Get-FilePermissions.ps1 -Path "C:\Shared"
```

**Example Output:**
```
Retrieving permissions for: C:\Shared

Permissions:

IdentityReference      FileSystemRights         AccessControlType IsInherited
--------------------   --------------------     ----------------- ------------
BUILTIN\Administrators FullControl              Allow             True
NT AUTHORITY\SYSTEM    FullControl              Allow             True
DOMAIN\Users          ReadAndExecute            Allow             True
DOMAIN\Finance        Modify                    Allow             False
```

## Copy-Robust.ps1

Robust file copy using Robocopy.

```powershell
# Basic copy
.\Copy-Robust.ps1 -SourcePath "C:\Data" -DestinationPath "D:\Backup\Data" -Subfolders

# Mirror copy
.\Copy-Robust.ps1 -SourcePath "C:\Data" -DestinationPath "D:\Backup\Data" -Mirror

# With retries
.\Copy-Robust.ps1 -SourcePath "C:\LargeData" -DestinationPath "\\Server\Share" -Subfolders -RetryCount 5 -RetryWaitSeconds 60

# With exclusions
.\Copy-Robust.ps1 -SourcePath "C:\Data" -DestinationPath "D:\Backup" -Subfolders -ExcludeFiles "*.tmp","*.log" -ExcludeFolders "temp","cache"
```

**Example Output:**
```
=== Robust File Copy ===
Source:      C:\Data
Destination: D:\Backup\Data
Log:         D:\Backup\Data\Robocopy_20240115_143000.log
Retries:     3 (wait 30 seconds)

Starting copy (Attempt 1)...
Copy completed successfully!

SourceSizeMB    : 10240.00
DestSizeMB      : 10240.00
Verified        : True
```
