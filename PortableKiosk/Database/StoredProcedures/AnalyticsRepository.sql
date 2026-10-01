-- Stored procedures for AnalyticsRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadSummary
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT COALESCE(SUM(Amount), 0), COUNT(*)
    FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End;
    SELECT COUNT(*), COALESCE(SUM(CASE WHEN p.PaymentStatus = N'PAID' THEN 1 ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.PaymentStatus = N'PAID' THEN p.Amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.PaymentStatus = N'EXPIRED'
            OR (p.PaymentStatus = N'PENDING' AND o.ExpiresAt IS NOT NULL
                AND o.ExpiresAt <= SYSUTCDATETIME()) THEN 1 ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.PaymentStatus = N'EXPIRED'
            OR (p.PaymentStatus = N'PENDING' AND o.ExpiresAt IS NOT NULL
                AND o.ExpiresAt <= SYSUTCDATETIME()) THEN p.Amount ELSE 0 END), 0)
    FROM Orders o LEFT JOIN Payments p ON p.OrderID = o.OrderID
    WHERE o.CreatedAt >= @Start AND o.CreatedAt < @End;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadTrend
    @Monthly BIT,
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT CASE WHEN @Monthly = 1
        THEN DATEFROMPARTS(YEAR(DATEADD(HOUR, 8, PaidAt)), MONTH(DATEADD(HOUR, 8, PaidAt)), 1)
        ELSE CAST(DATEADD(HOUR, 8, PaidAt) AS date) END AS Bucket, SUM(Amount)
    FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End
    GROUP BY CASE WHEN @Monthly = 1
        THEN DATEFROMPARTS(YEAR(DATEADD(HOUR, 8, PaidAt)), MONTH(DATEADD(HOUR, 8, PaidAt)), 1)
        ELSE CAST(DATEADD(HOUR, 8, PaidAt) AS date) END
    ORDER BY 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadProducts
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT p.ProductName, COALESCE(SUM(oi.Quantity), 0) AS Units,
        COALESCE(SUM(oi.UnitPrice * oi.Quantity), 0) AS Revenue,
        CASE WHEN p.IsAvailable = 1 AND c.IsAvailable = 1
            AND EXISTS (SELECT 1 FROM ProductVariants available
                WHERE available.ProductID = p.ProductID AND available.IsAvailable = 1)
            THEN 1 ELSE 0 END AS OnMenu,
        (SELECT TOP (1) imageVariant.ImagePath
            FROM ProductVariants imageVariant
            WHERE imageVariant.ProductID = p.ProductID
                AND imageVariant.ImagePath IS NOT NULL
                AND LTRIM(RTRIM(imageVariant.ImagePath)) <> N''
            ORDER BY imageVariant.IsAvailable DESC,
                imageVariant.ProductVariantID) AS ImagePath
    FROM Products p
    INNER JOIN Categories c ON c.CategoryID = p.CategoryID
    LEFT JOIN ProductVariants pv ON pv.ProductID = p.ProductID
    LEFT JOIN OrderItems oi ON oi.ProductVariantID = pv.ProductVariantID
        AND EXISTS (SELECT 1 FROM Payments pay WHERE pay.OrderID = oi.OrderID
            AND pay.PaymentStatus = N'PAID' AND pay.PaidAt >= @Start AND pay.PaidAt < @End)
    GROUP BY p.ProductID, p.ProductName, p.IsAvailable, c.IsAvailable;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadCategories
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT c.CategoryName, COALESCE(SUM(oi.Quantity), 0),
        COALESCE(SUM(oi.UnitPrice * oi.Quantity), 0)
    FROM Categories c LEFT JOIN Products p ON p.CategoryID = c.CategoryID
    LEFT JOIN ProductVariants pv ON pv.ProductID = p.ProductID
    LEFT JOIN OrderItems oi ON oi.ProductVariantID = pv.ProductVariantID
        AND EXISTS (SELECT 1 FROM Payments pay WHERE pay.OrderID = oi.OrderID
            AND pay.PaymentStatus = N'PAID' AND pay.PaidAt >= @Start AND pay.PaidAt < @End)
    GROUP BY c.CategoryID, c.CategoryName ORDER BY 3 DESC, c.CategoryName;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Analytics_ReadPaymentMethods
    @Start DATETIME2(7),
    @End DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT PaymentMethod, COUNT(*), SUM(Amount)
    FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End
    GROUP BY PaymentMethod ORDER BY 3 DESC;
END;
GO
