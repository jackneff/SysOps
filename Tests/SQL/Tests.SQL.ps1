BeforeAll {
    $script:SQLPath = "$PSScriptRoot\..\SQL"
}

Describe "SQL Scripts Tests" {
    Context "Get-SQLData Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Get-SQLData.ps1"
        }
        
        It "Should have Get-SQLData.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -Query "SELECT 1" } | Should -Not -Throw
        }
        
        It "Should accept Query parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -Query "SELECT 1" } | Should -Not -Throw
        }
        
        It "Should accept Database parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -Database "master" -Query "SELECT 1" } | Should -Not -Throw
        }
    }
    
    Context "Get-DatabaseSchema Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Get-DatabaseSchema.ps1"
        }
        
        It "Should have Get-DatabaseSchema.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" } | Should -Not -Throw
        }
        
        It "Should accept Database parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -Database "master" } | Should -Not -Throw
        }
    }
    
    Context "Get-TableSchema Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Get-TableSchema.ps1"
        }
        
        It "Should have Get-TableSchema.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -TableName "sys.tables" } | Should -Not -Throw
        }
    }
    
    Context "Get-ActiveConnections Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Get-ActiveConnections.ps1"
        }
        
        It "Should have Get-ActiveConnections.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Get-BlockedThreads Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Get-BlockedThreads.ps1"
        }
        
        It "Should have Get-BlockedThreads.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Backup-Database Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Backup-Database.ps1"
        }
        
        It "Should have Backup-Database.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -Database "master" -BackupPath "C:\Backup" } | Should -Not -Throw
        }
    }
    
    Context "Get-DatabaseBackups Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Get-DatabaseBackups.ps1"
        }
        
        It "Should have Get-DatabaseBackups.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Restore-Database Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SQLPath\Restore-Database.ps1"
        }
        
        It "Should have Restore-Database.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ServerInstance parameter" {
            { & $script:ScriptPath -ServerInstance "localhost" -Database "master" -BackupFile "C:\Backup\db.bak" } | Should -Not -Throw
        }
    }
}
