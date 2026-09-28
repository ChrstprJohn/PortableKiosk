USE portable_kiosk_db;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /*
       Clear all existing application data first. Transaction rows are
       deleted before catalog rows because OrderItems reference variants.
       Staff accounts are also removed; this reset leaves only the newly
       seeded catalog data.
    */
    IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL
        DELETE FROM dbo.OrderItems;

    IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL
        DELETE FROM dbo.Payments;

    IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL
        DELETE FROM dbo.Orders;

    IF OBJECT_ID(N'dbo.StaffAccounts', N'U') IS NOT NULL
        DELETE FROM dbo.StaffAccounts;

    /* Delete catalog child rows before parent rows to respect foreign keys. */
    DELETE FROM dbo.ProductVariants;
    DELETE FROM dbo.Products;
    DELETE FROM dbo.Categories;
    DELETE FROM dbo.Sizes;

    /* Start all emptied identity values at 1. */
    IF OBJECT_ID(N'dbo.StaffAccounts', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.StaffAccounts', RESEED, 0) WITH NO_INFOMSGS;
    IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.OrderItems', RESEED, 0) WITH NO_INFOMSGS;
    IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.Payments', RESEED, 0) WITH NO_INFOMSGS;
    IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.Orders', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT (N'dbo.ProductVariants', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT (N'dbo.Products', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT (N'dbo.Categories', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT (N'dbo.Sizes', RESEED, 0) WITH NO_INFOMSGS;

    /* Insert sizes one at a time to preserve the requested display order. */
    INSERT INTO dbo.Sizes (SizeName) VALUES (N'Regular');
    INSERT INTO dbo.Sizes (SizeName) VALUES (N'Medium');
    INSERT INTO dbo.Sizes (SizeName) VALUES (N'Large');

    /* Insert categories one at a time to keep a predictable order. */
    INSERT INTO dbo.Categories (CategoryName, IsAvailable)
    VALUES (N'Burgers', 1);
    INSERT INTO dbo.Categories (CategoryName, IsAvailable)
    VALUES (N'Chicken', 1);
    INSERT INTO dbo.Categories (CategoryName, IsAvailable)
    VALUES (N'Sides', 1);
    INSERT INTO dbo.Categories (CategoryName, IsAvailable)
    VALUES (N'Drinks', 1);
    INSERT INTO dbo.Categories (CategoryName, IsAvailable)
    VALUES (N'Desserts', 1);

    /*
       Every product below receives Regular, Medium, and Large variants.
       Prices are in the same currency unit used by the application.
    */
    DECLARE @CatalogSeed TABLE
    (
        SeedOrder INT NOT NULL PRIMARY KEY,
        CategoryName NVARCHAR(100) NOT NULL,
        ProductName NVARCHAR(100) NOT NULL,
        ProductDescription NVARCHAR(500) NOT NULL,
        RegularPrice DECIMAL(10, 2) NOT NULL,
        MediumPrice DECIMAL(10, 2) NOT NULL,
        LargePrice DECIMAL(10, 2) NOT NULL
    );

    INSERT INTO @CatalogSeed
    (
        SeedOrder,
        CategoryName,
        ProductName,
        ProductDescription,
        RegularPrice,
        MediumPrice,
        LargePrice
    )
    VALUES
        (1,  N'Burgers', N'Classic Burger', N'Grilled beef patty with lettuce, tomato, and house sauce.', 89.00, 109.00, 129.00),
        (2,  N'Burgers', N'Cheeseburger', N'Grilled beef patty topped with melted cheese and house sauce.', 99.00, 119.00, 139.00),
        (3,  N'Burgers', N'Bacon Burger', N'Grilled beef patty with crispy bacon, cheese, and house sauce.', 129.00, 149.00, 169.00),
        (4,  N'Chicken', N'Crispy Chicken Sandwich', N'Crispy chicken fillet with lettuce and creamy sauce.', 99.00, 119.00, 139.00),
        (5,  N'Chicken', N'Chicken Tenders', N'Golden chicken tenders served with dipping sauce.', 109.00, 139.00, 169.00),
        (6,  N'Chicken', N'Buffalo Wings', N'Crispy chicken wings tossed in tangy buffalo sauce.', 129.00, 159.00, 189.00),
        (7,  N'Sides', N'French Fries', N'Crispy golden fries lightly seasoned.', 39.00, 59.00, 79.00),
        (8,  N'Sides', N'Onion Rings', N'Crunchy battered onion rings.', 49.00, 69.00, 89.00),
        (9,  N'Sides', N'Mozzarella Sticks', N'Breaded mozzarella sticks served with marinara sauce.', 69.00, 99.00, 129.00),
        (10, N'Drinks', N'Iced Tea', N'Freshly brewed, chilled iced tea.', 29.00, 39.00, 49.00),
        (11, N'Drinks', N'Soft Drink', N'Chilled carbonated soft drink.', 29.00, 39.00, 49.00),
        (12, N'Drinks', N'Fresh Lemonade', N'Cold lemonade made with fresh lemon.', 39.00, 49.00, 59.00),
        (13, N'Desserts', N'Vanilla Sundae', N'Vanilla soft serve topped with chocolate syrup.', 49.00, 69.00, 89.00),
        (14, N'Desserts', N'Chocolate Brownie', N'Rich chocolate brownie served warm.', 59.00, 79.00, 99.00),
        (15, N'Desserts', N'Mango Float', N'Creamy mango dessert layered with graham crackers.', 59.00, 79.00, 99.00);

    /* Insert one product at a time so ProductID order follows SeedOrder. */
    DECLARE @NextProductOrder INT = 1;
    DECLARE @LastProductOrder INT = (SELECT MAX(SeedOrder) FROM @CatalogSeed);
    DECLARE @CategoryName NVARCHAR(100);
    DECLARE @ProductName NVARCHAR(100);
    DECLARE @ProductDescription NVARCHAR(500);
    DECLARE @CategoryID INT;

    WHILE @NextProductOrder <= @LastProductOrder
    BEGIN
        SELECT
            @CategoryName = CategoryName,
            @ProductName = ProductName,
            @ProductDescription = ProductDescription
        FROM @CatalogSeed
        WHERE SeedOrder = @NextProductOrder;

        SELECT @CategoryID = CategoryID
        FROM dbo.Categories
        WHERE CategoryName = @CategoryName;

        INSERT INTO dbo.Products
        (
            CategoryID,
            ProductName,
            ProductDescription,
            IsAvailable
        )
        VALUES
        (
            @CategoryID,
            @ProductName,
            @ProductDescription,
            1
        );

        SET @NextProductOrder += 1;
    END;

    /* Create exactly three size variants for every seeded product. */
    INSERT INTO dbo.ProductVariants
    (
        ProductID,
        SizeID,
        Price,
        ImagePath,
        IsAvailable
    )
    SELECT
        p.ProductID,
        s.SizeID,
        v.Price,
        CONCAT(
            N'~/Content/images/products/',
            LOWER(REPLACE(seed.ProductName, N' ', N'-')),
            N'/',
            LOWER(REPLACE(seed.ProductName, N' ', N'-')),
            N'-',
            LOWER(REPLACE(v.SizeName, N' ', N'-')),
            N'.jpg'
        ),
        1
    FROM @CatalogSeed AS seed
    INNER JOIN dbo.Categories AS c
        ON c.CategoryName = seed.CategoryName
    INNER JOIN dbo.Products AS p
        ON p.CategoryID = c.CategoryID
       AND p.ProductName = seed.ProductName
    CROSS APPLY
    (
        VALUES
            (N'Regular', seed.RegularPrice),
            (N'Medium', seed.MediumPrice),
            (N'Large', seed.LargePrice)
    ) AS v(SizeName, Price)
    INNER JOIN dbo.Sizes AS s
        ON s.SizeName = v.SizeName;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

/* Review the populated catalog after execution. */
SELECT
    c.CategoryName,
    p.ProductName,
    s.SizeName,
    pv.Price
FROM dbo.Categories AS c
INNER JOIN dbo.Products AS p
    ON p.CategoryID = c.CategoryID
INNER JOIN dbo.ProductVariants AS pv
    ON pv.ProductID = p.ProductID
INNER JOIN dbo.Sizes AS s
    ON s.SizeID = pv.SizeID
ORDER BY
    c.CategoryID,
    p.ProductID,
    s.SizeID;
GO
