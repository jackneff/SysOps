$script:DiskSpacePath = "C:\jack\dev\SysOps\DiskSpace"

Describe "Get-DiskSpace Script Tests" {
    $script:ScriptPath = "$script:DiskSpacePath\Get-DiskSpace.ps1"
    
    Context "Script Existence" {
        It "Should have Get-DiskSpace.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should have default ComputerName as localhost" {
            { & $script:ScriptPath } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            $result = & $script:ScriptPath
            $result | Should Not BeNullOrEmpty
        }
        
        It "Should return disk information" {
            $result = & $script:ScriptPath
            $result[0].ComputerName | Should Not BeNullOrEmpty
            $result[0].Drive | Should Not BeNullOrEmpty
            $result[0].UsedGB | Should Not BeNullOrEmpty
            $result[0].FreeGB | Should Not BeNullOrEmpty
            $result[0].TotalGB | Should Not BeNullOrEmpty
            $result[0].PercentUsed | Should Not BeNullOrEmpty
        }
    }
}

$script:ScriptPath = "$script:DiskSpacePath\Get-DiskSpaceRemote.ps1"

Describe "Get-DiskSpaceRemote Script Tests" {
    Context "Script Existence" {
        It "Should have Get-DiskSpaceRemote.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
    }
}

$script:ScriptPath = "$script:DiskSpacePath\Get-DiskSpaceThresholdReport.ps1"

Describe "Get-DiskSpaceThresholdReport Script Tests" {
    Context "Script Existence" {
        It "Should have Get-DiskSpaceThresholdReport.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept ThresholdPercent parameter" {
            { & $script:ScriptPath -ThresholdPercent 80 } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute with threshold" {
            { & $script:ScriptPath -ComputerName "localhost" -ThresholdPercent 80 } | Should Not Throw
        }
    }
}
