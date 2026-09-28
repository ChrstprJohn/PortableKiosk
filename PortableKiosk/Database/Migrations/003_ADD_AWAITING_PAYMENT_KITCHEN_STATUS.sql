IF OBJECT_ID(N'dbo.CK_Orders_KitchenStatus', N'C') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Orders
        DROP CONSTRAINT CK_Orders_KitchenStatus;
END;
GO

ALTER TABLE dbo.Orders WITH CHECK
    ADD CONSTRAINT CK_Orders_KitchenStatus
    CHECK (
        KitchenStatus IN (
            N'AWAITING_PAYMENT',
            N'QUEUED',
            N'PREPARING',
            N'READY',
            N'COMPLETED',
            N'CANCELLED'
        )
    );
GO
