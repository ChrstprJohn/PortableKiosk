namespace PortableKiosk.Core.Models
{
    public class PosCatalogItem
    {
        public int ProductVariantID { get; set; }

        public int ProductID { get; set; }

        public int CategoryID { get; set; }

        public int? SizeID { get; set; }

        public string ProductName { get; set; }

        public string CategoryName { get; set; }

        public string SizeName { get; set; }

        public string ImagePath { get; set; }

        public decimal Price { get; set; }
    }
}
