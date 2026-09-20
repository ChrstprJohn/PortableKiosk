using System;
using System.Collections.Generic;
using System.Linq;

namespace PortableKiosk.Core.Models
{
    [Serializable]
    public class Cart
    {
        public Cart()
        {
            Items = new List<CartItem>();
        }

        public List<CartItem> Items { get; set; }

        public int TotalQuantity
        {
            get { return Items.Sum(item => item.Quantity); }
        }

        public decimal TotalAmount
        {
            get { return Items.Sum(item => item.LineTotal); }
        }

        public bool IsEmpty
        {
            get { return Items.Count == 0; }
        }
    }
}
