# FTP Examples

This folder contains scripts for FTP/SFTP file transfers using WinSCP.

**Prerequisites:**
- WinSCP installed at `$env:ProgramFiles (x86)\WinSCP\`
- WinSCP .NET assembly (`WinSCPnet.dll`)

## Test-FtpConnection.ps1

Test FTP/SFTP connection.

```powershell
# Test FTP connection
.\Test-FtpConnection.ps1 -SessionUrl "ftp://user:password@ftp.example.com"

# Test SFTP connection
.\Test-FtpConnection.ps1 -SessionUrl "sftp://user:password@sftp.example.com"

# With custom timeout
.\Test-FtpConnection.ps1 -SessionUrl "sftp://user:password@sftp.example.com" -TimeoutSeconds 60
```

**Example Output:**
```
Connection successful!
Protocol: Sftp
True
```

## Send-FileToFtp.ps1

Upload a single file.

```powershell
# Upload file
.\Send-FileToFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -LocalPath "C:\data\file.txt" -RemotePath "/upload/"

# Upload to SFTP
.\Send-FileToFtp.ps1 -SessionUrl "sftp://user:password@sftp.example.com" -LocalPath "C:\backup.zip" -RemotePath "/backups/"
```

**Example Output:**
```
Uploaded: C:\data\file.txt
```

## Send-BatchToFtp.ps1

Batch upload multiple files.

```powershell
# Upload all files from folder
.\Send-BatchToFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -LocalPath "C:\uploads\*" -RemotePath "/upload/"

# Upload and remove source files
.\Send-BatchToFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -LocalPath "C:\uploads\*" -RemotePath "/archive/" -RemoveSource
```

**Example Output:**
```
Uploading files from: C:\uploads\*
To: /upload/
[OK] file1.txt
[OK] file2.txt
[OK] data.csv

Transfer Summary:
  Successful: 3
  Failed: 0
```

## Get-FileFromFtp.ps1

Download a file.

```powershell
# Download file
.\Get-FileFromFtp.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -RemotePath "/downloads/file.txt" -LocalPath "C:\temp\"

# Download from SFTP
.\Get-FileFromFtp.ps1 -SessionUrl "sftp://user:password@sftp.example.com" -RemotePath "/backups/backup.zip" -LocalPath "C:\restores\"
```

**Example Output:**
```
Downloaded: /downloads/file.txt
```

## Get-FtpDirectory.ps1

List directory contents.

```powershell
# List root directory
.\Get-FtpDirectory.ps1 -SessionUrl "ftp://user:password@ftp.example.com" -RemotePath "/"

# List specific folder
.\Get-FtpDirectory.ps1 -SessionUrl "sftp://user:password@sftp.example.com" -RemotePath "/backups/"
```

**Example Output:**
```
=== FTP Directory ===
Name           IsDirectory Length    LastModified          Permissions
----           ----------- ------    -------------          -----------
backups        True         0         2024-01-15 14:30:00  drwxr-xr-x
documents      True         0         2024-01-14 09:00:00  drwxr-xr-x
file.txt       False        1024      2024-01-15 16:00:00  -rw-r--r--
report.csv     False        4096      2024-01-14 12:00:00  -rw-r--r--
```

## Session URL Formats

WinSCP supports various protocols:

```powershell
# FTP (plain)
"ftp://username:password@ftp.example.com"

# FTPS (explicit TLS)
"ftps://username:password@ftp.example.com"

# SFTP (SSH)
"sftp://username:password@sftp.example.com"

# SCP
"scp://username:password@scp.example.com"
```

## Tips

- Store credentials securely using Windows Credential Manager
- Use SFTP for secure transfers
- Configure passive mode for FTP if behind firewall
- Use batch upload for multiple files (faster)
