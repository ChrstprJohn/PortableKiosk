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
