-- Stored procedures for PosRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteNewCashSale_Lock
    @Resource NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @Result INT;
    EXEC @Result = sp_getapplock
        @Resource = @Resource,
        @LockMode = N'Exclusive',
        @LockOwner = N'Transaction',
        @LockTimeout = 10000;
    SELECT @Result;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteNewCashSale_Existing
    @Reference NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT o.OrderID, o.OrderNumber, o.OrderType,
        o.FulfillmentMethod, o.TableNumber, o.KitchenStatus,
        o.CreatedAt, p.PaymentID, p.Amount, p.PaidAt
    FROM Payments p
    INNER JOIN Orders o ON o.OrderID = p.OrderID
    WHERE p.TransactionReference = @Reference
        AND p.PaymentMethod IN (N'CASH_COUNTER', N'CASHLESS')
        AND p.PaymentStatus = N'PAID';
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_GetAvailableCatalog
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        pv.ProductVariantID,
        pv.ProductID,
        c.CategoryID,
        pv.SizeID,
        p.ProductName,
        c.CategoryName,
        s.SizeName,
        pv.ImagePath,
        pv.Price
    FROM ProductVariants pv
    INNER JOIN Products p ON p.ProductID = pv.ProductID
    INNER JOIN Categories c ON c.CategoryID = p.CategoryID
    LEFT JOIN Sizes s ON s.SizeID = pv.SizeID
    WHERE pv.IsAvailable = 1
        AND p.IsAvailable = 1
        AND c.IsAvailable = 1
    ORDER BY c.CategoryName, p.ProductName,
        pv.Price, pv.ProductVariantID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteKioskCashOrder_Lock
    @ExpiryMinutes INT,
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        o.OrderID,
        o.OrderNumber,
        o.OrderType,
        o.FulfillmentMethod,
        o.TableNumber,
        o.KitchenStatus,
        o.CreatedAt,
        COALESCE(
            o.ExpiresAt,
            DATEADD(MINUTE, @ExpiryMinutes, o.CreatedAt)
        ) AS EffectiveExpiresAt,
        p.PaymentID,
        p.PaymentMethod,
        p.PaymentStatus
    FROM Payments p WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN Orders o WITH (UPDLOCK, HOLDLOCK)
        ON o.OrderID = p.OrderID
    WHERE p.OrderID = @OrderID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteKioskCashOrder_DeleteItems
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM OrderItems WHERE OrderID = @OrderID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteKioskCashOrder_CurrentItems
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT OrderItemID, ProductVariantID, UnitPrice, Quantity
    FROM OrderItems WITH (UPDLOCK, HOLDLOCK)
    WHERE OrderID = @OrderID
    ORDER BY OrderItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteKioskCashOrder_Pay
    @PaymentMethod NVARCHAR(20),
    @Amount DECIMAL(10,2),
    @TransactionReference NVARCHAR(100),
    @PaidAt DATETIME2(7),
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Payments
    SET PaymentMethod = @PaymentMethod,
        PaymentStatus = N'PAID',
        Amount = @Amount,
        TransactionReference = @TransactionReference,
        PaidAt = @PaidAt
    WHERE OrderID = @OrderID
        AND PaymentMethod = N'CASH_COUNTER'
        AND PaymentStatus = N'PENDING';
END;
GO

CREATE OR ALTER PROCEDURE dbo.Pos_CompleteKioskCashOrder_Queue
    @OrderID INT,
    @ExpiryMinutes INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Orders
    SET KitchenStatus = N'QUEUED', ExpiresAt = NULL
    WHERE OrderID = @OrderID
        AND KitchenStatus = N'AWAITING_PAYMENT'
        AND COALESCE(
            ExpiresAt,
            DATEADD(MINUTE, @ExpiryMinutes, CreatedAt)
        ) > SYSUTCDATETIME();
END;
GO
