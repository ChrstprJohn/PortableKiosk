-- Stored procedures for OrderRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Order_GetByID
    @Value INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        OrderID,
        OrderNumber,
        OrderType,
        FulfillmentMethod,
        TableNumber,
        KitchenStatus,
        ExpiresAt,
        CreatedAt
    FROM Orders
    WHERE OrderID = @Value;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_GetByOrderNumber
    @Value NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        OrderID,
        OrderNumber,
        OrderType,
        FulfillmentMethod,
        TableNumber,
        KitchenStatus,
        ExpiresAt,
        CreatedAt
    FROM Orders
    WHERE OrderNumber = @Value;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        OrderID,
        OrderNumber,
        OrderType,
        FulfillmentMethod,
        TableNumber,
        KitchenStatus,
        ExpiresAt,
        CreatedAt
    FROM Orders
    ORDER BY CreatedAt DESC, OrderID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_GetPaidKitchenOrders
    @IncludeCompleted BIT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT o.OrderID, o.OrderNumber, o.OrderType,
        o.FulfillmentMethod, o.TableNumber, o.KitchenStatus,
        o.ExpiresAt, o.CreatedAt
    FROM Orders o
    WHERE (o.KitchenStatus IN (N'QUEUED', N'PREPARING', N'SERVING')
        OR (@IncludeCompleted = 1 AND o.KitchenStatus = N'COMPLETED'))
        AND EXISTS (
            SELECT 1 FROM Payments p
            WHERE p.OrderID = o.OrderID AND p.PaymentStatus = N'PAID'
        )
    ORDER BY o.CreatedAt, o.OrderID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_CancelExpiredPendingOrders
    @ExpiryMinutes INT
AS
BEGIN
    SET NOCOUNT OFF;
    SET NOCOUNT ON;

    DECLARE @ExpiredOrders TABLE (OrderID INT PRIMARY KEY);
    DECLARE @ExpiredCount INT = 0;
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    UPDATE p
    SET PaymentStatus = N'EXPIRED'
    OUTPUT inserted.OrderID INTO @ExpiredOrders (OrderID)
    FROM Payments p
    INNER JOIN Orders o ON o.OrderID = p.OrderID
    WHERE p.PaymentMethod = N'CASH_COUNTER'
        AND p.PaymentStatus = N'PENDING'
        AND COALESCE(
            o.ExpiresAt,
            DATEADD(
                MINUTE,
                @ExpiryMinutes,
                o.CreatedAt)) <= @Now;

    SET @ExpiredCount = @@ROWCOUNT;

    UPDATE o
    SET KitchenStatus = N'CANCELLED'
    FROM Orders o
    INNER JOIN @ExpiredOrders expired
        ON expired.OrderID = o.OrderID
    WHERE o.KitchenStatus IN (
        N'AWAITING_PAYMENT',
        N'QUEUED'
    );

    SELECT @ExpiredCount;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_Update
    @OrderType NVARCHAR(10),
    @FulfillmentMethod NVARCHAR(20),
    @TableNumber NVARCHAR(20),
    @KitchenStatus NVARCHAR(20),
    @ExpiresAt DATETIME2(7),
    @OrderID INT,
    @OrderNumber NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Orders
    SET
        OrderType = @OrderType,
        FulfillmentMethod = @FulfillmentMethod,
        TableNumber = @TableNumber,
        KitchenStatus = @KitchenStatus,
        ExpiresAt = @ExpiresAt
    WHERE OrderID = @OrderID
        AND (
            @KitchenStatus IN (N'AWAITING_PAYMENT', N'CANCELLED')
            OR EXISTS (
                SELECT 1
                FROM Payments p
                WHERE p.OrderID = Orders.OrderID
                    AND p.PaymentStatus = N'PAID'
            )
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_SetKitchenStatus
    @NextStatus NVARCHAR(20),
    @OrderID INT,
    @CurrentStatus NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Orders
    SET KitchenStatus = @NextStatus
    WHERE OrderID = @OrderID AND KitchenStatus = @CurrentStatus
        AND EXISTS (SELECT 1 FROM Payments
            WHERE Payments.OrderID = Orders.OrderID
                AND PaymentStatus = N'PAID');
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_Delete
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Orders
    WHERE OrderID = @OrderID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_Add_Insert
    @OrderNumber NVARCHAR(20),
    @OrderType NVARCHAR(10),
    @FulfillmentMethod NVARCHAR(20),
    @TableNumber NVARCHAR(20),
    @KitchenStatus NVARCHAR(20),
    @ExpiresAt DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Orders
        (
            OrderNumber,
            OrderType,
            FulfillmentMethod,
            TableNumber,
            KitchenStatus,
            ExpiresAt
        )
    OUTPUT INSERTED.OrderID, INSERTED.CreatedAt
    VALUES
        (
            @OrderNumber,
            @OrderType,
            @FulfillmentMethod,
            @TableNumber,
            @KitchenStatus,
            @ExpiresAt
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.Order_Add_UpdateNumber
    @OrderNumber NVARCHAR(20),
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Orders
    SET OrderNumber = @OrderNumber
    WHERE OrderID = @OrderID;
END;
GO
