namespace PortableKiosk.Core.Models
{
    public class ProductVariant
    {
        public ProductVariant()
        {
            IsAvailable = true;
        }

        public int ProductVariantID { get; set; }

        public int ProductID { get; set; }

        public int? SizeID { get; set; }

        public decimal Price { get; set; }

        public string ImagePath { get; set; }

        public bool IsAvailable { get; set; }

        // Display values populated by GetAll().
        public string ProductName { get; set; }

        public string CategoryName { get; set; }

        public string SizeName { get; set; }
    }
}