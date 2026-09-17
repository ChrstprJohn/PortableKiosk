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

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_Categories_CategoryName
        UNIQUE (CategoryName),

    CONSTRAINT CK_Categories_DisplayOrder
        CHECK (DisplayOrder >= 0)
);
GO

/* =========================================================
   SIZES
   ========================================================= */

CREATE TABLE Sizes
(
    SizeID INT IDENTITY(1, 1) PRIMARY KEY,

    SizeName NVARCHAR(50) NOT NULL,

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    CONSTRAINT UQ_Sizes_SizeName
        UNIQUE (SizeName),

    CONSTRAINT CK_Sizes_DisplayOrder
        CHECK (DisplayOrder >= 0)
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

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    CONSTRAINT CK_Products_DisplayOrder
        CHECK (DisplayOrder >= 0),

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
   BUNDLES
   ========================================================= */

CREATE TABLE Bundles
(
    BundleID INT IDENTITY(1, 1) PRIMARY KEY,

    BundleName NVARCHAR(100) NOT NULL,

    BasePrice DECIMAL(10, 2) NOT NULL,

    ImagePath NVARCHAR(500) NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    CONSTRAINT CK_Bundles_BasePrice
        CHECK (BasePrice >= 0),

    CONSTRAINT CK_Bundles_DisplayOrder
        CHECK (DisplayOrder >= 0)
);
GO

/* =========================================================
   BUNDLE OPTION GROUPS

   Reusable groups such as:
   - Standard Drinks
   - Standard Sides
   - Premium Drinks
   ========================================================= */

CREATE TABLE BundleOptionGroups
(
    OptionGroupID INT IDENTITY(1, 1) PRIMARY KEY,

    OptionGroupName NVARCHAR(100) NOT NULL,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    CONSTRAINT UQ_BundleOptionGroups_Name
        UNIQUE (OptionGroupName),

    CONSTRAINT CK_BundleOptionGroups_Name
        CHECK (
            LEN(LTRIM(RTRIM(OptionGroupName))) > 0
        ),

    CONSTRAINT CK_BundleOptionGroups_DisplayOrder
        CHECK (DisplayOrder >= 0)
);
GO

/* =========================================================
   BUNDLE OPTION GROUP ITEMS

   Product variants available inside an option group.

   AdditionalPrice is the amount added to the bundle price.
   It is not the standalone ProductVariant price.
   ========================================================= */

CREATE TABLE BundleOptionGroupItems
(
    OptionGroupID INT NOT NULL,

    ProductVariantID INT NOT NULL,

    AdditionalPrice DECIMAL(10, 2) NOT NULL
        DEFAULT 0.00,

    IsAvailable BIT NOT NULL
        DEFAULT 1,

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    CONSTRAINT PK_BundleOptionGroupItems
        PRIMARY KEY (
            OptionGroupID,
            ProductVariantID
        ),

    CONSTRAINT CK_BundleOptionGroupItems_AdditionalPrice
        CHECK (AdditionalPrice >= 0),

    CONSTRAINT CK_BundleOptionGroupItems_DisplayOrder
        CHECK (DisplayOrder >= 0),

    CONSTRAINT FK_BundleOptionGroupItems_Groups
        FOREIGN KEY (OptionGroupID)
        REFERENCES BundleOptionGroups(OptionGroupID)
        ON DELETE CASCADE,

    CONSTRAINT FK_BundleOptionGroupItems_ProductVariants
        FOREIGN KEY (ProductVariantID)
        REFERENCES ProductVariants(ProductVariantID)
);
GO

/* =========================================================
   BUNDLE SLOTS

   Every bundle is divided into slots such as:
   - Main
   - Drink
   - Side

   A slot is either:

   1. Fixed:
      FixedProductVariantID is populated.
      OptionGroupID and DefaultProductVariantID are NULL.

   2. Choice:
      OptionGroupID and DefaultProductVariantID are populated.
      FixedProductVariantID is NULL.

   The composite foreign key guarantees that the default
   product variant belongs to the selected option group.
   ========================================================= */

CREATE TABLE BundleSlots
(
    BundleSlotID INT IDENTITY(1, 1) PRIMARY KEY,

    BundleID INT NOT NULL,

    SlotName NVARCHAR(100) NOT NULL,

    FixedProductVariantID INT NULL,

    OptionGroupID INT NULL,

    DefaultProductVariantID INT NULL,

    Quantity INT NOT NULL
        DEFAULT 1,

    IsRequired BIT NOT NULL
        DEFAULT 1,

    DisplayOrder INT NOT NULL
        DEFAULT 0,

    CONSTRAINT UQ_BundleSlots_Bundle_Name
        UNIQUE (
            BundleID,
            SlotName
        ),

    CONSTRAINT CK_BundleSlots_Name
        CHECK (
            LEN(LTRIM(RTRIM(SlotName))) > 0
        ),

    CONSTRAINT CK_BundleSlots_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_BundleSlots_DisplayOrder
        CHECK (DisplayOrder >= 0),

    CONSTRAINT CK_BundleSlots_Configuration
        CHECK (
            (
                FixedProductVariantID IS NOT NULL
                AND OptionGroupID IS NULL
                AND DefaultProductVariantID IS NULL
            )
            OR
            (
                FixedProductVariantID IS NULL
                AND OptionGroupID IS NOT NULL
                AND DefaultProductVariantID IS NOT NULL
            )
        ),

    CONSTRAINT FK_BundleSlots_Bundles
        FOREIGN KEY (BundleID)
        REFERENCES Bundles(BundleID)
        ON DELETE CASCADE,

    CONSTRAINT FK_BundleSlots_FixedProductVariant
        FOREIGN KEY (FixedProductVariantID)
        REFERENCES ProductVariants(ProductVariantID),

    CONSTRAINT FK_BundleSlots_DefaultOption
        FOREIGN KEY (
            OptionGroupID,
            DefaultProductVariantID
        )
        REFERENCES BundleOptionGroupItems (
            OptionGroupID,
            ProductVariantID
        )
);
GO

/* =========================================================
   BUNDLE CONFIGURATION INDEXES
   ========================================================= */

CREATE INDEX IX_BundleOptionGroupItems_ProductVariant
    ON BundleOptionGroupItems(ProductVariantID);
GO

CREATE INDEX IX_BundleOptionGroupItems_Display
    ON BundleOptionGroupItems(
        OptionGroupID,
        DisplayOrder
    );
GO

CREATE INDEX IX_BundleSlots_Bundle_Display
    ON BundleSlots(
        BundleID,
        DisplayOrder
    );
GO

CREATE INDEX IX_BundleSlots_FixedProductVariant
    ON BundleSlots(FixedProductVariantID);
GO

CREATE INDEX IX_BundleSlots_DefaultOption
    ON BundleSlots(
        OptionGroupID,
        DefaultProductVariantID
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

    ProductVariantID INT NULL,

    BundleID INT NULL,

    ItemName NVARCHAR(100) NOT NULL,

    SizeName NVARCHAR(50) NULL,

    UnitPrice DECIMAL(10, 2) NOT NULL,

    Quantity INT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (UnitPrice >= 0),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_OrderItems_Type
        CHECK (
            (
                ProductVariantID IS NOT NULL
                AND BundleID IS NULL
            )
            OR
            (
                ProductVariantID IS NULL
                AND BundleID IS NOT NULL
            )
        ),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_ProductVariants
        FOREIGN KEY (ProductVariantID)
        REFERENCES ProductVariants(ProductVariantID),

    CONSTRAINT FK_OrderItems_Bundles
        FOREIGN KEY (BundleID)
        REFERENCES Bundles(BundleID)
);
GO

/* =========================================================
   ORDER ITEM BUNDLE COMPONENTS

   This table stores an order-time snapshot of each selected
   bundle slot. It does not rely on the current bundle setup.

   Example:
   SlotName: Drink
   ComponentProductName: Coke
   ComponentSizeName: Large
   AdditionalPrice: 20.00
   ========================================================= */

CREATE TABLE OrderItemBundleComponents
(
    OrderItemBundleComponentID
        INT IDENTITY(1, 1) PRIMARY KEY,

    OrderItemID INT NOT NULL,

    SlotName NVARCHAR(100) NOT NULL,

    ComponentProductVariantID INT NOT NULL,

    ComponentProductName NVARCHAR(100) NOT NULL,

    ComponentSizeName NVARCHAR(50) NULL,

    QuantityPerBundle INT NOT NULL
        DEFAULT 1,

    AdditionalPrice DECIMAL(10, 2) NOT NULL
        DEFAULT 0.00,

    CONSTRAINT CK_OrderItemBundleComponents_SlotName
        CHECK (
            LEN(LTRIM(RTRIM(SlotName))) > 0
        ),

    CONSTRAINT CK_OrderItemBundleComponents_Quantity
        CHECK (QuantityPerBundle > 0),

    CONSTRAINT CK_OrderItemBundleComponents_AdditionalPrice
        CHECK (AdditionalPrice >= 0),

    CONSTRAINT FK_OrderItemBundleComponents_OrderItems
        FOREIGN KEY (OrderItemID)
        REFERENCES OrderItems(OrderItemID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItemBundleComponents_ProductVariants
        FOREIGN KEY (ComponentProductVariantID)
        REFERENCES ProductVariants(ProductVariantID)
);
GO

CREATE INDEX IX_OrderItemBundleComponents_OrderItem
    ON OrderItemBundleComponents(OrderItemID);
GO