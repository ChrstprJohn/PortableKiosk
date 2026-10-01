-- Reset staff accounts and create one fully populated admin account.
-- Login email and password: picardochristopherjohnoleo1@gmail.com
-- Password uses the application PBKDF2-SHA256 format (100,000 iterations).
USE portable_kiosk_db;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Clear all existing admin and crew accounts before creating this admin.
    DELETE FROM dbo.StaffAccounts;
    -- Keep the identity sequence: reseeding to 0 can create an invalid ID on a new table.

    INSERT INTO dbo.StaffAccounts
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
    VALUES
    (
        N'Picardo',
        N'Christopher John',
        N'Oleo',
        NULL,
        N'picardochristopherjohnoleo1@gmail.com',
        0x2C9A14438D144CF99DAC867142925AB8DD254AC4A70805AF29C4AE69A783E5F4,
        0x27231920D94309DB00E6EA0D9763C8B9,
        100000,
        N'ADMIN',
        1
    );

    COMMIT TRANSACTION;

    SELECT
        StaffAccountID,
        FirstName,
        MiddleName,
        LastName,
        Email,
        StaffRole,
        IsActive,
        CreatedAt
    FROM dbo.StaffAccounts;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;
GO