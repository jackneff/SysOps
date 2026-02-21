BeforeAll {
    $script:SystemInfoPath = "$PSScriptRoot\..\SystemInfo"
}

Describe "Get-SystemUptime Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:SystemInfoPath\Get-SystemUptime.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-SystemUptime.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
        
        It "Should have default ComputerName as localhost" {
            { & $script:ScriptPath } | Should -Not -Throw
        }
    }
    
    Context "Execution" {
        It "Should return uptime information" {
            $result = & $script:ScriptPath
            $result | Should -Not -BeNullOrEmpty
            $result.ComputerName | Should -Not -BeNullOrEmpty
            $result.LastBootTime | Should -BeOfType [System.DateTime]
            $result.UptimeDays | Should -BeOfType [System.Int32]
        }
        
        It "Should return valid UptimeString" {
            $result = & $script:ScriptPath
            $result.UptimeString | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Get-SystemUptimeRemote Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:SystemInfoPath\Get-SystemUptimeRemote.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-SystemUptimeRemote.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
}

Describe "Get-WindowsRoles Script Tests" {
    BeforeAll {
        $script:ScriptPath = "$script:SystemInfoPath\Get-WindowsRoles.ps1"
    }
    
    Context "Script Existence" {
        It "Should have Get-WindowsRoles.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
}
