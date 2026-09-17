namespace PortableKiosk.Core.Models
{
    public class Product
    {
        public Product()
        {
            IsAvailable = true;
        }

        public int ProductID { get; set; }

        public int CategoryID { get; set; }

        public string ProductName { get; set; }

        public bool IsAvailable { get; set; }

        public int DisplayOrder { get; set; }

        // Used when displaying products.
        // This value comes from the Categories table.
        public string CategoryName { get; set; }
    }
}