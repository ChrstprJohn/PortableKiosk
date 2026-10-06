-- Run against portable_kiosk_db. Safe to rerun; existing saved links are retained.
IF OBJECT_ID(N'dbo.WebsiteQrCode', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.WebsiteQrCode
    (
        QrCodeID INT NOT NULL CONSTRAINT PK_WebsiteQrCode PRIMARY KEY,
        WebsiteUrl NVARCHAR(2048) NOT NULL,
        UpdatedAt DATETIME2 NOT NULL
            CONSTRAINT DF_WebsiteQrCode_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT CK_WebsiteQrCode_SingleRow CHECK (QrCodeID = 1),
        CONSTRAINT CK_WebsiteQrCode_Url CHECK (
            LEN(LTRIM(RTRIM(WebsiteUrl))) > 0 AND
            (WebsiteUrl LIKE N'http://%' OR WebsiteUrl LIKE N'https://%'))
    );
END;
GO
