using System;

namespace PortableKiosk.Core.Models
{
    public class Payment
    {
        public Payment()
        {
            PaymentStatus = "PENDING";
        }

        public int PaymentID { get; set; }

        public int OrderID { get; set; }

        public string PaymentMethod { get; set; }

        public string PaymentStatus { get; set; }

        public decimal Amount { get; set; }

        public string TransactionReference { get; set; }

        public DateTime? PaidAt { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
