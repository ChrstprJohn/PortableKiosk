-- Stored procedures for WebsiteQrCodeRepository. Apply after migration 007.
CREATE OR ALTER PROCEDURE dbo.WebsiteQrCode_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT WebsiteUrl FROM dbo.WebsiteQrCode WHERE QrCodeID = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.WebsiteQrCode_Save
    @WebsiteUrl NVARCHAR(2048)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Serialize first-time saves so the singleton cannot be inserted twice.
        IF EXISTS (SELECT 1 FROM dbo.WebsiteQrCode WITH (UPDLOCK, HOLDLOCK) WHERE QrCodeID = 1)
            UPDATE dbo.WebsiteQrCode
            SET WebsiteUrl = @WebsiteUrl, UpdatedAt = SYSUTCDATETIME()
            WHERE QrCodeID = 1;
        ELSE
            INSERT INTO dbo.WebsiteQrCode (QrCodeID, WebsiteUrl) VALUES (1, @WebsiteUrl);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
