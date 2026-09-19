namespace PortableKiosk.Core.Models
{
    public class OrderItem
    {
        public OrderItem()
        {
            Quantity = 1;
        }

        public int OrderItemID { get; set; }

        public int OrderID { get; set; }

        public int ProductVariantID { get; set; }

        public string ItemName { get; set; }

        public string SizeName { get; set; }

        public decimal UnitPrice { get; set; }

        public int Quantity { get; set; }
    }
}
