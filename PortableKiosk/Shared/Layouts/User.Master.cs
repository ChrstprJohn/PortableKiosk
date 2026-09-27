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

            userKioskHeader.Visible = !isOrderTypePage && !isCartPage;
            if (isMenuPage)
            {
                userKioskShell.Attributes["class"] =
                    "user-kiosk-shell group/menu @container/menu relative mx-auto h-dvh min-h-0 w-full max-w-none overflow-hidden bg-slate-50 text-slate-900 shadow-[0_0_40px_rgba(15,23,42,0.12)]";
                userKioskHeader.Attributes["class"] =
                    "user-kiosk-header h-0 min-h-0 bg-transparent p-0";
                lnkMenu.Attributes["class"] = "hidden";
                userKioskActions.Attributes["class"] =
                    "user-kiosk-actions fixed inset-x-0 bottom-0 z-[1040] flex min-h-[clamp(3.5rem,9vh,26rem)] max-[480px]:min-h-[3.5rem] w-full items-center justify-between gap-[clamp(0.35rem,2cqw,2rem)] rounded-t-[clamp(0.75rem,3cqw,5rem)] border-t border-slate-200 bg-white/95 px-[clamp(0.5rem,3.5cqw,6rem)] py-[clamp(0.4rem,2vh,3rem)] max-[480px]:px-3 max-[480px]:py-2 shadow-[0_-1px_6px_rgba(15,23,42,0.05)] backdrop-blur-[16px] max-[360px]:px-2 group-has-[.product-detail-page]/menu:hidden";
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
                    "<span class=\"user-kiosk-cart-badge absolute -right-1 -top-1 z-[2] inline-flex h-[clamp(1rem,1.5cqw,1.5rem)] min-w-[clamp(1rem,1.5cqw,1.5rem)] items-center justify-center rounded-full border-2 border-white bg-red-500 px-[clamp(0.2rem,0.3cqw,0.4rem)] text-[clamp(0.6rem,0.75cqw,0.9rem)] font-extrabold leading-none text-white shadow-[0_2px_6px_rgba(239,68,68,0.45)]\">{0}</span>",
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
