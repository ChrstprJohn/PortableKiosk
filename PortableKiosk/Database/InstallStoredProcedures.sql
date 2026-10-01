-- Generated from StoredProcedures/*.sql by BuildStoredProcedures.ps1.
-- Run against the application database after applying schema/migrations.
USE [portable_kiosk_db];
GO

-- Stored procedures for AnalyticsRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadSummary
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT COALESCE(SUM(Amount), 0), COUNT(*)
    FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End;
    SELECT COUNT(*), COALESCE(SUM(CASE WHEN p.PaymentStatus = N'PAID' THEN 1 ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.PaymentStatus = N'PAID' THEN p.Amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.PaymentStatus = N'EXPIRED'
            OR (p.PaymentStatus = N'PENDING' AND o.ExpiresAt IS NOT NULL
                AND o.ExpiresAt <= SYSUTCDATETIME()) THEN 1 ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.PaymentStatus = N'EXPIRED'
            OR (p.PaymentStatus = N'PENDING' AND o.ExpiresAt IS NOT NULL
                AND o.ExpiresAt <= SYSUTCDATETIME()) THEN p.Amount ELSE 0 END), 0)
    FROM Orders o LEFT JOIN Payments p ON p.OrderID = o.OrderID
    WHERE o.CreatedAt >= @Start AND o.CreatedAt < @End;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadTrend
    @Monthly BIT,
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT CASE WHEN @Monthly = 1
        THEN DATEFROMPARTS(YEAR(DATEADD(HOUR, 8, PaidAt)), MONTH(DATEADD(HOUR, 8, PaidAt)), 1)
        ELSE CAST(DATEADD(HOUR, 8, PaidAt) AS date) END AS Bucket, SUM(Amount)
    FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End
    GROUP BY CASE WHEN @Monthly = 1
        THEN DATEFROMPARTS(YEAR(DATEADD(HOUR, 8, PaidAt)), MONTH(DATEADD(HOUR, 8, PaidAt)), 1)
        ELSE CAST(DATEADD(HOUR, 8, PaidAt) AS date) END
    ORDER BY 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadProducts
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT p.ProductName, COALESCE(SUM(oi.Quantity), 0) AS Units,
        COALESCE(SUM(oi.UnitPrice * oi.Quantity), 0) AS Revenue,
        CASE WHEN p.IsAvailable = 1 AND c.IsAvailable = 1
            AND EXISTS (SELECT 1 FROM ProductVariants available
                WHERE available.ProductID = p.ProductID AND available.IsAvailable = 1)
            THEN 1 ELSE 0 END AS OnMenu,
        (SELECT TOP (1) imageVariant.ImagePath
            FROM ProductVariants imageVariant
            WHERE imageVariant.ProductID = p.ProductID
                AND imageVariant.ImagePath IS NOT NULL
                AND LTRIM(RTRIM(imageVariant.ImagePath)) <> N''
            ORDER BY imageVariant.IsAvailable DESC,
                imageVariant.ProductVariantID) AS ImagePath
    FROM Products p
    INNER JOIN Categories c ON c.CategoryID = p.CategoryID
    LEFT JOIN ProductVariants pv ON pv.ProductID = p.ProductID
    LEFT JOIN OrderItems oi ON oi.ProductVariantID = pv.ProductVariantID
        AND EXISTS (SELECT 1 FROM Payments pay WHERE pay.OrderID = oi.OrderID
            AND pay.PaymentStatus = N'PAID' AND pay.PaidAt >= @Start AND pay.PaidAt < @End)
    GROUP BY p.ProductID, p.ProductName, p.IsAvailable, c.IsAvailable;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadCategories
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT c.CategoryName, COALESCE(SUM(oi.Quantity), 0),
        COALESCE(SUM(oi.UnitPrice * oi.Quantity), 0)
    FROM Categories c LEFT JOIN Products p ON p.CategoryID = c.CategoryID
    LEFT JOIN ProductVariants pv ON pv.ProductID = p.ProductID
    LEFT JOIN OrderItems oi ON oi.ProductVariantID = pv.ProductVariantID
        AND EXISTS (SELECT 1 FROM Payments pay WHERE pay.OrderID = oi.OrderID
            AND pay.PaymentStatus = N'PAID' AND pay.PaidAt >= @Start AND pay.PaidAt < @End)
    GROUP BY c.CategoryID, c.CategoryName ORDER BY 3 DESC, c.CategoryName;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadPaymentMethods
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT PaymentMethod, COUNT(*), SUM(Amount)
    FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End
    GROUP BY PaymentMethod ORDER BY 3 DESC;
END;
GO

-- Stored procedures for CategoryRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Category_Add
    @CategoryName NVARCHAR(100),
    @IsAvailable BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Categories
        (CategoryName, IsAvailable)
    OUTPUT INSERTED.CategoryID
    VALUES
        (@CategoryName, @IsAvailable);
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_GetByID
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        CategoryID,
        CategoryName,
        IsAvailable
    FROM Categories
    WHERE CategoryID = @CategoryID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        CategoryID,
        CategoryName,
        IsAvailable
    FROM Categories
    ORDER BY CategoryName ASC, CategoryID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_GetAvailable
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        CategoryID,
        CategoryName,
        IsAvailable
    FROM Categories
    WHERE IsAvailable = 1
    ORDER BY CategoryName ASC, CategoryID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_Update
    @CategoryName NVARCHAR(100),
    @IsAvailable BIT,
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Categories
    SET
        CategoryName = @CategoryName,
        IsAvailable = @IsAvailable
    WHERE CategoryID = @CategoryID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_Delete
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Categories
    WHERE CategoryID = @CategoryID;
END;
GO

-- Stored procedures for KioskSettingsRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.KioskSettings_Get
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT IsAvailable, PendingPaymentExpiryMinutes
                    FROM KioskSettings WHERE SettingsID = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.KioskSettings_Save
    @IsAvailable BIT,
    @ExpiryMinutes INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE KioskSettings
                    SET IsAvailable = @IsAvailable,
                        PendingPaymentExpiryMinutes = @ExpiryMinutes
                    WHERE SettingsID = 1;
END;
GO

-- Stored procedures for OrderItemRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.OrderItem_GetByID
    @OrderItemID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        oi.OrderItemID,
        oi.OrderID,
        oi.ProductVariantID,
        p.ProductName,
        pv.ImagePath,
        s.SizeName,
        oi.UnitPrice,
        oi.Quantity
    FROM OrderItems oi
    INNER JOIN ProductVariants pv
        ON pv.ProductVariantID = oi.ProductVariantID
    INNER JOIN Products p
        ON p.ProductID = pv.ProductID
    LEFT JOIN Sizes s
        ON s.SizeID = pv.SizeID
    WHERE oi.OrderItemID = @OrderItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.OrderItem_GetByOrderID
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        oi.OrderItemID,
        oi.OrderID,
        oi.ProductVariantID,
        p.ProductName,
        pv.ImagePath,
        s.SizeName,
        oi.UnitPrice,
        oi.Quantity
    FROM OrderItems oi
    INNER JOIN ProductVariants pv
        ON pv.ProductVariantID = oi.ProductVariantID
    INNER JOIN Products p
        ON p.ProductID = pv.ProductID
    LEFT JOIN Sizes s
        ON s.SizeID = pv.SizeID
    WHERE oi.OrderID = @OrderID
    ORDER BY oi.OrderItemID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.OrderItem_Update
    @OrderID INT,
    @ProductVariantID INT,
    @UnitPrice DECIMAL(10,2),
    @Quantity INT,
    @OrderItemID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE OrderItems
    SET
        OrderID = @OrderID,
        ProductVariantID = @ProductVariantID,
        UnitPrice = @UnitPrice,
        Quantity = @Quantity
    WHERE OrderItemID = @OrderItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.OrderItem_Delete
    @OrderItemID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM OrderItems
    WHERE OrderItemID = @OrderItemID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.OrderItem_Add
    @OrderID INT,
    @ProductVariantID INT,
    @UnitPrice DECIMAL(10,2),
    @Quantity INT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO OrderItems
        (OrderID, ProductVariantID, UnitPrice, Quantity)
    OUTPUT INSERTED.OrderItemID
    VALUES
        (@OrderID, @ProductVariantID, @UnitPrice, @Quantity);
END;
GO

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

-- Stored procedures for PaymentRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Payment_GetByID
    @ID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        PaymentID,
        OrderID,
        PaymentMethod,
        PaymentStatus,
        Amount,
        TransactionReference,
        PaidAt,
        CreatedAt
    FROM Payments
    WHERE PaymentID = @ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_GetByOrderID
    @ID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        PaymentID,
        OrderID,
        PaymentMethod,
        PaymentStatus,
        Amount,
        TransactionReference,
        PaidAt,
        CreatedAt
    FROM Payments
    WHERE OrderID = @ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        PaymentID,
        OrderID,
        PaymentMethod,
        PaymentStatus,
        Amount,
        TransactionReference,
        PaidAt,
        CreatedAt
    FROM Payments
    ORDER BY CreatedAt DESC, PaymentID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Update
    @OrderID INT,
    @PaymentMethod NVARCHAR(20),
    @PaymentStatus NVARCHAR(20),
    @Amount DECIMAL(10,2),
    @TransactionReference NVARCHAR(100),
    @PaidAt DATETIME2(7),
    @PaymentID INT,
    @ExpiryMinutes INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE p
    SET
        OrderID = @OrderID,
        PaymentMethod = @PaymentMethod,
        PaymentStatus = @PaymentStatus,
        Amount = @Amount,
        TransactionReference = @TransactionReference,
        PaidAt = @PaidAt
    FROM Payments p
    WHERE p.PaymentID = @PaymentID
        AND NOT (
            @PaymentStatus = N'PAID'
            AND p.PaymentStatus <> N'PAID'
            AND p.PaymentMethod = N'CASH_COUNTER'
            AND EXISTS (
                SELECT 1
                FROM Orders o
                WHERE o.OrderID = p.OrderID
                    AND COALESCE(
                        o.ExpiresAt,
                        DATEADD(
                            MINUTE,
                            @ExpiryMinutes,
                            o.CreatedAt)) <= SYSUTCDATETIME()
            )
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Update_QueueOrder
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Orders
    SET KitchenStatus = N'QUEUED'
    WHERE OrderID = @OrderID
        AND KitchenStatus = N'AWAITING_PAYMENT';
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Delete
    @PaymentID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Payments
    WHERE PaymentID = @PaymentID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Add
    @OrderID INT,
    @PaymentMethod NVARCHAR(20),
    @PaymentStatus NVARCHAR(20),
    @Amount DECIMAL(10,2),
    @TransactionReference NVARCHAR(100),
    @PaidAt DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Payments
        (
            OrderID,
            PaymentMethod,
            PaymentStatus,
            Amount,
            TransactionReference,
            PaidAt
        )
    OUTPUT INSERTED.PaymentID
    VALUES
        (
            @OrderID,
            @PaymentMethod,
            @PaymentStatus,
            @Amount,
            @TransactionReference,
            @PaidAt
        );
END;
GO

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

-- Stored procedures for ProductRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Product_Add
    @CategoryID INT,
    @ProductName NVARCHAR(100),
    @ProductDescription NVARCHAR(500),
    @IsAvailable BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Products
        (CategoryID, ProductName, ProductDescription, IsAvailable)
    OUTPUT INSERTED.ProductID
    VALUES
        (@CategoryID, @ProductName, @ProductDescription, @IsAvailable);
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT p.ProductID, p.CategoryID, c.CategoryName,
        p.ProductName, p.ProductDescription, p.IsAvailable
    FROM Products AS p
    INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
    ORDER BY p.ProductName ASC, p.ProductID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_GetByID
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT p.ProductID, p.CategoryID, c.CategoryName,
        p.ProductName, p.ProductDescription, p.IsAvailable
    FROM Products AS p
    INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
    WHERE p.ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_GetAvailableByID
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT p.ProductID, p.CategoryID, c.CategoryName,
        p.ProductName, p.ProductDescription, p.IsAvailable
    FROM Products AS p
    INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
    WHERE p.ProductID = @ProductID
        AND p.IsAvailable = 1
        AND c.IsAvailable = 1
        AND EXISTS
        (
            SELECT 1
            FROM ProductVariants AS pv
            WHERE pv.ProductID = p.ProductID
                AND pv.IsAvailable = 1
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_GetAvailableByCategoryID
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT p.ProductID, p.CategoryID, c.CategoryName,
        p.ProductName, p.ProductDescription, p.IsAvailable
    FROM Products AS p
    INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
    WHERE p.CategoryID = @CategoryID
        AND p.IsAvailable = 1
        AND c.IsAvailable = 1
        AND EXISTS
        (
            SELECT 1
            FROM ProductVariants AS pv
            WHERE pv.ProductID = p.ProductID
                AND pv.IsAvailable = 1
        )
    ORDER BY p.ProductName ASC, p.ProductID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_GetTopSellingAvailable
    @Count INT
AS
BEGIN
    SET NOCOUNT OFF;
    WITH SoldUnits AS
    (
        SELECT pv.ProductID, SUM(oi.Quantity) AS Units
        FROM ProductVariants AS pv
        INNER JOIN OrderItems AS oi
            ON oi.ProductVariantID = pv.ProductVariantID
        WHERE EXISTS
        (
            SELECT 1 FROM Payments AS pay
            WHERE pay.OrderID = oi.OrderID
                AND pay.PaymentStatus = N'PAID'
        )
        GROUP BY pv.ProductID
    )
    SELECT TOP (@Count) p.ProductID, p.CategoryID, c.CategoryName,
        p.ProductName, p.ProductDescription, p.IsAvailable
    FROM Products AS p
    INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
    INNER JOIN SoldUnits AS sold ON sold.ProductID = p.ProductID
    WHERE p.IsAvailable = 1 AND c.IsAvailable = 1
        AND EXISTS
        (
            SELECT 1 FROM ProductVariants AS available
            WHERE available.ProductID = p.ProductID
                AND available.IsAvailable = 1
        )
    ORDER BY sold.Units DESC, p.ProductName ASC,
        p.ProductID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_Update
    @CategoryID INT,
    @ProductName NVARCHAR(100),
    @ProductDescription NVARCHAR(500),
    @IsAvailable BIT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Products
    SET CategoryID = @CategoryID,
        ProductName = @ProductName,
        ProductDescription = @ProductDescription,
        IsAvailable = @IsAvailable
    WHERE ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_Delete_DeleteVariants
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM ProductVariants
    WHERE ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Product_Delete_DeleteProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Products
    WHERE ProductID = @ProductID;
END;
GO

-- Stored procedures for ProductVariantRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.ProductVariant_Add
    @ProductID INT,
    @SizeID INT,
    @Price DECIMAL(10,2),
    @ImagePath NVARCHAR(500),
    @IsAvailable BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO ProductVariants
        (
            ProductID,
            SizeID,
            Price,
            ImagePath,
            IsAvailable
        )
    OUTPUT INSERTED.ProductVariantID
    VALUES
        (
            @ProductID,
            @SizeID,
            @Price,
            @ImagePath,
            @IsAvailable
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_AddRange
    @ProductID INT,
    @SizeID INT,
    @Price DECIMAL(10,2),
    @ImagePath NVARCHAR(500),
    @IsAvailable BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO ProductVariants
        (
            ProductID,
            SizeID,
            Price,
            ImagePath,
            IsAvailable
        )
    OUTPUT INSERTED.ProductVariantID
    VALUES
        (
            @ProductID,
            @SizeID,
            @Price,
            @ImagePath,
            @IsAvailable
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        pv.ProductVariantID,
        pv.ProductID,
        pv.SizeID,
        pv.Price,
        pv.ImagePath,
        pv.IsAvailable,
        p.ProductName,
        c.CategoryName,
        s.SizeName
    FROM ProductVariants AS pv
    INNER JOIN Products AS p
        ON p.ProductID = pv.ProductID
    INNER JOIN Categories AS c
        ON c.CategoryID = p.CategoryID
    LEFT JOIN Sizes AS s
        ON s.SizeID = pv.SizeID
    ORDER BY
        c.CategoryName ASC,
        p.ProductName ASC,
        s.SizeName ASC,
        pv.ProductVariantID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_GetByProductID
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        pv.ProductVariantID,
        pv.ProductID,
        pv.SizeID,
        pv.Price,
        pv.ImagePath,
        pv.IsAvailable,
        p.ProductName,
        c.CategoryName,
        s.SizeName
    FROM ProductVariants AS pv
    INNER JOIN Products AS p
        ON p.ProductID = pv.ProductID
    INNER JOIN Categories AS c
        ON c.CategoryID = p.CategoryID
    LEFT JOIN Sizes AS s
        ON s.SizeID = pv.SizeID
    WHERE pv.ProductID = @ProductID
    ORDER BY
        s.SizeName ASC,
        pv.ProductVariantID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_GetAvailableByProductID
    @ProductID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        pv.ProductVariantID,
        pv.ProductID,
        pv.SizeID,
        pv.Price,
        pv.ImagePath,
        pv.IsAvailable,
        p.ProductName,
        c.CategoryName,
        s.SizeName
    FROM ProductVariants AS pv
    INNER JOIN Products AS p
        ON p.ProductID = pv.ProductID
    INNER JOIN Categories AS c
        ON c.CategoryID = p.CategoryID
    LEFT JOIN Sizes AS s
        ON s.SizeID = pv.SizeID
    WHERE pv.ProductID = @ProductID
        AND pv.IsAvailable = 1
        AND p.IsAvailable = 1
        AND c.IsAvailable = 1
    ORDER BY
        CASE WHEN pv.SizeID IS NULL THEN 0 ELSE 1 END,
        pv.Price ASC,
        s.SizeName ASC,
        pv.ProductVariantID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_GetByID
    @ProductVariantID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        pv.ProductVariantID,
        pv.ProductID,
        pv.SizeID,
        pv.Price,
        pv.ImagePath,
        pv.IsAvailable,
        p.ProductName,
        c.CategoryName,
        s.SizeName
    FROM ProductVariants AS pv
    INNER JOIN Products AS p
        ON p.ProductID = pv.ProductID
    INNER JOIN Categories AS c
        ON c.CategoryID = p.CategoryID
    LEFT JOIN Sizes AS s
        ON s.SizeID = pv.SizeID
    WHERE pv.ProductVariantID = @ProductVariantID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_GetAvailableByID
    @ProductVariantID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        pv.ProductVariantID,
        pv.ProductID,
        pv.SizeID,
        pv.Price,
        pv.ImagePath,
        pv.IsAvailable,
        p.ProductName,
        c.CategoryName,
        s.SizeName
    FROM ProductVariants AS pv
    INNER JOIN Products AS p
        ON p.ProductID = pv.ProductID
    INNER JOIN Categories AS c
        ON c.CategoryID = p.CategoryID
    LEFT JOIN Sizes AS s
        ON s.SizeID = pv.SizeID
    WHERE pv.ProductVariantID = @ProductVariantID
        AND pv.IsAvailable = 1
        AND p.IsAvailable = 1
        AND c.IsAvailable = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_Update
    @ProductID INT,
    @SizeID INT,
    @Price DECIMAL(10,2),
    @ImagePath NVARCHAR(500),
    @IsAvailable BIT,
    @ProductVariantID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE ProductVariants
    SET
        ProductID = @ProductID,
        SizeID = @SizeID,
        Price = @Price,
        ImagePath = @ImagePath,
        IsAvailable = @IsAvailable
    WHERE ProductVariantID = @ProductVariantID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.ProductVariant_Delete
    @ProductVariantID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM ProductVariants
    WHERE ProductVariantID = @ProductVariantID;
END;
GO

-- Stored procedures for SizeRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Size_Add
    @SizeName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Sizes
        (SizeName)
    OUTPUT INSERTED.SizeID
    VALUES
        (@SizeName);
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_GetByID
    @SizeID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        SizeID,
        SizeName
    FROM Sizes
    WHERE SizeID = @SizeID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        SizeID,
        SizeName
    FROM Sizes
    ORDER BY SizeName ASC, SizeID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_Update
    @SizeName NVARCHAR(50),
    @SizeID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Sizes
    SET
        SizeName = @SizeName
    WHERE SizeID = @SizeID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_Delete
    @SizeID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Sizes
    WHERE SizeID = @SizeID;
END;
GO

-- Stored procedures for StaffAccountRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.StaffAccount_GetByID
    @StaffAccountID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        StaffRole,
        IsActive,
        CreatedAt,
        UpdatedAt
    FROM StaffAccounts
    WHERE StaffAccountID = @StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_GetByEmail
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        PasswordHash,
        PasswordSalt,
        PasswordIterations,
        StaffRole,
        IsActive,
        CreatedAt,
        UpdatedAt
    FROM StaffAccounts
    WHERE Email = @Email;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        StaffRole,
        IsActive,
        CreatedAt,
        UpdatedAt
    FROM StaffAccounts
    ORDER BY LastName, FirstName, StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_Update
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Suffix NVARCHAR(20),
    @Email NVARCHAR(256),
    @StaffRole NVARCHAR(20),
    @IsActive BIT,
    @StaffAccountID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE StaffAccounts
    SET
        FirstName = @FirstName,
        MiddleName = @MiddleName,
        LastName = @LastName,
        Suffix = @Suffix,
        Email = @Email,
        StaffRole = @StaffRole,
        IsActive = @IsActive,
        UpdatedAt = SYSUTCDATETIME()
    WHERE StaffAccountID = @StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_Delete
    @StaffAccountID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM StaffAccounts
    WHERE StaffAccountID = @StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_Add
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Suffix NVARCHAR(20),
    @Email NVARCHAR(256),
    @PasswordHash VARBINARY(32),
    @PasswordSalt VARBINARY(16),
    @PasswordIterations INT,
    @StaffRole NVARCHAR(20),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO StaffAccounts
    (
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        PasswordHash,
        PasswordSalt,
        PasswordIterations,
        StaffRole,
        IsActive
    )
    OUTPUT
        INSERTED.StaffAccountID,
        INSERTED.CreatedAt
    VALUES
    (
        @FirstName,
        @MiddleName,
        @LastName,
        @Suffix,
        @Email,
        @PasswordHash,
        @PasswordSalt,
        @PasswordIterations,
        @StaffRole,
        @IsActive
    );
END;
GO
