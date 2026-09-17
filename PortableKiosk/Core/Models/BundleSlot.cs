namespace PortableKiosk.Core.Models
{
    public class BundleSlot
    {
        public BundleSlot()
        {
            Quantity = 1;
            IsRequired = true;
        }

        public int BundleSlotID { get; set; }

        public int BundleID { get; set; }

        public string SlotName { get; set; }

        public int? FixedProductVariantID { get; set; }

        public int? OptionGroupID { get; set; }

        public int? DefaultProductVariantID { get; set; }

        public int Quantity { get; set; }

        public bool IsRequired { get; set; }

        public int DisplayOrder { get; set; }

        // Display values populated by GetAll().
        public string BundleName { get; set; }

        public string SlotType { get; set; }

        public string ConfigurationDescription { get; set; }
    }
}
