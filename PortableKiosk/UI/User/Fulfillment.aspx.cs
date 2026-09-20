using System;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class Fulfillment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            Cart cart = KioskSession.GetCart(Session);

            if (cart.IsEmpty)
            {
                Redirect("~/UI/User/Cart.aspx");
                return;
            }

            if (!KioskSession.CanContinueFromPayment(Session))
            {
                Redirect(
                    string.Equals(
                        KioskSession.GetPaymentMethod(Session),
                        "CASHLESS",
                        StringComparison.OrdinalIgnoreCase)
                            ? "~/UI/User/OnlinePayment.aspx"
                            : "~/UI/User/Payment.aspx");
                return;
            }

            string orderType =
                KioskSession.GetOrderType(Session);
            bool isDineIn = string.Equals(
                orderType,
                "DINE_IN",
                StringComparison.OrdinalIgnoreCase);

            pnlTableService.Visible = true;
            litFulfillmentHint.Text = isDineIn
                ? "Choose table service or counter pickup."
                : "Your order will be packed to go. Choose where you would like to receive it.";
        }

        protected void btnTableService_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.SetFulfillmentMethod(
                Session,
                "TABLE_SERVICE");
            Redirect("~/UI/User/TableNumber.aspx");
        }

        protected void btnCounterPickup_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.SetFulfillmentMethod(
                Session,
                "COUNTER_PICKUP");
            KioskSession.GetOrCreatePreviewOrderNumber(Session);
            Redirect("~/UI/User/Complete.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
