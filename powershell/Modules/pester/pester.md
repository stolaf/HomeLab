# Pester Testframework
https://pester.dev/docs/quick-start
https://github.com/pester/Pester
https://jakubjares.com

```powershell
Install-Module pester -Force
Import-Module pester -Force

function New-Thing {
    "Thing"
}

Describe "New-Thing" {
    BeforeAll {
        Write-Host "BeforeAll"
    }
    BeforeEach {
        Write-Host "BeforeEach"
    }
    AfterAll {
        Write-Host "AfterAll"
    }
    AfterEach {
        Write-Host "AfterEach"
    }
    Context "Context" {
        It "shoult return a thing" {
            New-Thing | Should -Be "Thing"
        }
        It "should not return a thing" {
            New-Thing | Should -Not -Be "Thinger"
        }
    }
}

Describe "Should" {
    It "should assert" {
        "Test" | Should -be "Test"
        "Test" | Should -not -be "Tester"
        "test" | Should -BeExactly "Test"
    }
}

Describe "Should" {
    It "should continue on error" {
        "Test" | Should -be "Tester" -ErrorAction Continue
        1 | Should -be 2
    }
}

```

## Pester 5
https://www.youtube.com/watch?v=yd3M5sKW7jA&t=25s