-- Prevent large identity jumps when SQL Server restarts or fails over.
-- OrderRepository formats OrderID as the customer-facing order number (D4).
-- Keeps all existing order IDs/numbers. Failed inserts and deletions can still leave gaps.
USE [portable_kiosk_db];
GO

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF;
GO

CHECKPOINT;
GO

SELECT name, value
FROM sys.database_scoped_configurations
WHERE name = N'IDENTITY_CACHE';
GO
