USE portable_kiosk_db;
GO

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
VALUES
(
    N'CREW_FIRST_NAME',
    NULL, -- Optional middle name
    N'CREW_LAST_NAME',
    NULL, -- Optional suffix
    N'crew@example.com',
    0xPASSWORD_HASH_HERE,
    0xPASSWORD_SALT_HERE,
    100000,
    N'CREW',
    1
);
GO