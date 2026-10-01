-- Stored procedures for KioskSettingsRepository.
-- Apply after Schema.sql and all required migrations.

CREATE OR ALTER PROCEDURE dbo.KioskSettings_Get
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT IsAvailable, PendingPaymentExpiryMinutes
                    FROM KioskSettings WHERE SettingsID = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.KioskSettings_Save
    @IsAvailable BIT,
    @ExpiryMinutes INT
AS
BEGIN
    SET NOCOUNT OFF;
    UPDATE KioskSettings
                    SET IsAvailable = @IsAvailable,
                        PendingPaymentExpiryMinutes = @ExpiryMinutes
                    WHERE SettingsID = 1;
END;
GO
