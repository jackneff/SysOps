BeforeAll {
    $script:ADPath = "$PSScriptRoot\..\AD"
}

Describe "Active Directory Scripts Tests" {
    Context "Get-ADUser Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADUser.ps1"
        }
        
        It "Should have Get-ADUser.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Identity parameter" {
            { & $script:ScriptPath -Identity "administrator" } | Should -Not -Throw
        }
    }
    
    Context "Get-ADGroup Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADGroup.ps1"
        }
        
        It "Should have Get-ADGroup.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Identity parameter" {
            { & $script:ScriptPath -Identity "Domain Admins" } | Should -Not -Throw
        }
    }
    
    Context "Get-ADComputer Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADComputer.ps1"
        }
        
        It "Should have Get-ADComputer.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Identity parameter" {
            { & $script:ScriptPath -Identity "localhost" } | Should -Not -Throw
        }
    }
    
    Context "Get-ADUserGroups Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADUserGroups.ps1"
        }
        
        It "Should have Get-ADUserGroups.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Identity parameter" {
            { & $script:ScriptPath -Identity "administrator" } | Should -Not -Throw
        }
    }
    
    Context "Get-ADLockedAccounts Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADLockedAccounts.ps1"
        }
        
        It "Should have Get-ADLockedAccounts.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Get-ADExpiredAccounts Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADExpiredAccounts.ps1"
        }
        
        It "Should have Get-ADExpiredAccounts.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Get-ADInactiveComputers Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Get-ADInactiveComputers.ps1"
        }
        
        It "Should have Get-ADInactiveComputers.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept DaysInactive parameter" {
            { & $script:ScriptPath -DaysInactive 90 } | Should -Not -Throw
        }
    }
    
    Context "Test-ADReplication Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Test-ADReplication.ps1"
        }
        
        It "Should have Test-ADReplication.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
    
    Context "Test-ADServices Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ADPath\Test-ADServices.ps1"
        }
        
        It "Should have Test-ADServices.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
}
