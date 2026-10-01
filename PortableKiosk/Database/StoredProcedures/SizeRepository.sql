-- Stored procedures for SizeRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.Size_Add
    @SizeName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO Sizes
        (SizeName)
    OUTPUT INSERTED.SizeID
    VALUES
        (@SizeName);
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_GetByID
    @SizeID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        SizeID,
        SizeName
    FROM Sizes
    WHERE SizeID = @SizeID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        SizeID,
        SizeName
    FROM Sizes
    ORDER BY SizeName ASC, SizeID ASC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_Update
    @SizeName NVARCHAR(50),
    @SizeID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE Sizes
    SET
        SizeName = @SizeName
    WHERE SizeID = @SizeID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.Size_Delete
    @SizeID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM Sizes
    WHERE SizeID = @SizeID;
END;
GO
