USE portable_kiosk_db;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM dbo.StaffAccounts;

    DBCC CHECKIDENT
    (
        N'dbo.StaffAccounts',
        RESEED,
        0
    );

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
        0x8954E48CE27B7C2BD6F0EF213DB0A0A8B490DA07295D8146DD77864BFB565568,
        0x07E255DA5068BD2522E97B6E7A9D5AD7,
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