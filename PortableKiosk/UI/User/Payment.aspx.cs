using System;
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
