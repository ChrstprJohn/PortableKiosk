USE portable_kiosk_db;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.CK_Orders_KitchenStatus', N'C') IS NOT NULL
    BEGIN
        ALTER TABLE dbo.Orders DROP CONSTRAINT CK_Orders_KitchenStatus;
    END;

    UPDATE dbo.Orders
    SET KitchenStatus = N'SERVING'
    WHERE KitchenStatus = N'READY';

    ALTER TABLE dbo.Orders WITH CHECK
        ADD CONSTRAINT CK_Orders_KitchenStatus
        CHECK (KitchenStatus IN (
            N'AWAITING_PAYMENT',
            N'QUEUED',
            N'PREPARING',
            N'SERVING',
            N'COMPLETED',
            N'CANCELLED'
        ));

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
