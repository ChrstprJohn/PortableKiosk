-- Clear non-user data so POPULATE CATALOG.sql can rebuild the catalog.
-- Preserves every staff account, password, role, status, and staff identity value.
-- Removes orders, payments, catalog entries, and the saved website QR link.
-- Restores kiosk availability and the default 30-minute payment expiry.
-- SQL Server foreign keys prevent TRUNCATE on referenced tables; use DELETE
-- in dependency order and reseed identities without dropping constraints.
USE [portable_kiosk_db];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT * INTO #PreservedStaffAccounts
    FROM dbo.StaffAccounts WITH (TABLOCKX, HOLDLOCK);

    DELETE FROM dbo.OrderItems;
    DELETE FROM dbo.Payments;
    DELETE FROM dbo.Orders;
    DELETE FROM dbo.ProductVariants;
    DELETE FROM dbo.Products;
    DELETE FROM dbo.Sizes;
    DELETE FROM dbo.Categories;
    DELETE FROM dbo.WebsiteQrCode;
    DELETE FROM dbo.KioskSettings;

    INSERT INTO dbo.KioskSettings (SettingsID, IsAvailable, PendingPaymentExpiryMinutes)
    VALUES (1, 1, 30);

    -- Skip never-used / truncated identities: reseeding those to zero would
    -- make their first inserted ID zero. After DELETE, reseed to zero yields one.
    DECLARE @TableName SYSNAME;
    DECLARE @ReseedSql NVARCHAR(MAX) = N'';
    DECLARE ResetIdentities CURSOR LOCAL FAST_FORWARD FOR
        SELECT OBJECT_NAME(object_id)
        FROM sys.identity_columns
        WHERE object_id IN (
            OBJECT_ID(N'dbo.OrderItems'), OBJECT_ID(N'dbo.Payments'),
            OBJECT_ID(N'dbo.Orders'), OBJECT_ID(N'dbo.ProductVariants'),
            OBJECT_ID(N'dbo.Products'), OBJECT_ID(N'dbo.Sizes'),
            OBJECT_ID(N'dbo.Categories'))
            AND last_value IS NOT NULL;
    OPEN ResetIdentities;
    FETCH NEXT FROM ResetIdentities INTO @TableName;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ReseedSql += N'DBCC CHECKIDENT (N''dbo.' + @TableName + N''', RESEED, 0) WITH NO_INFOMSGS;' + CHAR(10);
        FETCH NEXT FROM ResetIdentities INTO @TableName;
    END;
    CLOSE ResetIdentities;
    DEALLOCATE ResetIdentities;
    IF LEN(@ReseedSql) > 0 EXEC sys.sp_executesql @ReseedSql;

    IF EXISTS (SELECT * FROM dbo.StaffAccounts EXCEPT SELECT * FROM #PreservedStaffAccounts)
        OR EXISTS (SELECT * FROM #PreservedStaffAccounts EXCEPT SELECT * FROM dbo.StaffAccounts)
        THROW 50001, 'Staff accounts changed during reset. Reset rolled back.', 1;

    DROP TABLE #PreservedStaffAccounts;
    COMMIT TRANSACTION;

    SELECT N'Data reset complete. Staff accounts preserved. Run POPULATE CATALOG.sql next.' AS Result;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
