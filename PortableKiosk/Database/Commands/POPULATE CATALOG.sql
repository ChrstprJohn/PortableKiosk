USE portable_kiosk_db;
GO

INSERT INTO Sizes
(
    SizeName
)
VALUES
    (N'Regular'),
    (N'Medium'),
    (N'Large');
GO

INSERT INTO Categories
(
    CategoryName,
    IsAvailable
)
VALUES
    (N'Burgers', 1),
    (N'Chicken', 1),
    (N'Sides', 1),
    (N'Drinks', 1),
    (N'Desserts', 1);
GO

INSERT INTO Products
(
    CategoryID,
    ProductName,
    IsAvailable
)
VALUES
    (1, N'Classic Burger', 1),
    (1, N'Cheeseburger', 1),
    (2, N'Fried Chicken', 1),
    (3, N'French Fries', 1),
    (3, N'Onion Rings', 1),
    (4, N'Iced Tea', 1),
    (4, N'Soft Drink', 1),
    (4, N'Bottled Water', 1),
    (5, N'Sundae', 1);
GO

INSERT INTO ProductVariants
(
    ProductID,
    SizeID,
    Price,
    ImagePath,
    IsAvailable
)
VALUES
    (1, NULL, 69.00, NULL, 1),
    (2, NULL, 89.00, NULL, 1),
    (3, NULL, 99.00, NULL, 1),
    (4, 1, 45.00, NULL, 1),
    (4, 2, 60.00, NULL, 1),
    (4, 3, 75.00, NULL, 1),
    (5, 1, 55.00, NULL, 1),
    (5, 3, 80.00, NULL, 1),
    (6, 1, 35.00, NULL, 1),
    (6, 2, 45.00, NULL, 1),
    (6, 3, 55.00, NULL, 1),
    (7, 1, 35.00, NULL, 1),
    (7, 2, 45.00, NULL, 1),
    (7, 3, 55.00, NULL, 1),
    (8, NULL, 30.00, NULL, 1),
    (9, 1, 45.00, NULL, 1),
    (9, 3, 65.00, NULL, 1);
GO
