$ErrorActionPreference = 'Stop'
$analyticsRoot = Split-Path $PSScriptRoot -Parent
$analyticsApp = Join-Path $analyticsRoot 'PortableKiosk'
$analyticsOutput = Join-Path $analyticsRoot 'TestResults/analytics'
New-Item -ItemType Directory -Path $analyticsOutput -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $analyticsApp 'bin/PortableKiosk.dll') -Destination $analyticsOutput
$analyticsExe = Join-Path $analyticsOutput 'AnalyticsDrilldownTests.exe'
& (Join-Path $analyticsApp 'bin/roslyn/csc.exe') /nologo /target:exe "/out:$analyticsExe" `
    "/reference:$(Join-Path $analyticsOutput 'PortableKiosk.dll')" /reference:System.IO.Compression.dll `
    /reference:System.Xml.Linq.dll (Join-Path $PSScriptRoot 'AnalyticsDrilldownTests.cs')
if ($LASTEXITCODE -ne 0) { throw 'Test compilation failed.' }
[xml]$analyticsWebConfig = Get-Content -LiteralPath (Join-Path $analyticsApp 'Web.config')
$analyticsTestConfig = [xml]'<configuration />'
[void]$analyticsTestConfig.DocumentElement.AppendChild($analyticsTestConfig.ImportNode($analyticsWebConfig.configuration.connectionStrings, $true))
$analyticsConfigPath = $analyticsExe + '.config'
try {
    $analyticsTestConfig.Save($analyticsConfigPath)
    & $analyticsExe
    if ($LASTEXITCODE -ne 0) { throw 'Analytics integration checks failed.' }
} finally {
    # Do not leave a duplicate connection string in the test output.
    Remove-Item -LiteralPath $analyticsConfigPath -ErrorAction SilentlyContinue
}
