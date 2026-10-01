using System;
using System.Collections.Generic;

namespace PortableKiosk.Core.Models
{
    [Serializable]
    public class PosReceipt
    {
        public PosReceipt()
        {
            Items = new List<CartItem>();
        }

        public Order Order { get; set; }

        public Payment Payment { get; set; }

        public List<CartItem> Items { get; set; }

        public decimal Tendered { get; set; }

        public decimal Change { get; set; }

        public int IssuedByStaffAccountID { get; set; }

        public string IssuedByName { get; set; }
    }
}
