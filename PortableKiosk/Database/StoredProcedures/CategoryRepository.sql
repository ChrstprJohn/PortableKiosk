-- Stored procedures for CategoryRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Category_Add
    @CategoryName NVARCHAR(100),
    @IsAvailable BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Categories
        (CategoryName, IsAvailable)
    OUTPUT INSERTED.CategoryID
    VALUES
        (@CategoryName, @IsAvailable);
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_GetByID
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        CategoryID,
        CategoryName,
        IsAvailable
    FROM Categories
    WHERE CategoryID = @CategoryID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        CategoryID,
        CategoryName,
        IsAvailable
    FROM Categories
    ORDER BY CategoryName ASC, CategoryID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_GetAvailable
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        CategoryID,
        CategoryName,
        IsAvailable
    FROM Categories
    WHERE IsAvailable = 1
    ORDER BY CategoryName ASC, CategoryID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_Update
    @CategoryName NVARCHAR(100),
    @IsAvailable BIT,
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Categories
    SET
        CategoryName = @CategoryName,
        IsAvailable = @IsAvailable
    WHERE CategoryID = @CategoryID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Category_Delete
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Categories
    WHERE CategoryID = @CategoryID;
END;
GO
