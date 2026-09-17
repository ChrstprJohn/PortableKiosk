namespace PortableKiosk.Core.Models
{
    public class BundleOptionGroup
    {
        public BundleOptionGroup()
        {
            IsAvailable = true;
        }

        public int OptionGroupID { get; set; }

        public string OptionGroupName { get; set; }

        public bool IsAvailable { get; set; }

        public int DisplayOrder { get; set; }
    }
}