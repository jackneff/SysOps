BeforeAll {
    $script:IISPath = "$PSScriptRoot\..\IIS"
}

Describe "IIS Scripts Tests" {
    Context "Test-IISService Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Test-IISService.ps1"
        }
        
        It "Should have Test-IISService.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Get-IISSiteStatus Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Get-IISSiteStatus.ps1"
        }
        
        It "Should have Get-IISSiteStatus.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Get-IISAppPoolStatus Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Get-IISAppPoolStatus.ps1"
        }
        
        It "Should have Get-IISAppPoolStatus.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Test-IISSite Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Test-IISSite.ps1"
        }
        
        It "Should have Test-IISSite.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept SiteName parameter" {
            { & $script:ScriptPath -SiteName "Default Web Site" } | Should -Not -Throw
        }
    }
    
    Context "Get-IISBindings Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Get-IISBindings.ps1"
        }
        
        It "Should have Get-IISBindings.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Get-IISWorkerProcesses Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Get-IISWorkerProcesses.ps1"
        }
        
        It "Should have Get-IISWorkerProcesses.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Get-IISErrorLogs Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Get-IISErrorLogs.ps1"
        }
        
        It "Should have Get-IISErrorLogs.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept LogPath parameter" {
            { & $script:ScriptPath -LogPath "C:\inetpub\logs\LogFiles" } | Should -Not -Throw
        }
    }
    
    Context "Start-IISSite Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Start-IISSite.ps1"
        }
        
        It "Should have Start-IISSite.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Name parameter" {
            { & $script:ScriptPath -Name "Default Web Site" } | Should -Not -Throw
        }
    }
    
    Context "Stop-IISSite Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Stop-IISSite.ps1"
        }
        
        It "Should have Stop-IISSite.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Name parameter" {
            { & $script:ScriptPath -Name "Default Web Site" } | Should -Not -Throw
        }
    }
    
    Context "Recycle-IISAppPool Script" {
        BeforeAll {
            $script:ScriptPath = "$script:IISPath\Recycle-IISAppPool.ps1"
        }
        
        It "Should have Recycle-IISAppPool.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Name parameter" {
            { & $script:ScriptPath -Name "DefaultAppPool" } | Should -Not -Throw
        }
    }
}
