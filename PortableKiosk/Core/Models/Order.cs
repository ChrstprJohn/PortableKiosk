using System;

namespace PortableKiosk.Core.Models
{
    public class Order
    {
        public Order()
        {
            OrderType = "DINE_IN";
            PaymentStatus = "UNPAID";
            KitchenStatus = "NONE";
        }

        public int OrderID { get; set; }

        public string OrderNumber { get; set; }

        public string OrderType { get; set; }

        public string PaymentStatus { get; set; }

        public string KitchenStatus { get; set; }

        public DateTime ExpiresAt { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
