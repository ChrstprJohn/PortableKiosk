namespace PortableKiosk.Shared.Constants
{
    public static class OrderSettings
    {
        // Keep this policy in one place so it can move to admin-managed
        // settings without changing the order and payment flows.
        public const int PendingPaymentExpiryMinutes = 30;
    }
}
