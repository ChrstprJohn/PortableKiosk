IF OBJECT_ID(
    N'dbo.CK_Orders_TakeoutFulfillment',
    N'C') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Orders
    DROP CONSTRAINT CK_Orders_TakeoutFulfillment;
END;
GO
