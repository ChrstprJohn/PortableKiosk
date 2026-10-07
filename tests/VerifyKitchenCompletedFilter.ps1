$ErrorActionPreference = 'Stop'
$kitchenRoot = Split-Path $PSScriptRoot -Parent
$kitchenApp = Join-Path $kitchenRoot 'PortableKiosk'
$kitchenOutput = Join-Path $kitchenRoot 'TestResults/kitchen-filter'
New-Item -ItemType Directory -Path $kitchenOutput -Force | Out-Null
$kitchenExe = Join-Path $kitchenOutput 'KitchenCompletedFilterTests.exe'
& (Join-Path $kitchenApp 'bin/roslyn/csc.exe') /nologo /target:exe "/out:$kitchenExe" `
    (Join-Path $kitchenApp 'Core/Models/Order.cs') `
    (Join-Path $kitchenApp 'Core/Services/KitchenCompletedFilter.cs') `
    (Join-Path $PSScriptRoot 'KitchenCompletedFilterTests.cs')
if ($LASTEXITCODE -ne 0) { throw 'Kitchen filter test compilation failed.' }
& $kitchenExe
if ($LASTEXITCODE -ne 0) { throw 'Kitchen completed filter checks failed.' }
