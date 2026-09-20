using System;

namespace PortableKiosk.Core.Models
{
    public class Order
    {
        public Order()
        {
            OrderType = "DINE_IN";
            FulfillmentMethod = "COUNTER_PICKUP";
            KitchenStatus = "QUEUED";
        }

        public int OrderID { get; set; }

        public string OrderNumber { get; set; }

        public string OrderType { get; set; }

        public string FulfillmentMethod { get; set; }

        public string TableNumber { get; set; }

        public string KitchenStatus { get; set; }

        public DateTime? ExpiresAt { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
