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

        public string ProcessedByRole { get; set; }

        public string ProcessedByRoleDisplay
        {
            get
            {
                if (string.Equals(ProcessedByRole, "ADMIN", StringComparison.OrdinalIgnoreCase)) return "Admin";
                if (string.Equals(ProcessedByRole, "CREW", StringComparison.OrdinalIgnoreCase)) return "Crew";
                return PlacedByStaffAccountID.HasValue || !string.IsNullOrWhiteSpace(PlacedByName)
                    ? "Role not recorded" : string.Empty;
            }
        }

        public string PlacedByDisplay
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(PlacedByName)) return PlacedByName;
                if (PlacedByStaffAccountID.HasValue) return "Staff #" + PlacedByStaffAccountID.Value;
                if (string.Equals(OrderSource, "KIOSK", StringComparison.OrdinalIgnoreCase)) return "Not processed at POS";
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
