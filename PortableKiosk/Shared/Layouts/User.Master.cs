using System;
using System.Globalization;
using System.Web.UI;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.Shared.Layouts
{
    public partial class UserLayout : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected override void OnPreRender(EventArgs e)
        {
            RefreshCartSummary();
            base.OnPreRender(e);
        }

        public void RefreshCartSummary()
        {
            Cart cart = KioskSession.GetCart(Session);
            string orderType = KioskSession.GetOrderType(Session);

            litOrderType.Text = Server.HtmlEncode(
                string.Equals(
                    orderType,
                    "TAKEOUT",
                    StringComparison.OrdinalIgnoreCase)
                        ? "Takeout order"
                        : string.Equals(
                            orderType,
                            "DINE_IN",
                            StringComparison.OrdinalIgnoreCase)
                                ? "Dine-in order"
                                : "Choose order type");

            litCartCount.Text = string.Format(
                CultureInfo.InvariantCulture,
                "{0} {1}",
                cart.TotalQuantity,
                cart.TotalQuantity == 1 ? "item" : "items");

            litCartTotal.Text = string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                cart.TotalAmount);
        }

        protected void btnCancelOrder_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.ClearActiveOrder(Session);
            Response.Redirect("~/Default.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
