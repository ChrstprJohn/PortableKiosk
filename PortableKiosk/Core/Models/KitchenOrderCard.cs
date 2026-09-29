using System.Collections.Generic;

namespace PortableKiosk.Core.Models
{
    public class KitchenOrderCard
    {
        public int OrderID { get; set; }
        public string OrderNumberDisplay { get; set; }
        public string TimeDisplay { get; set; }
        public string FulfillmentDisplay { get; set; }
        public string OrderTypeDisplay { get; set; }
        public string OrderTypeClass { get; set; }
        public string KitchenStatus { get; set; }
        public List<OrderItem> Items { get; set; }
    }
}
