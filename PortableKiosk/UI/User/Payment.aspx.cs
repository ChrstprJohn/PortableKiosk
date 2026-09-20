using System;
using System.Globalization;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class Payment : System.Web.UI.Page
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

            litCheckoutTotal.Text = string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                cart.TotalAmount);
        }

        protected void btnCashless_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.SetPaymentMethod(
                Session,
                "CASHLESS");
            Redirect("~/UI/User/OnlinePayment.aspx");
        }

        protected void btnCashCounter_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.SetPaymentMethod(
                Session,
                "CASH_COUNTER");
            Redirect("~/UI/User/Fulfillment.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
