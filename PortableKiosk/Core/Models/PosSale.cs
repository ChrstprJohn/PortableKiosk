using System;

namespace PortableKiosk.Core.Models
{
    [Serializable]
    public class PosSale
    {
        public PosSale()
        {
            SaleKey = Guid.NewGuid();
            OrderType = "TAKEOUT";
            FulfillmentMethod = "COUNTER_PICKUP";
            Cart = new Cart();
        }

        public int? SourceOrderID { get; set; }

        public Guid SaleKey { get; set; }

        public string OriginalItemsSignature { get; set; }

        public string SourceOrderNumber { get; set; }

        public string OrderType { get; set; }

        public string FulfillmentMethod { get; set; }

        public string TableNumber { get; set; }

        public Cart Cart { get; set; }
    }
}
