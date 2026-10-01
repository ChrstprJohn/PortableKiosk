-- Stored procedures for PaymentRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Payment_GetByID
    @ID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        PaymentID,
        OrderID,
        PaymentMethod,
        PaymentStatus,
        Amount,
        TransactionReference,
        PaidAt,
        CreatedAt
    FROM Payments
    WHERE PaymentID = @ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_GetByOrderID
    @ID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        PaymentID,
        OrderID,
        PaymentMethod,
        PaymentStatus,
        Amount,
        TransactionReference,
        PaidAt,
        CreatedAt
    FROM Payments
    WHERE OrderID = @ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        PaymentID,
        OrderID,
        PaymentMethod,
        PaymentStatus,
        Amount,
        TransactionReference,
        PaidAt,
        CreatedAt
    FROM Payments
    ORDER BY CreatedAt DESC, PaymentID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Update
    @OrderID INT,
    @PaymentMethod NVARCHAR(20),
    @PaymentStatus NVARCHAR(20),
    @Amount DECIMAL(10,2),
    @TransactionReference NVARCHAR(100),
    @PaidAt DATETIME2(7),
    @PaymentID INT,
    @ExpiryMinutes INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE p
    SET
        OrderID = @OrderID,
        PaymentMethod = @PaymentMethod,
        PaymentStatus = @PaymentStatus,
        Amount = @Amount,
        TransactionReference = @TransactionReference,
        PaidAt = @PaidAt
    FROM Payments p
    WHERE p.PaymentID = @PaymentID
        AND NOT (
            @PaymentStatus = N'PAID'
            AND p.PaymentStatus <> N'PAID'
            AND p.PaymentMethod = N'CASH_COUNTER'
            AND EXISTS (
                SELECT 1
                FROM Orders o
                WHERE o.OrderID = p.OrderID
                    AND COALESCE(
                        o.ExpiresAt,
                        DATEADD(
                            MINUTE,
                            @ExpiryMinutes,
                            o.CreatedAt)) <= SYSUTCDATETIME()
            )
        );
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Update_QueueOrder
    @OrderID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Orders
    SET KitchenStatus = N'QUEUED'
    WHERE OrderID = @OrderID
        AND KitchenStatus = N'AWAITING_PAYMENT';
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Delete
    @PaymentID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Payments
    WHERE PaymentID = @PaymentID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Payment_Add
    @OrderID INT,
    @PaymentMethod NVARCHAR(20),
    @PaymentStatus NVARCHAR(20),
    @Amount DECIMAL(10,2),
    @TransactionReference NVARCHAR(100),
    @PaidAt DATETIME2(7)
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Payments
        (
            OrderID,
            PaymentMethod,
            PaymentStatus,
            Amount,
            TransactionReference,
            PaidAt
        )
    OUTPUT INSERTED.PaymentID
    VALUES
        (
            @OrderID,
            @PaymentMethod,
            @PaymentStatus,
            @Amount,
            @TransactionReference,
            @PaidAt
        );
END;
GO
