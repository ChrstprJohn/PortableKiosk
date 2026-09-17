namespace PortableKiosk.Core.Models
{
    public class BundleOptionGroupItem
    {
        public BundleOptionGroupItem()
        {
            IsAvailable = true;
        }

        public int OptionGroupID { get; set; }

        public int ProductVariantID { get; set; }

        public decimal AdditionalPrice { get; set; }

        public bool IsAvailable { get; set; }

        public int DisplayOrder { get; set; }

        // Display values populated by GetAll().
        public string OptionGroupName { get; set; }

        public string ProductName { get; set; }

        public string CategoryName { get; set; }

        public string SizeName { get; set; }

        public decimal ProductVariantPrice { get; set; }
    }
}
