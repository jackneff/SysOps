BeforeAll {
    $script:FileSystemPath = "$PSScriptRoot\..\FileSystem"
    $script:TestDirectory = $TestDrive
}

Describe "Test-PathExists Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Test-PathExists.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Test-PathExists.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "C:\" } | Should -Not -Throw
        }
    }
    
    Context "Execution" {
        It "Should return true for existing path" {
            $result = & $script:ScriptPath -Path "C:\"
            $result.Exists | Should -Be $true
        }
        
        It "Should return false for non-existing path" {
            $result = & $script:ScriptPath -Path "C:\NonExistentPath12345"
            $result.Exists | Should -Be $false
        }
    }
}

Describe "Get-IsDirectory Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Get-IsDirectory.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-IsDirectory.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Execution" {
        It "Should return true for directory" {
            $result = & $script:ScriptPath -Path "C:\Windows"
            $result.IsDirectory | Should -Be $true
        }
        
        It "Should return false for file" {
            $result = & $script:ScriptPath -Path "C:\Windows\notepad.exe"
            $result.IsDirectory | Should -Be $false
        }
    }
}

Describe "Find-LargeFiles Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Find-LargeFiles.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Find-LargeFiles.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "C:\Windows\System32" } | Should -Not -Throw
        }
        
        It "Should accept MinimumSizeMB parameter" {
            { & $script:ScriptPath -Path "C:\Windows\System32" -MinimumSizeMB 50 } | Should -Not -Throw
        }
        
        It "Should accept Top parameter" {
            { & $script:ScriptPath -Path "C:\Windows\System32" -Top 10 } | Should -Not -Throw
        }
    }
    
    Context "Execution" {
        It "Should execute on System32 folder" {
            $result = & $script:ScriptPath -Path "C:\Windows\System32" -MinimumSizeMB 1 -Top 5
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should return files with size properties" {
            $result = & $script:ScriptPath -Path "C:\Windows\System32" -MinimumSizeMB 1 -Top 1
            $result[0].SizeMB | Should -BeGreaterThan 0
        }
    }
}

Describe "Find-OldFiles Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Find-OldFiles.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Find-OldFiles.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "C:\Windows\System32" } | Should -Not -Throw
        }
        
        It "Should accept DaysOld parameter" {
            { & $script:ScriptPath -Path "C:\Windows\System32" -DaysOld 365 } | Should -Not -Throw
        }
    }
}

Describe "Get-FileHash Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Get-FileHash.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-FileHash.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "C:\Windows\notepad.exe" } | Should -Not -Throw
        }
        
        It "Should accept Algorithm parameter" {
            { & $script:ScriptPath -Path "C:\Windows\notepad.exe" -Algorithm "SHA256" } | Should -Not -Throw
        }
    }
    
    Context "Execution" {
        It "Should compute file hash" {
            $result = & $script:ScriptPath -Path "C:\Windows\notepad.exe"
            $result.Hash | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Get-FolderSize Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Get-FolderSize.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-FolderSize.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "C:\Windows\System32" } | Should -Not -Throw
        }
    }
}

Describe "Get-DirectoryTree Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Get-DirectoryTree.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-DirectoryTree.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Path parameter" {
            { & $script:ScriptPath -Path "C:\Windows" } | Should -Not -Throw
        }
        
        It "Should accept Depth parameter" {
            { & $script:ScriptPath -Path "C:\Windows" -Depth 2 } | Should -Not -Throw
        }
    }
}

Describe "Copy-Robust Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:FileSystemPath\Copy-Robust.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Copy-Robust.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept SourcePath parameter" {
            { & $script:ScriptPath -SourcePath "C:\Windows\System32\notepad.exe" -DestinationPath "$TestDrive\test" } | Should -Not -Throw
        }
    }
}
