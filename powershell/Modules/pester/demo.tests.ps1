Import-Module -Name 'Pester' -MinimumVersion '5.1.1'

# https://github.com/pester/pester
# Settings / Codelens / Powershell Pester : Disable Checkbox

Describe "Should" {
    It "should continue on error" {
        "Test" | Should -be "Tester" -ErrorAction Continue
        1 | Should -be 2
    }
}

Describe "Tags" {
    Context "Integration" {
        It "integration 1" {
            1 | should -be 1
        }
        It "integration 2" {
            1 | should -be 1
        }
        It "integration 3" {
            1 | should -be 1
        }
    } -Tag "Integration"
    Context "Unit" {
        It "unit 1" {
            1 | should -be 1
        }
        It "unit 2" {
            1 | should -be 1
        } -Tag "Integration"
        It "unit 3" {
            1 | should -be 1
        }
    } -Tag "Unit"
} 

Describe "Long" {
    It "should run a long time" {
        Start-Sleep -Seconds 4
    }
} -Tag "LongRunning"

Describe "Skip" {
    It "it is skipped" {

    }
} -Skip

Describe "Don't skip" {
    Context "Skip" {
        It "it is skipped" {

        }
    } -Skip
    Context "Don't skip" {
        It "it is skipped" {

        } -Skip
    } 
}

Describe "Test Cases" {
    It "should run test cases" -TestCases @(
        @{ Name = "Adam"; Age = 34}
        @{ Name = "Jim"; Age = 29}
        @{ Name = "Sarah"; Age = 32}
    ) {
        $Name | Should -be "Adam"
    }
} -Tag "TestCases"

Describe "Mocking" {
    BeforeAll {
        function New-Thing {
            "Thing"
        }
    }
    It "should return the real thing" {
        New-Thing | Should -be "Thing"
    }
    It "should return the fake thing" {
        Mock -CommandName New-Thing -MockWith { "FakeThing" }
        New-Thing | Should -be "FakeThing"
    }
    It "should return assert that it was called" {
        Mock -CommandName New-Thing -MockWith { "FakeThing" }
        New-Thing
        Should -Invoke New-Thing -Times 1
    }
    It "should use parameter filter" {
        function New-Thang { param($a) $a} 
        Mock -CommandName New-Thang -MockWith { "FakeThing" } -ParameterFilter { $a -eq 'Yes'} 
        New-Thang
        Should -Invoke New-Thang -Times 0
        New-Thang -A "Yes"
        Should -Invoke New-Thang -Times 1
    }
    It "should debug the mock" {
        function New-Thang { param($a) $a} 
        Mock -CommandName New-Thang -MockWith {
            "FakeThing"
        }
        New-Thang
    }
} -Tag "Mocking"

# Invoke-Pester -Path 'C:\Users\olaf\Documents\HomeLab\software\pwsh\pester\demo.tests.ps1' -TagFilter 'Integration'
# Invoke-Pester -Path 'C:\Users\olaf\Documents\HomeLab\software\pwsh\pester\demo.tests.ps1' -TagFilter 'Long*'
# Invoke-Pester -Path 'C:\Users\olaf\Documents\HomeLab\software\pwsh\pester\demo.tests.ps1' -TagFilter 'Unit','Integration'
# Invoke-Pester -Path 'C:\Users\olaf\Documents\HomeLab\software\pwsh\pester\demo.tests.ps1' -TagFilter 'TestCases'
# Invoke-Pester -Path 'C:\Users\olaf\Documents\HomeLab\software\pwsh\pester\demo.tests.ps1' -TagFilter 'Mocking'