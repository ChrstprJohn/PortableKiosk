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
