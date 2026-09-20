using System;

namespace PortableKiosk.Core.Models
{
    [Serializable]
    public class CartItem
    {
        public CartItem()
        {
            Quantity = 1;
        }

        public int ProductVariantID { get; set; }

        public int ProductID { get; set; }

        public string ProductName { get; set; }

        public string SizeName { get; set; }

        public string ImagePath { get; set; }

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
