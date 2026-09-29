using System;

namespace PortableKiosk.Core.Models
{
    [Serializable]
    public class PosRegisterState
    {
        public PosRegisterState()
        {
            Stage = "IDLE";
        }

        public string Stage { get; set; }
        public PosSale Sale { get; set; }
        public PosReceipt Receipt { get; set; }
    }
}
