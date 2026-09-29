IF OBJECT_ID(N'dbo.KioskSettings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.KioskSettings
    (
        SettingsID INT NOT NULL CONSTRAINT PK_KioskSettings PRIMARY KEY,
        IsAvailable BIT NOT NULL CONSTRAINT DF_KioskSettings_IsAvailable DEFAULT (1),
        PendingPaymentExpiryMinutes INT NOT NULL
            CONSTRAINT DF_KioskSettings_Expiry DEFAULT (30),
        CONSTRAINT CK_KioskSettings_SingleRow CHECK (SettingsID = 1),
        CONSTRAINT CK_KioskSettings_Expiry CHECK (PendingPaymentExpiryMinutes BETWEEN 1 AND 1440)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.KioskSettings WHERE SettingsID = 1)
BEGIN
    INSERT INTO dbo.KioskSettings (SettingsID, IsAvailable, PendingPaymentExpiryMinutes)
    VALUES (1, 1, 30);
END;
GO
