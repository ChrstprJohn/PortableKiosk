using System;

using PortableKiosk.Shared.Helpers;
using PortableKiosk.Core.Services;

namespace PortableKiosk
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool available = new KioskSettingsService().Get().IsAvailable;
            btnStartOrder.Visible = available;
            pnlUnavailable.Visible = !available;
        }

        protected void btnStartOrder_Click(
            object sender,
            EventArgs e)
        {
            if (!new KioskSettingsService().Get().IsAvailable)
            {
                Response.Redirect("~/Default.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            KioskSession.StartNewOrder(Session);
            Response.Redirect(
                "~/UI/User/OrderType.aspx",
                false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
