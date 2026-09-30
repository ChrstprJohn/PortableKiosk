-- Run this entire script to add the catalog, including 20 new products.
-- Safe to rerun: existing products, variants, images, orders, and staff are preserved.
-- Result on a fresh database: 35 products with 105 Regular/Medium/Large variants.
USE portable_kiosk_db;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* Add missing catalog entries only. Preserve orders, staff, and existing images. */
    /* Insert sizes one at a time to preserve the requested display order. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Sizes WHERE SizeName = N'Regular')
        INSERT INTO dbo.Sizes (SizeName) VALUES (N'Regular');
    IF NOT EXISTS (SELECT 1 FROM dbo.Sizes WHERE SizeName = N'Medium')
        INSERT INTO dbo.Sizes (SizeName) VALUES (N'Medium');
    IF NOT EXISTS (SELECT 1 FROM dbo.Sizes WHERE SizeName = N'Large')
        INSERT INTO dbo.Sizes (SizeName) VALUES (N'Large');

    /* Insert categories one at a time to keep a predictable order. */
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Burgers')
        INSERT INTO dbo.Categories (CategoryName, IsAvailable) VALUES (N'Burgers', 1);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Chicken')
        INSERT INTO dbo.Categories (CategoryName, IsAvailable) VALUES (N'Chicken', 1);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Sides')
        INSERT INTO dbo.Categories (CategoryName, IsAvailable) VALUES (N'Sides', 1);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Drinks')
        INSERT INTO dbo.Categories (CategoryName, IsAvailable) VALUES (N'Drinks', 1);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Desserts')
        INSERT INTO dbo.Categories (CategoryName, IsAvailable) VALUES (N'Desserts', 1);

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
        (15, N'Desserts', N'Mango Float', N'Creamy mango dessert layered with graham crackers.', 59.00, 79.00, 99.00),
        (16, N'Burgers', N'BBQ Burger', N'Beef patty with smoky barbecue sauce, cheddar, and crispy onions.', 119.00, 149.00, 179.00),
        (17, N'Burgers', N'Mushroom Swiss Burger', N'Beef patty with sauteed mushrooms and melted Swiss cheese.', 129.00, 159.00, 189.00),
        (18, N'Burgers', N'Spicy Jalapeno Burger', N'Beef patty with jalapenos, pepper jack cheese, and spicy sauce.', 119.00, 149.00, 179.00),
        (19, N'Burgers', N'Veggie Burger', N'Vegetable patty with lettuce, tomato, and creamy herb sauce.', 99.00, 129.00, 159.00),
        (20, N'Chicken', N'Garlic Parmesan Wings', N'Crispy wings coated with garlic butter and parmesan.', 139.00, 169.00, 199.00),
        (21, N'Chicken', N'Honey Soy Chicken', N'Crispy chicken bites glazed with honey soy sauce.', 119.00, 149.00, 179.00),
        (22, N'Chicken', N'Chicken Nuggets', N'Golden bite-sized chicken nuggets with dipping sauce.', 89.00, 119.00, 149.00),
        (23, N'Chicken', N'Spicy Chicken Bites', N'Crispy chicken bites tossed in a spicy red glaze.', 109.00, 139.00, 169.00),
        (24, N'Sides', N'Potato Wedges', N'Crispy seasoned potato wedges with garlic dip.', 49.00, 69.00, 89.00),
        (25, N'Sides', N'Cheese Fries', N'Golden fries topped with creamy cheddar sauce.', 59.00, 89.00, 119.00),
        (26, N'Sides', N'Coleslaw', N'Fresh shredded cabbage and carrots in creamy dressing.', 39.00, 59.00, 79.00),
        (27, N'Sides', N'Mac and Cheese', N'Tender macaroni in a rich cheddar cheese sauce.', 69.00, 99.00, 129.00),
        (28, N'Drinks', N'Iced Coffee', N'Chilled coffee with milk served over ice.', 59.00, 79.00, 99.00),
        (29, N'Drinks', N'Strawberry Milkshake', N'Creamy strawberry milkshake topped with whipped cream.', 69.00, 89.00, 109.00),
        (30, N'Drinks', N'Mango Smoothie', N'Thick blended mango drink made with ripe mangoes.', 69.00, 89.00, 109.00),
        (31, N'Drinks', N'Calamansi Cooler', N'Refreshing calamansi citrus drink served over ice.', 39.00, 49.00, 59.00),
        (32, N'Desserts', N'Strawberry Sundae', N'Vanilla soft serve topped with strawberry sauce.', 59.00, 79.00, 99.00),
        (33, N'Desserts', N'Caramel Sundae', N'Vanilla soft serve topped with caramel sauce.', 59.00, 79.00, 99.00),
        (34, N'Desserts', N'Cookies and Cream', N'Creamy cookies-and-cream dessert with crushed chocolate cookies.', 69.00, 89.00, 109.00),
        (35, N'Desserts', N'Chocolate Mousse', N'Light chocolate mousse topped with chocolate shavings.', 69.00, 89.00, 109.00);

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

        IF NOT EXISTS (
            SELECT 1 FROM dbo.Products
            WHERE CategoryID = @CategoryID AND ProductName = @ProductName
        )
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

    /* Add missing size variants; keep existing prices and image paths unchanged. */
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
        ON s.SizeName = v.SizeName
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.ProductVariants AS existing
        WHERE existing.ProductID = p.ProductID AND existing.SizeID = s.SizeID
    );

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
