BeforeAll {
    $script:FTPPath = "$PSScriptRoot\..\FTP"
}

Describe "FTP Scripts Tests" {
    Context "Test-FtpConnection Script" {
        BeforeAll {
            $script:ScriptPath = "$script:FTPPath\Test-FtpConnection.ps1"
        }
        
        It "Should have Test-FtpConnection.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Server parameter" {
            { & $script:ScriptPath -Server "ftp.example.com" } | Should -Not -Throw
        }
        
        It "Should accept Username parameter" {
            { & $script:ScriptPath -Server "ftp.example.com" -Username "anonymous" } | Should -Not -Throw
        }
    }
    
    Context "Send-FileToFtp Script" {
        BeforeAll {
            $script:ScriptPath = "$script:FTPPath\Send-FileToFtp.ps1"
        }
        
        It "Should have Send-FileToFtp.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept LocalFile parameter" {
            { & $script:ScriptPath -LocalFile "test.txt" } | Should -Not -Throw
        }
        
        It "Should accept RemotePath parameter" {
            { & $script:ScriptPath -LocalFile "test.txt" -RemotePath "/" } | Should -Not -Throw
        }
    }
    
    Context "Get-FileFromFtp Script" {
        BeforeAll {
            $script:ScriptPath = "$script:FTPPath\Get-FileFromFtp.ps1"
        }
        
        It "Should have Get-FileFromFtp.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept RemoteFile parameter" {
            { & $script:ScriptPath -RemoteFile "test.txt" } | Should -Not -Throw
        }
        
        It "Should accept LocalPath parameter" {
            { & $script:ScriptPath -RemoteFile "test.txt" -LocalPath "C:\Temp" } | Should -Not -Throw
        }
    }
    
    Context "Get-FtpDirectory Script" {
        BeforeAll {
            $script:ScriptPath = "$script:FTPPath\Get-FtpDirectory.ps1"
        }
        
        It "Should have Get-FtpDirectory.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "/" } | Should -Not -Throw
        }
    }
    
    Context "Send-BatchToFtp Script" {
        BeforeAll {
            $script:ScriptPath = "$script:FTPPath\Send-BatchToFtp.ps1"
        }
        
        It "Should have Send-BatchToFtp.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept SourceFolder parameter" {
            { & $script:ScriptPath -SourceFolder "C:\Temp" } | Should -Not -Throw
        }
        
        It "Should accept DestinationFolder parameter" {
            { & $script:ScriptPath -SourceFolder "C:\Temp" -DestinationFolder "/upload" } | Should -Not -Throw
        }
    }
}
