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
            bool isMenuPage =
                requestPath.EndsWith(
                    "/UI/User/Menu.aspx",
                    StringComparison.OrdinalIgnoreCase) ||
                pagePath.EndsWith(
                    "/UI/User/Menu.aspx",
                    StringComparison.OrdinalIgnoreCase);
            bool isOrderTypePage =
                requestPath.EndsWith(
                    "/UI/User/OrderType.aspx",
                    StringComparison.OrdinalIgnoreCase) ||
                pagePath.EndsWith(
                    "/UI/User/OrderType.aspx",
                    StringComparison.OrdinalIgnoreCase);
            bool isCartPage =
                requestPath.EndsWith(
                    "/UI/User/Cart.aspx",
                    StringComparison.OrdinalIgnoreCase) ||
                requestPath.EndsWith(
                    "/UI/User/Cart",
                    StringComparison.OrdinalIgnoreCase) ||
                pagePath.EndsWith(
                    "/UI/User/Cart.aspx",
                    StringComparison.OrdinalIgnoreCase) ||
                pagePath.EndsWith(
                    "/UI/User/Cart",
                    StringComparison.OrdinalIgnoreCase);
            bool isCheckoutFlowPage =
                IsUserPage(requestPath, pagePath, "Payment.aspx") ||
                IsUserPage(requestPath, pagePath, "OnlinePayment.aspx") ||
                IsUserPage(requestPath, pagePath, "Fulfillment.aspx") ||
                IsUserPage(requestPath, pagePath, "TableNumber.aspx") ||
                IsUserPage(requestPath, pagePath, "Complete.aspx");

            userKioskHeader.Visible =
                !isOrderTypePage && !isCartPage && !isCheckoutFlowPage;
            if (isMenuPage)
            {
                userKioskShell.Attributes["class"] =
                    "user-kiosk-shell group/menu @container/menu relative mx-auto h-dvh min-h-0 w-full max-w-none overflow-hidden bg-slate-50 text-slate-900 shadow-[0_0_40px_rgba(15,23,42,0.12)]";
                userKioskHeader.Attributes["class"] =
                    "user-kiosk-header h-0 min-h-0 bg-transparent p-0";
                lnkMenu.Attributes["class"] = "hidden";
                userKioskActions.Attributes["class"] =
                    "user-kiosk-actions kiosk-cta-footer kiosk-cta-footer-menu";
            }
            else if (isOrderTypePage)
            {
                userKioskShell.Attributes["class"] =
                    "user-kiosk-shell relative mx-auto min-h-screen min-h-dvh w-full max-w-none overflow-x-hidden bg-slate-50 text-slate-900 shadow-[0_0_40px_rgba(15,23,42,0.12)]";
                userKioskHeader.Attributes["class"] = "hidden";
            }
            else if (isCartPage)
            {
                userKioskShell.Attributes["class"] =
                    "user-kiosk-shell @container/menu relative mx-auto h-dvh min-h-0 w-full max-w-none overflow-x-hidden overflow-y-auto bg-slate-50 text-slate-900 shadow-[0_0_40px_rgba(15,23,42,0.12)]";
                userKioskHeader.Attributes["class"] = "hidden";
            }
            else if (isCheckoutFlowPage)
            {
                userKioskShell.Attributes["class"] =
                    "user-kiosk-shell relative mx-auto min-h-screen min-h-dvh w-full max-w-none overflow-x-hidden bg-slate-50 text-slate-900";
                userKioskHeader.Attributes["class"] = "hidden";
            }

            RefreshCartSummary();
            base.OnPreRender(e);
        }

        private static bool IsUserPage(
            string requestPath,
            string pagePath,
            string pageName)
        {
            string suffix = "/UI/User/" + pageName;

            return requestPath.EndsWith(
                    suffix,
                    StringComparison.OrdinalIgnoreCase) ||
                pagePath.EndsWith(
                    suffix,
                    StringComparison.OrdinalIgnoreCase);
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
