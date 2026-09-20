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

        public string ProductName { get; set; }

        public string SizeName { get; set; }

        public decimal UnitPrice { get; set; }

        public int Quantity { get; set; }

        public decimal LineTotal
        {
            get { return UnitPrice * Quantity; }
        }

        public string DisplaySize
        {
            get
            {
                return string.IsNullOrWhiteSpace(SizeName)
                    ? "Standard"
                    : SizeName;
            }
        }
    }
}
