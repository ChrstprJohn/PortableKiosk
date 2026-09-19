-- Portable Kiosk database schema
-- Microsoft SQL Server

IF DB_ID(N'portable_kiosk_db') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE portable_kiosk_db');
END;
GO

USE portable_kiosk_db;
GO

/* =========================================================
   STAFF ACCOUNTS
   ========================================================= */

CREATE TABLE StaffAccounts
(
    StaffAccountID INT IDENTITY(1, 1) PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,

    MiddleName NVARCHAR(50) NULL,

    LastName NVARCHAR(50) NOT NULL,

    Suffix NVARCHAR(20) NULL,

    Email NVARCHAR(256) NOT NULL,

    PasswordHash VARBINARY(32) NOT NULL,

    PasswordSalt VARBINARY(16) NOT NULL,

    PasswordIterations INT NOT NULL
        DEFAULT 100000,

    StaffRole NVARCHAR(20) NOT NULL
        DEFAULT N'CREW',

    IsActive BIT NOT NULL
        DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL
        DEFAULT SYSUTCDATETIME(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT UQ_StaffAccounts_Email
        UNIQUE (Email),

    CONSTRAINT CK_StaffAccounts_FirstName
        CHECK (
            LEN(LTRIM(RTRIM(FirstName))) > 0
        ),

    CONSTRAINT CK_StaffAccounts_LastName
        CHECK (
            LEN(LTRIM(RTRIM(LastName))) > 0
        ),

    CONSTRAINT CK_StaffAccounts_PasswordIterations
        CHECK (PasswordIterations > 0),

    CONSTRAINT CK_StaffAccounts_StaffRole
        CHECK (
            StaffRole IN (
                N'ADMIN',
                N'CREW'
            )
        )
);
GO

/* =========================================================
   CATEGORIES
   ========================================================= */

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1, 1) PRIMARY KEY,

    CategoryName NVARCHAR(100) NOT NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_Categories_CategoryName
        UNIQUE (CategoryName)
);
GO

/* =========================================================
   SIZES
   ========================================================= */

CREATE TABLE Sizes
(
    SizeID INT IDENTITY(1, 1) PRIMARY KEY,

    SizeName NVARCHAR(50) NOT NULL,

    CONSTRAINT UQ_Sizes_SizeName
        UNIQUE (SizeName)
);
GO

/* =========================================================
   PRODUCTS
   ========================================================= */

CREATE TABLE Products
(
    ProductID INT IDENTITY(1, 1) PRIMARY KEY,

    CategoryID INT NOT NULL,

    ProductName NVARCHAR(100) NOT NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);
GO

/* =========================================================
   PRODUCT VARIANTS
   ========================================================= */

CREATE TABLE ProductVariants
(
    ProductVariantID INT IDENTITY(1, 1) PRIMARY KEY,

    ProductID INT NOT NULL,

    SizeID INT NULL,

    Price DECIMAL(10, 2) NOT NULL,

    ImagePath NVARCHAR(500) NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_ProductVariants_Product_Size
        UNIQUE (ProductID, SizeID),

    CONSTRAINT CK_ProductVariants_Price
        CHECK (Price >= 0),

    CONSTRAINT FK_ProductVariants_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_ProductVariants_Sizes
        FOREIGN KEY (SizeID)
        REFERENCES Sizes(SizeID)
);
GO

/* =========================================================
   ORDERS
   ========================================================= */

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1, 1) PRIMARY KEY,

    OrderNumber NVARCHAR(20) NOT NULL,

    OrderType NVARCHAR(10) NOT NULL
        DEFAULT N'DINE_IN',

    PaymentStatus NVARCHAR(20) NOT NULL
        DEFAULT N'UNPAID',

    KitchenStatus NVARCHAR(20) NOT NULL
        DEFAULT N'NONE',

    ExpiresAt DATETIME2 NOT NULL,

    CreatedAt DATETIME2 NOT NULL
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_Orders_OrderNumber
        UNIQUE (OrderNumber),

    CONSTRAINT CK_Orders_OrderType
        CHECK (
            OrderType IN (
                N'DINE_IN',
                N'TAKEOUT'
            )
        ),

    CONSTRAINT CK_Orders_PaymentStatus
        CHECK (
            PaymentStatus IN (
                N'UNPAID',
                N'PAID'
            )
        ),

    CONSTRAINT CK_Orders_KitchenStatus
        CHECK (
            KitchenStatus IN (
                N'NONE',
                N'PREPARING',
                N'SERVING'
            )
        )
);
GO

/* =========================================================
   ORDER ITEMS
   ========================================================= */

CREATE TABLE OrderItems
(
    OrderItemID INT IDENTITY(1, 1) PRIMARY KEY,

    OrderID INT NOT NULL,

    ProductVariantID INT NOT NULL,

    ItemName NVARCHAR(100) NOT NULL,

    SizeName NVARCHAR(50) NULL,

    UnitPrice DECIMAL(10, 2) NOT NULL,

    Quantity INT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (UnitPrice >= 0),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_ProductVariants
        FOREIGN KEY (ProductVariantID)
        REFERENCES ProductVariants(ProductVariantID)
);
GO
