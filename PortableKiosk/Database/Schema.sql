-- Portable Kiosk database schema
-- Microsoft SQL Server
-- Fresh database setup: run this entire file once; migrations 001-007 are included.
-- Includes product descriptions, takeout table service, AWAITING_PAYMENT,
-- EXPIRED payments, kiosk settings, SERVING (formerly READY), and website QR links.
-- For an existing installation, use the migration scripts instead.

IF DB_ID(N'portable_kiosk_db') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE portable_kiosk_db');
END;
GO

USE portable_kiosk_db;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

CREATE TABLE dbo.KioskSettings
(
    SettingsID INT NOT NULL CONSTRAINT PK_KioskSettings PRIMARY KEY,
    IsAvailable BIT NOT NULL CONSTRAINT DF_KioskSettings_IsAvailable DEFAULT (1),
    PendingPaymentExpiryMinutes INT NOT NULL CONSTRAINT DF_KioskSettings_Expiry DEFAULT (30),
    CONSTRAINT CK_KioskSettings_SingleRow CHECK (SettingsID = 1),
    CONSTRAINT CK_KioskSettings_Expiry CHECK (PendingPaymentExpiryMinutes BETWEEN 1 AND 1440)
);
INSERT INTO dbo.KioskSettings (SettingsID, IsAvailable, PendingPaymentExpiryMinutes)
VALUES (1, 1, 30);

CREATE TABLE dbo.WebsiteQrCode
(
    QrCodeID INT NOT NULL CONSTRAINT PK_WebsiteQrCode PRIMARY KEY,
    WebsiteUrl NVARCHAR(2048) NOT NULL,
    UpdatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_WebsiteQrCode_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_WebsiteQrCode_SingleRow CHECK (QrCodeID = 1),
    CONSTRAINT CK_WebsiteQrCode_Url CHECK (
        LEN(LTRIM(RTRIM(WebsiteUrl))) > 0 AND
        (WebsiteUrl LIKE N'http://%' OR WebsiteUrl LIKE N'https://%'))
);

/* =========================================================
   STAFF ACCOUNTS
   ========================================================= */

CREATE TABLE dbo.StaffAccounts
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

/* =========================================================
   CATEGORIES
   ========================================================= */

CREATE TABLE dbo.Categories
(
    CategoryID INT IDENTITY(1, 1) PRIMARY KEY,

    CategoryName NVARCHAR(100) NOT NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_Categories_CategoryName
        UNIQUE (CategoryName)
);

/* =========================================================
   SIZES
   ========================================================= */

CREATE TABLE dbo.Sizes
(
    SizeID INT IDENTITY(1, 1) PRIMARY KEY,

    SizeName NVARCHAR(50) NOT NULL,

    CONSTRAINT UQ_Sizes_SizeName
        UNIQUE (SizeName)
);

/* =========================================================
   PRODUCTS
   ========================================================= */

CREATE TABLE dbo.Products
(
    ProductID INT IDENTITY(1, 1) PRIMARY KEY,

    CategoryID INT NOT NULL,

    ProductName NVARCHAR(100) NOT NULL,

    ProductDescription NVARCHAR(500) NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID)
);

/* =========================================================
   PRODUCT VARIANTS
   ========================================================= */

CREATE TABLE dbo.ProductVariants
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
        REFERENCES dbo.Products(ProductID),

    CONSTRAINT FK_ProductVariants_Sizes
        FOREIGN KEY (SizeID)
        REFERENCES dbo.Sizes(SizeID)
);

/* =========================================================
   ORDERS
   ========================================================= */

CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1, 1) PRIMARY KEY,

    OrderNumber NVARCHAR(20) NOT NULL,

    OrderType NVARCHAR(10) NOT NULL
        DEFAULT N'DINE_IN',

    FulfillmentMethod NVARCHAR(20) NOT NULL,

    TableNumber NVARCHAR(20) NULL,

    KitchenStatus NVARCHAR(20) NOT NULL
        DEFAULT N'QUEUED',

    ExpiresAt DATETIME2 NULL,

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

    CONSTRAINT CK_Orders_FulfillmentMethod
        CHECK (
            FulfillmentMethod IN (
                N'TABLE_SERVICE',
                N'COUNTER_PICKUP'
            )
        ),

    CONSTRAINT CK_Orders_FulfillmentTable
        CHECK (
            (
                FulfillmentMethod = N'TABLE_SERVICE'
                AND LEN(LTRIM(RTRIM(TableNumber))) > 0
            )
            OR
            (
                FulfillmentMethod = N'COUNTER_PICKUP'
                AND TableNumber IS NULL
            )
        ),

    CONSTRAINT CK_Orders_KitchenStatus
        CHECK (
            KitchenStatus IN (
                N'AWAITING_PAYMENT',
                N'QUEUED',
                N'PREPARING',
                N'SERVING',
                N'COMPLETED',
                N'CANCELLED'
            )
        )
);

/* =========================================================
   PAYMENTS
   ========================================================= */

CREATE TABLE dbo.Payments
(
    PaymentID INT IDENTITY(1, 1) PRIMARY KEY,

    OrderID INT NOT NULL,

    PaymentMethod NVARCHAR(20) NOT NULL,

    PaymentStatus NVARCHAR(20) NOT NULL
        DEFAULT N'PENDING',

    Amount DECIMAL(10, 2) NOT NULL,

    TransactionReference NVARCHAR(100) NULL,

    PaidAt DATETIME2 NULL,

    CreatedAt DATETIME2 NOT NULL
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_Payments_Order
        UNIQUE (OrderID),

    CONSTRAINT CK_Payments_PaymentMethod
        CHECK (
            PaymentMethod IN (
                N'CASHLESS',
                N'CASH_COUNTER'
            )
        ),

    CONSTRAINT CK_Payments_PaymentStatus
        CHECK (
            PaymentStatus IN (
                N'PENDING',
                N'PAID',
                N'FAILED',
                N'CANCELLED',
                N'EXPIRED'
            )
        ),

    CONSTRAINT CK_Payments_Amount
        CHECK (Amount >= 0),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID)
        ON DELETE CASCADE
);

/* =========================================================
   ORDER ITEMS
   ========================================================= */

CREATE TABLE dbo.OrderItems
(
    OrderItemID INT IDENTITY(1, 1) PRIMARY KEY,

    OrderID INT NOT NULL,

    ProductVariantID INT NOT NULL,

    UnitPrice DECIMAL(10, 2) NOT NULL,

    Quantity INT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (UnitPrice >= 0),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_ProductVariants
        FOREIGN KEY (ProductVariantID)
        REFERENCES dbo.ProductVariants(ProductVariantID)
);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
