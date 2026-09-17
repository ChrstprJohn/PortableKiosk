namespace PortableKiosk.Core.Models
{
    public class Bundle
    {
        public Bundle()
        {
            IsAvailable = true;
        }

        public int BundleID { get; set; }

        public string BundleName { get; set; }

        public decimal BasePrice { get; set; }

        public string ImagePath { get; set; }

        public bool IsAvailable { get; set; }

        public int DisplayOrder { get; set; }
    }
}