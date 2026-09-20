using System;

using PortableKiosk.Shared.Helpers;

namespace PortableKiosk
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnStartOrder_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.StartNewOrder(Session);
            Response.Redirect(
                "~/UI/User/OrderType.aspx",
                false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
