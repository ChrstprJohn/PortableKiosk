-- Stored procedures for StaffAccountRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.StaffAccount_GetByID
    @StaffAccountID INT
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        StaffRole,
        IsActive,
        CreatedAt,
        UpdatedAt
    FROM StaffAccounts
    WHERE StaffAccountID = @StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_GetByEmail
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        PasswordHash,
        PasswordSalt,
        PasswordIterations,
        StaffRole,
        IsActive,
        CreatedAt,
        UpdatedAt
    FROM StaffAccounts
    WHERE Email = @Email;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_GetAll
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        StaffRole,
        IsActive,
        CreatedAt,
        UpdatedAt
    FROM StaffAccounts
    ORDER BY LastName, FirstName, StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_Update
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Suffix NVARCHAR(20),
    @Email NVARCHAR(256),
    @StaffRole NVARCHAR(20),
    @IsActive BIT,
    @StaffAccountID INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE StaffAccounts
    SET
        FirstName = @FirstName,
        MiddleName = @MiddleName,
        LastName = @LastName,
        Suffix = @Suffix,
        Email = @Email,
        StaffRole = @StaffRole,
        IsActive = @IsActive,
        UpdatedAt = SYSUTCDATETIME()
    WHERE StaffAccountID = @StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_Delete
    @StaffAccountID INT
AS
BEGIN
    SET NOCOUNT OFF;
    DELETE FROM StaffAccounts
    WHERE StaffAccountID = @StaffAccountID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.StaffAccount_Add
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Suffix NVARCHAR(20),
    @Email NVARCHAR(256),
    @PasswordHash VARBINARY(32),
    @PasswordSalt VARBINARY(16),
    @PasswordIterations INT,
    @StaffRole NVARCHAR(20),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT OFF;
    INSERT INTO StaffAccounts
    (
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        Email,
        PasswordHash,
        PasswordSalt,
        PasswordIterations,
        StaffRole,
        IsActive
    )
    OUTPUT
        INSERTED.StaffAccountID,
        INSERTED.CreatedAt
    VALUES
    (
        @FirstName,
        @MiddleName,
        @LastName,
        @Suffix,
        @Email,
        @PasswordHash,
        @PasswordSalt,
        @PasswordIterations,
        @StaffRole,
        @IsActive
    );
END;
GO
