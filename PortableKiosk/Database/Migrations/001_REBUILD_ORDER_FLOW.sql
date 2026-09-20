USE portable_kiosk_db;
GO

/* No order data exists yet, so rebuild only the order tables. */

/* Drop dependent tables first so their foreign keys do not block Orders. */
IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL
    DROP TABLE dbo.Payments;

IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL
    DROP TABLE dbo.OrderItems;

IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL
    DROP TABLE dbo.Orders;

/* Remove this only if an earlier version of the update created it. */
IF OBJECT_ID(N'dbo.DiningTables', N'U') IS NOT NULL
    DROP TABLE dbo.DiningTables;
GO

IF COL_LENGTH(N'dbo.Products', N'ProductDescription') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD ProductDescription NVARCHAR(500) NULL;
END;
GO

CREATE TABLE Orders
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
                N'QUEUED',
                N'PREPARING',
                N'READY',
                N'COMPLETED',
                N'CANCELLED'
            )
        )
);
GO

CREATE TABLE Payments
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
                N'CANCELLED'
            )
        ),

    CONSTRAINT CK_Payments_Amount
        CHECK (Amount >= 0),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);
GO

CREATE TABLE OrderItems
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
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_ProductVariants
        FOREIGN KEY (ProductVariantID)
        REFERENCES ProductVariants(ProductVariantID)
);
GO
