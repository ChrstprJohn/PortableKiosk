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
