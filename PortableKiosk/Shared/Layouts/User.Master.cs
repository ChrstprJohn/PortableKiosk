using System;
using System.Globalization;
using System.Web.UI;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.Shared.Layouts
{
    public partial class UserLayout : MasterPage
    {
        protected override void OnPreRender(EventArgs e)
        {
            string requestPath = Request.Url.AbsolutePath;
            string pagePath = Page.AppRelativeVirtualPath ?? string.Empty;
            bool isOrderTypePage =
                requestPath.EndsWith(
                    "/UI/User/OrderType.aspx",
                    StringComparison.OrdinalIgnoreCase) ||
                pagePath.EndsWith(
                    "/UI/User/OrderType.aspx",
                    StringComparison.OrdinalIgnoreCase);

            userKioskHeader.Visible = !isOrderTypePage;
            userKioskHeader.Attributes["class"] = isOrderTypePage
                ? "user-kiosk-header hidden"
                : "user-kiosk-header";
            userKioskShell.Attributes["class"] = isOrderTypePage
                ? "user-kiosk-shell max-w-none"
                : "user-kiosk-shell max-w-[860px]";

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

            int count = cart.TotalQuantity;
            if (count > 0)
            {
                litCartCount.Text = string.Format(
                    CultureInfo.InvariantCulture,
                    "<span class=\"user-kiosk-cart-badge\">{0}</span>",
                    count > 9 ? "9+" : count.ToString(CultureInfo.InvariantCulture));
            }
            else
            {
                litCartCount.Text = string.Empty;
            }

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
