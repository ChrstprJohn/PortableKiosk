$ErrorActionPreference = 'Stop'
$header = @'
-- Generated from StoredProcedures/*.sql by BuildStoredProcedures.ps1.
-- Run against the application database after applying schema/migrations.
USE [portable_kiosk_db];
GO

'@
$files = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'StoredProcedures') -Filter '*.sql' | Sort-Object Name
$body = ($files | ForEach-Object { [System.IO.File]::ReadAllText($_.FullName) }) -join "`r`n"
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot 'InstallStoredProcedures.sql'), $header + "`r`n" + $body, [System.Text.UTF8Encoding]::new($false))
Write-Output "Built InstallStoredProcedures.sql from $($files.Count) repository files."
