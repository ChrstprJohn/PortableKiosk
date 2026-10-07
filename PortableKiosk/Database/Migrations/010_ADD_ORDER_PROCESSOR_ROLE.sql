-- Apply after migration 009. New orders snapshot the role at POS processing.
-- Older orders use the linked staff account's current role at migration time;
-- deleted accounts and orders without a recorded processor keep a NULL role.
USE [portable_kiosk_db];
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH(N'dbo.Orders', N'PlacedByStaffAccountID') IS NULL
    THROW 50001, 'Apply migration 009 before adding the order processor role.', 1;
IF COL_LENGTH(N'dbo.Orders', N'ProcessedByRole') IS NULL
    ALTER TABLE dbo.Orders ADD ProcessedByRole NVARCHAR(10) NULL;
COMMIT TRANSACTION;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;
UPDATE o
SET ProcessedByRole = staff.StaffRole
FROM dbo.Orders o
INNER JOIN dbo.StaffAccounts staff ON staff.StaffAccountID = o.PlacedByStaffAccountID
WHERE o.ProcessedByRole IS NULL AND staff.StaffRole IN (N'ADMIN', N'CREW');

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Orders_ProcessedByRole')
    ALTER TABLE dbo.Orders WITH CHECK ADD CONSTRAINT CK_Orders_ProcessedByRole
        CHECK (ProcessedByRole IS NULL OR ProcessedByRole IN (N'ADMIN', N'CREW'));
COMMIT TRANSACTION;
GO
