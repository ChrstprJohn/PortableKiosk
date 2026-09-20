using System;
using System.Text.RegularExpressions;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class TableNumber : System.Web.UI.Page
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

            if (!string.Equals(
                KioskSession.GetFulfillmentMethod(Session),
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase))
            {
                Redirect("~/UI/User/Fulfillment.aspx");
                return;
            }
        }

        protected void btnContinue_Click(
            object sender,
            EventArgs e)
        {
            if (KioskSession.HasCompletedOrder(Session))
            {
                Redirect("~/UI/User/Complete.aspx");
                return;
            }

            string tableNumber = txtTableNumber.Text.Trim();

            if (!Regex.IsMatch(tableNumber, "^[0-9]{1,20}$"))
            {
                lblTableNumberError.Text =
                    "Enter the number printed on your locator.";
                lblTableNumberError.Visible = true;
                return;
            }

            KioskSession.SetTableNumber(
                Session,
                tableNumber);

            try
            {
                Order order = orderService.PlaceOrder(
                    KioskSession.GetCart(Session),
                    KioskSession.GetOrderType(Session),
                    KioskSession.GetPaymentMethod(Session),
                    KioskSession.GetFulfillmentMethod(Session),
                    KioskSession.GetTableNumber(Session));

                KioskSession.MarkOrderPlaced(Session, order);
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

        private void ShowError(string message)
        {
            lblTableNumberError.Text = Server.HtmlEncode(message);
            lblTableNumberError.Visible = true;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
