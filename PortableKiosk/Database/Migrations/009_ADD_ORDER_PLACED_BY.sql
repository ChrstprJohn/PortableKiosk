-- Preserve old orders as UNKNOWN: their creator was not recorded.
USE [portable_kiosk_db];
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH(N'dbo.Orders', N'OrderSource') IS NULL
    ALTER TABLE dbo.Orders ADD OrderSource NVARCHAR(10) NOT NULL
        CONSTRAINT DF_Orders_OrderSource DEFAULT N'UNKNOWN' WITH VALUES;
IF COL_LENGTH(N'dbo.Orders', N'PlacedByStaffAccountID') IS NULL
    ALTER TABLE dbo.Orders ADD PlacedByStaffAccountID INT NULL;
IF COL_LENGTH(N'dbo.Orders', N'PlacedByName') IS NULL
    ALTER TABLE dbo.Orders ADD PlacedByName NVARCHAR(200) NULL;
COMMIT TRANSACTION;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Orders_PlacedByStaffAccount')
    ALTER TABLE dbo.Orders WITH CHECK ADD CONSTRAINT FK_Orders_PlacedByStaffAccount
        FOREIGN KEY (PlacedByStaffAccountID) REFERENCES dbo.StaffAccounts(StaffAccountID) ON DELETE SET NULL;
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Orders_OrderSource')
    ALTER TABLE dbo.Orders WITH CHECK ADD CONSTRAINT CK_Orders_OrderSource
        CHECK (OrderSource IN (N'UNKNOWN', N'KIOSK', N'POS'));
COMMIT TRANSACTION;
GO
