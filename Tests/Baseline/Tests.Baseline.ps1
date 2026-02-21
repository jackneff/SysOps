BeforeAll {
    $script:BaselinePath = "$PSScriptRoot\..\Baseline"
}

Describe "Baseline Scripts Tests" {
    Context "New-ServerBaseline Script" {
        BeforeAll {
            $script:ScriptPath = "$script:BaselinePath\New-ServerBaseline.ps1"
        }
        
        It "Should have New-ServerBaseline.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
        
        It "Should accept OutputPath parameter" {
            { & $script:ScriptPath -ComputerName "localhost" -OutputPath "$TestDrive\baseline.json" } | Should -Not -Throw
        }
    }
    
    Context "Get-ServerBaseline Script" {
        BeforeAll {
            $script:ScriptPath = "$script:BaselinePath\Get-ServerBaseline.ps1"
        }
        
        It "Should have Get-ServerBaseline.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Compare-Baseline Script" {
        BeforeAll {
            $script:ScriptPath = "$script:BaselinePath\Compare-Baseline.ps1"
        }
        
        It "Should have Compare-Baseline.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Remove-ServerBaseline Script" {
        BeforeAll {
            $script:ScriptPath = "$script:BaselinePath\Remove-ServerBaseline.ps1"
        }
        
        It "Should have Remove-ServerBaseline.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
}
