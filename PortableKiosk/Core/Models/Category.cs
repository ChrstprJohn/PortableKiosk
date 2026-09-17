namespace PortableKiosk.Core.Models
{
    public class Category
    {
        public Category()
        {
            IsAvailable = true;
        }

        public int CategoryID { get; set; }

        public string CategoryName { get; set; }


        public int DisplayOrder { get; set; }

        public bool IsAvailable { get; set; }
    }
}