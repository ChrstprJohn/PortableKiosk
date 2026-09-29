namespace PortableKiosk.Core.Models
{
    public class KioskSettings
    {
        public bool IsAvailable { get; set; }
        public int PendingPaymentExpiryMinutes { get; set; }
    }
}
