-- Kiosk schema with dedicated Category, Size, and Bundle entities for Microsoft SQL Server

IF DB_ID(N'portable_kiosk_db') IS NULL
    EXEC(N'CREATE DATABASE portable_kiosk_db');
GO

USE portable_kiosk_db;
GO

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1, 1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    DisplayOrder INT NOT NULL DEFAULT 0,
    IsAvailable BIT NOT NULL DEFAULT 1,
    CONSTRAINT CK_Categories_DisplayOrder CHECK (DisplayOrder >= 0)
);

CREATE TABLE Sizes
(
    SizeID INT IDENTITY(1, 1) PRIMARY KEY,
    SizeName NVARCHAR(50) NOT NULL UNIQUE,
    DisplayOrder INT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Sizes_DisplayOrder CHECK (DisplayOrder >= 0)
);

CREATE TABLE Products
(
    ProductID INT IDENTITY(1, 1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    DisplayOrder INT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Products_DisplayOrder CHECK (DisplayOrder >= 0),
    CONSTRAINT FK_Products_Categories 
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE ProductVariants
(
    ProductVariantID INT IDENTITY(1, 1) PRIMARY KEY,
    ProductID INT NOT NULL,
    SizeID INT NULL, -- NULL allows for products without sizes (e.g., single-item goods)
    Price DECIMAL(10, 2) NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    CONSTRAINT UQ_ProductVariants_Product_Size UNIQUE (ProductID, SizeID),
    CONSTRAINT CK_ProductVariants_Price CHECK (Price >= 0),
    CONSTRAINT FK_ProductVariants_Products 
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_ProductVariants_Sizes 
        FOREIGN KEY (SizeID) REFERENCES Sizes(SizeID)
);

CREATE TABLE Bundles
(
    BundleID INT IDENTITY(1, 1) PRIMARY KEY,
    BundleName NVARCHAR(100) NOT NULL,
    BasePrice DECIMAL(10, 2) NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    DisplayOrder INT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Bundles_BasePrice CHECK (BasePrice >= 0),
    CONSTRAINT CK_Bundles_DisplayOrder CHECK (DisplayOrder >= 0)
);

CREATE TABLE BundleComponents
(
    BundleID INT NOT NULL,
    ComponentProductVariantID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    IsDefault BIT NOT NULL DEFAULT 1,
    AdditionalPrice DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_BundleComponents PRIMARY KEY (BundleID, ComponentProductVariantID),
    CONSTRAINT CK_BundleComponents_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_BundleComponents_AdditionalPrice CHECK (AdditionalPrice >= 0),
    CONSTRAINT FK_BundleComponents_Bundles 
        FOREIGN KEY (BundleID) REFERENCES Bundles(BundleID) ON DELETE CASCADE,
    CONSTRAINT FK_BundleComponents_ProductVariants 
        FOREIGN KEY (ComponentProductVariantID) REFERENCES ProductVariants(ProductVariantID)
);

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1, 1) PRIMARY KEY,
    OrderNumber NVARCHAR(20) NOT NULL UNIQUE,
    OrderType NVARCHAR(10) NOT NULL DEFAULT N'DINE_IN',
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT N'UNPAID',
    KitchenStatus NVARCHAR(20) NOT NULL DEFAULT N'NONE',
    ExpiresAt DATETIME2 NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Orders_OrderType
        CHECK (OrderType IN (N'DINE_IN', N'TAKEOUT')),
    CONSTRAINT CK_Orders_PaymentStatus 
        CHECK (PaymentStatus IN (N'UNPAID', N'PAID')),
    CONSTRAINT CK_Orders_KitchenStatus 
        CHECK (KitchenStatus IN (N'NONE', N'PREPARING', N'SERVING'))
);

CREATE TABLE OrderItems
(
    OrderItemID INT IDENTITY(1, 1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductVariantID INT NULL,
    BundleID INT NULL,
    ItemName NVARCHAR(100) NOT NULL,
    SizeName NVARCHAR(50) NULL, -- Snapshot of size string at time of order
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_Type 
        CHECK ((ProductVariantID IS NOT NULL AND BundleID IS NULL) OR 
               (ProductVariantID IS NULL AND BundleID IS NOT NULL)),
    CONSTRAINT FK_OrderItems_Orders 
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_ProductVariants 
        FOREIGN KEY (ProductVariantID) REFERENCES ProductVariants(ProductVariantID),
    CONSTRAINT FK_OrderItems_Bundles 
        FOREIGN KEY (BundleID) REFERENCES Bundles(BundleID)
);

CREATE TABLE OrderItemBundleComponents
(
    OrderItemBundleComponentID INT IDENTITY(1, 1) PRIMARY KEY,
    OrderItemID INT NOT NULL,
    ComponentProductVariantID INT NOT NULL,
    ComponentProductName NVARCHAR(100) NOT NULL,
    ComponentSizeName NVARCHAR(50) NULL, -- Snapshot of size string at time of order
    QuantityPerBundle INT NOT NULL DEFAULT 1,
    AdditionalPrice DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT CK_OrderItemBundleComponents_Quantity CHECK (QuantityPerBundle > 0),
    CONSTRAINT CK_OrderItemBundleComponents_AdditionalPrice CHECK (AdditionalPrice >= 0),
    CONSTRAINT FK_OrderItemBundleComponents_OrderItems 
        FOREIGN KEY (OrderItemID) REFERENCES OrderItems(OrderItemID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItemBundleComponents_ProductVariants 
        FOREIGN KEY (ComponentProductVariantID) REFERENCES ProductVariants(ProductVariantID)
);
GO
