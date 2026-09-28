IF OBJECT_ID(N'dbo.CK_Payments_PaymentStatus', N'C') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Payments
        DROP CONSTRAINT CK_Payments_PaymentStatus;
END;
GO

ALTER TABLE dbo.Payments WITH CHECK
    ADD CONSTRAINT CK_Payments_PaymentStatus
    CHECK (
        PaymentStatus IN (
            N'PENDING',
            N'PAID',
            N'FAILED',
            N'CANCELLED',
            N'EXPIRED'
        )
    );
GO
