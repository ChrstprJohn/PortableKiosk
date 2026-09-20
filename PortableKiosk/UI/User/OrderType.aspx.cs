using System;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class OrderType : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
            }
        }

        protected void btnDineIn_Click(
            object sender,
            EventArgs e)
        {
            SelectOrderType("DINE_IN");
        }

        protected void btnTakeout_Click(
            object sender,
            EventArgs e)
        {
            SelectOrderType("TAKEOUT");
        }

        private void SelectOrderType(string orderType)
        {
            KioskSession.SetOrderType(Session, orderType);
            Redirect("~/UI/User/Menu.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
