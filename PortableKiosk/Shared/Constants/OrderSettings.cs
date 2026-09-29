namespace PortableKiosk.Shared.Constants
{
    public static class OrderSettings
    {
        // Orders created before ExpiresAt was stored retain the original 30-minute policy.
        public const int LegacyPendingPaymentExpiryMinutes = 30;

        // Read each time so admin changes take effect without restarting the app.
        public static int PendingPaymentExpiryMinutes
        {
            get { return new PortableKiosk.Core.Services.KioskSettingsService().Get().PendingPaymentExpiryMinutes; }
        }
    }
}
