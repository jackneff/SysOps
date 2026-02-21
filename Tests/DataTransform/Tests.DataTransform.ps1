BeforeAll {
    $script:DataTransformPath = "$PSScriptRoot\..\DataTransform"
    $script:TestDataPath = "$TestDrive"
}

Describe "DataTransform Scripts Tests" {
    Context "ConvertTo-JsonFromCsv Script" {
        BeforeAll {
            $script:ScriptPath = "$script:DataTransformPath\ConvertTo-JsonFromCsv.ps1"
        }
        
        It "Should have ConvertTo-JsonFromCsv.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept InputFile parameter" {
            { & $script:ScriptPath -InputFile "test.csv" -OutputFile "test.json" } | Should -Not -Throw
        }
        
        It "Should accept OutputFile parameter" {
            { & $script:ScriptPath -InputFile "test.csv" -OutputFile "test.json" } | Should -Not -Throw
        }
        
        It "Should throw for non-existent input file" {
            { & $script:ScriptPath -InputFile "C:\NonExistent.csv" -OutputFile "test.json" } | Should -Throw
        }
    }
    
    Context "ConvertTo-CsvFromJson Script" {
        BeforeAll {
            $script:ScriptPath = "$script:DataTransformPath\ConvertTo-CsvFromJson.ps1"
        }
        
        It "Should have ConvertTo-CsvFromJson.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept InputFile parameter" {
            { & $script:ScriptPath -InputFile "test.json" -OutputFile "test.csv" } | Should -Not -Throw
        }
    }
    
    Context "ConvertTo-XmlFromJson Script" {
        BeforeAll {
            $script:ScriptPath = "$script:DataTransformPath\ConvertTo-XmlFromJson.ps1"
        }
        
        It "Should have ConvertTo-XmlFromJson.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept InputFile parameter" {
            { & $script:ScriptPath -InputFile "test.json" -OutputFile "test.xml" } | Should -Not -Throw
        }
    }
    
    Context "ConvertTo-JsonFromXml Script" {
        BeforeAll {
            $script:ScriptPath = "$script:DataTransformPath\ConvertTo-JsonFromXml.ps1"
        }
        
        It "Should have ConvertTo-JsonFromXml.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept InputFile parameter" {
            { & $script:ScriptPath -InputFile "test.xml" -OutputFile "test.json" } | Should -Not -Throw
        }
    }
    
    Context "ConvertTo-XmlFromCsv Script" {
        BeforeAll {
            $script:ScriptPath = "$script:DataTransformPath\ConvertTo-XmlFromCsv.ps1"
        }
        
        It "Should have ConvertTo-XmlFromCsv.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept InputFile parameter" {
            { & $script:ScriptPath -InputFile "test.csv" -OutputFile "test.xml" } | Should -Not -Throw
        }
    }
    
    Context "ConvertTo-CsvFromXml Script" {
        BeforeAll {
            $script:ScriptPath = "$script:DataTransformPath\ConvertTo-CsvFromXml.ps1"
        }
        
        It "Should have ConvertTo-CsvFromXml.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept InputFile parameter" {
            { & $script:ScriptPath -InputFile "test.xml" -OutputFile "test.csv" } | Should -Not -Throw
        }
    }
}

Describe "DataTransform Integration Tests" {
    BeforeAll {
        $script:TestCsvFile = Join-Path $TestDrive "test.csv"
        $script:TestJsonFile = Join-Path $TestDrive "test.json"
        $script:TestXmlFile = Join-Path $TestDrive "test.xml"
        
        "Name,Age,City" | Out-File $script:TestCsvFile -Encoding UTF8
        "John,30,NYC" | Out-File $script:TestCsvFile -Append -Encoding UTF8
        "Jane,25,LA" | Out-File $script:TestCsvFile -Append -Encoding UTF8
    }
    
    It "Should create test CSV file" {
        Test-Path $script:TestCsvFile | Should -Be $true
    }
    
    It "Should convert CSV to JSON" {
        $script:ScriptPath = "$script:DataTransformPath\ConvertTo-JsonFromCsv.ps1"
        { & $script:ScriptPath -InputFile $script:TestCsvFile -OutputFile $script:TestJsonFile } | Should -Not -Throw
        Test-Path $script:TestJsonFile | Should -Be $true
    }
    
    It "Should convert CSV to XML" {
        $script:ScriptPath = "$script:DataTransformPath\ConvertTo-XmlFromCsv.ps1"
        $xmlOutput = Join-Path $TestDrive "output.xml"
        { & $script:ScriptPath -InputFile $script:TestCsvFile -OutputFile $xmlOutput } | Should -Not -Throw
    }
}
