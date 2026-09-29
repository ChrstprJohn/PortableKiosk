using System;
using PortableKiosk.Shared.Constants;
using PortableKiosk.Shared.Helpers;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.User
{
    public partial class Complete : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            string orderNumber = KioskSession.GetCompletedOrderNumber(Session);

            if (!KioskSession.GetCompletedOrderID(Session).HasValue ||
                string.IsNullOrWhiteSpace(orderNumber))
            {
                Redirect("~/UI/User/Fulfillment.aspx");
                return;
            }

            if (IsPostBack)
            {
                return;
            }

            litOrderNumber.Text = Server.HtmlEncode(orderNumber);

            bool isTableService = string.Equals(
                KioskSession.GetFulfillmentMethod(Session),
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase);
            bool isCashAtCounter = string.Equals(
                KioskSession.GetPaymentMethod(Session),
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase);

            int paymentWindowMinutes = OrderSettings.PendingPaymentExpiryMinutes;
            if (isCashAtCounter)
            {
                Order placedOrder = new OrderService().GetByID(
                    KioskSession.GetCompletedOrderID(Session).Value);
                if (placedOrder != null && placedOrder.ExpiresAt.HasValue)
                {
                    paymentWindowMinutes = Math.Max(1, (int)Math.Ceiling(
                        (placedOrder.ExpiresAt.Value - placedOrder.CreatedAt).TotalMinutes));
                }
            }

            string instruction;
            if (isTableService && isCashAtCounter)
            {
                instruction =
                    "Bring this number to the counter to pay within " +
                    paymentWindowMinutes +
                    " minutes, then keep your table locator visible.";
            }
            else if (isTableService)
            {
                instruction =
                    "Keep your table locator visible. Your order will be brought to you.";
            }
            else if (isCashAtCounter)
            {
                instruction =
                    "Bring this number to the counter to pay within " +
                    paymentWindowMinutes +
                    " minutes and collect your order.";
            }
            else
            {
                instruction =
                    "Show this number at the counter to collect your order.";
            }

            litInstruction.Text = Server.HtmlEncode(instruction);
        }

        protected void btnFinish_Click(object sender, EventArgs e)
        {
            KioskSession.ClearActiveOrder(Session);
            Redirect("~/Default.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
