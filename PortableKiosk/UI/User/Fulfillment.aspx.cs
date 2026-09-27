using System;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class Fulfillment : System.Web.UI.Page
    {
        private readonly OrderService orderService =
            new OrderService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            if (KioskSession.HasCompletedOrder(Session))
            {
                Redirect("~/UI/User/Complete.aspx");
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
        }

        protected void btnTableService_Click(
            object sender,
            EventArgs e)
        {
            if (KioskSession.HasCompletedOrder(Session))
            {
                Redirect("~/UI/User/Complete.aspx");
                return;
            }

            KioskSession.SetFulfillmentMethod(
                Session,
                "TABLE_SERVICE");
            Redirect("~/UI/User/TableNumber.aspx");
        }

        protected void btnCounterPickup_Click(
            object sender,
            EventArgs e)
        {
            if (KioskSession.HasCompletedOrder(Session))
            {
                Redirect("~/UI/User/Complete.aspx");
                return;
            }

            KioskSession.SetFulfillmentMethod(
                Session,
                "COUNTER_PICKUP");

            try
            {
                PlaceCurrentOrder();
                Redirect("~/UI/User/Complete.aspx");
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                ShowError(
                    "Your order could not be saved. Please try again.");
            }
        }

        private void PlaceCurrentOrder()
        {
            Order order = orderService.PlaceOrder(
                KioskSession.GetCart(Session),
                KioskSession.GetOrderType(Session),
                KioskSession.GetPaymentMethod(Session),
                KioskSession.GetFulfillmentMethod(Session),
                KioskSession.GetTableNumber(Session));

            KioskSession.MarkOrderPlaced(Session, order);
        }

        private void ShowError(string message)
        {
            lblFulfillmentError.Text = Server.HtmlEncode(message);
            lblFulfillmentError.Visible = true;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
