using System;
using System.Globalization;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class OnlinePayment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            if (KioskSession.HasConfirmedOnlinePayment(Session))
            {
                Response.Redirect(
                    KioskSession.HasCompletedOrder(Session)
                        ? "~/UI/User/Complete.aspx"
                        : "~/UI/User/Fulfillment.aspx",
                    true);
                return;
            }

            Cart cart = KioskSession.GetCart(Session);

            if (cart.IsEmpty)
            {
                Redirect("~/UI/User/Cart.aspx");
                return;
            }

            if (!string.Equals(
                KioskSession.GetPaymentMethod(Session),
                "CASHLESS",
                StringComparison.OrdinalIgnoreCase))
            {
                Redirect("~/UI/User/Payment.aspx");
                return;
            }

            litPaymentTotal.Text = string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                cart.TotalAmount);
        }

        protected void btnConfirmMockPayment_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.ConfirmMockOnlinePayment(Session);
            Redirect("~/UI/User/Fulfillment.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
