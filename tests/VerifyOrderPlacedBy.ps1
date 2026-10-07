$ErrorActionPreference = 'Stop'
$testRoot = Split-Path $PSScriptRoot -Parent
$testApp = Join-Path $testRoot 'PortableKiosk'
$testOutput = Join-Path $testRoot 'TestResults/order-placed-by'
New-Item -ItemType Directory -Path $testOutput -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $testApp 'bin/PortableKiosk.dll') -Destination $testOutput
$testExe = Join-Path $testOutput 'OrderPlacedByTests.exe'
& (Join-Path $testApp 'bin/roslyn/csc.exe') /nologo /target:exe "/out:$testExe" "/reference:$(Join-Path $testOutput 'PortableKiosk.dll')" /reference:System.Data.dll (Join-Path $PSScriptRoot 'OrderPlacedByTests.cs')
if ($LASTEXITCODE -ne 0) { throw 'Test compilation failed.' }
[xml]$testWebConfig = Get-Content -LiteralPath (Join-Path $testApp 'Web.config')
$testConnection = [System.Data.SqlClient.SqlConnectionStringBuilder]::new($testWebConfig.configuration.connectionStrings.add.connectionString)
$testDatabaseName = 'PortableKiosk_PlacedByTests_' + [guid]::NewGuid().ToString('N')
$testConnection['Initial Catalog'] = 'master'
$testMaster = [System.Data.SqlClient.SqlConnection]::new($testConnection.ConnectionString)
$testMaster.Open()
$testCreated = $false
$testConfigPath = $testExe + '.config'
function Invoke-TestSql($connection, $sql) {
    foreach ($batch in [regex]::Split($sql, '(?im)^\s*GO\s*$')) {
        if ([string]::IsNullOrWhiteSpace($batch)) { continue }
        $command = $connection.CreateCommand()
        try { $command.CommandText = $batch; $command.CommandTimeout = 60; [void]$command.ExecuteNonQuery() }
        finally { $command.Dispose() }
    }
}
try {
    Invoke-TestSql $testMaster "CREATE DATABASE [$testDatabaseName]"
    $testCreated = $true
    $testConnection['Initial Catalog'] = $testDatabaseName
    $testDb = [System.Data.SqlClient.SqlConnection]::new($testConnection.ConnectionString)
    $testDb.Open()
    try {
        $schema = [IO.File]::ReadAllText((Join-Path $testApp 'Database/Schema.sql')).Replace('portable_kiosk_db', $testDatabaseName)
        Invoke-TestSql $testDb $schema
        # Simulate an existing installation and a historical order with no recorded creator.
        Invoke-TestSql $testDb @'
ALTER TABLE dbo.Orders DROP CONSTRAINT FK_Orders_PlacedByStaffAccount, CK_Orders_OrderSource, DF_Orders_OrderSource, CK_Orders_ProcessedByRole;
ALTER TABLE dbo.Orders DROP COLUMN OrderSource, PlacedByStaffAccountID, PlacedByName, ProcessedByRole;
INSERT dbo.Orders (OrderNumber, OrderType, FulfillmentMethod) VALUES (N'LEGACY', N'TAKEOUT', N'COUNTER_PICKUP');
'@
        $upgrade = [IO.File]::ReadAllText((Join-Path $testApp 'Database/Migrations/Upgrades/UPDATE ORDER PROCESSOR ROLE.sql')).Replace('portable_kiosk_db', $testDatabaseName)
        Invoke-TestSql $testDb $upgrade
        Invoke-TestSql $testDb $upgrade # Migration must be safe to rerun.
        $installer = [IO.File]::ReadAllText((Join-Path $testApp 'Database/InstallStoredProcedures.sql')).Replace('portable_kiosk_db', $testDatabaseName)
        Invoke-TestSql $testDb $installer
    } finally { $testDb.Dispose() }
    $testConfig = [xml]'<configuration><connectionStrings><add name="PortableKioskDb" providerName="System.Data.SqlClient" /></connectionStrings></configuration>'
    $testConfig.configuration.connectionStrings.add.SetAttribute('connectionString', $testConnection.ConnectionString)
    $testConfig.Save($testConfigPath)
    & $testExe (Join-Path $testApp 'Database/Migrations/010_ADD_ORDER_PROCESSOR_ROLE.sql')
    if ($LASTEXITCODE -ne 0) { throw 'Placed-by integration checks failed.' }
} finally {
    Remove-Item -LiteralPath $testConfigPath -ErrorAction SilentlyContinue
    [System.Data.SqlClient.SqlConnection]::ClearAllPools()
    if ($testCreated -and $testDatabaseName -match '^PortableKiosk_PlacedByTests_[a-f0-9]{32}$') {
        Invoke-TestSql $testMaster "ALTER DATABASE [$testDatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$testDatabaseName];"
    }
    $testMaster.Dispose()
}
