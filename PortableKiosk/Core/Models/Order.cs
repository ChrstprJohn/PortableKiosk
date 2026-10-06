using System;

namespace PortableKiosk.Core.Models
{
    [Serializable]
    public class Order
    {
        public Order()
        {
            OrderType = "DINE_IN";
            FulfillmentMethod = "COUNTER_PICKUP";
            KitchenStatus = "QUEUED";
            OrderSource = "KIOSK";
        }

        public int OrderID { get; set; }

        public string OrderNumber { get; set; }

        public string OrderSource { get; set; }

        public int? PlacedByStaffAccountID { get; set; }

        public string PlacedByName { get; set; }

        public string PlacedByDisplay
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(PlacedByName)) return PlacedByName;
                if (PlacedByStaffAccountID.HasValue) return "Staff #" + PlacedByStaffAccountID.Value;
                return "Not recorded";
            }
        }

        public string OrderType { get; set; }

        public string FulfillmentMethod { get; set; }

        public string TableNumber { get; set; }

        public string KitchenStatus { get; set; }

        public DateTime? ExpiresAt { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
