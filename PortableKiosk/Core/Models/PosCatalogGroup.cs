using System.Collections.Generic;

namespace PortableKiosk.Core.Models
{
    public class PosCatalogCategory
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; }
    }

    public class PosCatalogSizeGroup
    {
        public string SizeKey { get; set; }
        public string SizeName { get; set; }
        public List<PosCatalogItem> Items { get; set; }
    }

    public class PosCatalogGroup
    {
        public List<PosCatalogCategory> Categories { get; set; }
        public List<PosCatalogSizeGroup> Sizes { get; set; }
        public List<int> CategoryIDs { get; set; }
    }
}
