using System;
using System.Globalization;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Shared.Constants;
using PortableKiosk.Shared.Helpers;

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
            string orderTypeDisplay = string.Equals(
                KioskSession.GetOrderType(Session),
                "TAKEOUT",
                StringComparison.OrdinalIgnoreCase)
                    ? "Takeout"
                    : "Dine in";
            string fulfillmentDisplay = string.Equals(
                KioskSession.GetFulfillmentMethod(Session),
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase)
                    ? "Table service"
                    : "Counter pickup";
            litOrderType.Text = Server.HtmlEncode(
                orderTypeDisplay + " / " + fulfillmentDisplay);
            rptOrderItems.DataSource = new OrderItemRepository()
                .GetByOrderID(KioskSession.GetCompletedOrderID(Session).Value)
                .GroupBy(item => item.ProductName)
                .Select(group => new
                {
                    ProductName = group.Key,
                    Quantity = group.Sum(item => item.Quantity)
                })
                .ToList();
            rptOrderItems.DataBind();

            bool isCashAtCounter = string.Equals(
                KioskSession.GetPaymentMethod(Session),
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase);
            litInstruction.Text = Server.HtmlEncode(isCashAtCounter
                ? "Please go to the counter to pay for your order."
                : "Please wait while we prepare your order.");
            BindExpiryCountdown();
        }

        private void BindExpiryCountdown()
        {
            int orderID = KioskSession.GetCompletedOrderID(Session).Value;
            var payment = new PaymentRepository().GetByOrderID(orderID);
            if (payment == null ||
                !string.Equals(payment.PaymentMethod, "CASH_COUNTER", StringComparison.OrdinalIgnoreCase) ||
                !(string.Equals(payment.PaymentStatus, "PENDING", StringComparison.OrdinalIgnoreCase) ||
                  string.Equals(payment.PaymentStatus, "EXPIRED", StringComparison.OrdinalIgnoreCase)))
            {
                return;
            }

            var order = new OrderRepository().GetByID(orderID);
            if (order == null)
            {
                return;
            }

            DateTime expiresAt = DateTime.SpecifyKind(
                order.ExpiresAt ?? order.CreatedAt.AddMinutes(OrderSettings.LegacyPendingPaymentExpiryMinutes),
                DateTimeKind.Utc);
            double remainingMilliseconds = string.Equals(payment.PaymentStatus, "EXPIRED", StringComparison.OrdinalIgnoreCase)
                ? 0
                : Math.Max(0, (expiresAt - DateTime.UtcNow).TotalMilliseconds);
            int remainingSeconds = (int)Math.Ceiling(remainingMilliseconds / 1000);
            bool expired = remainingSeconds == 0;

            completeExpiry.Visible = true;
            completeExpiry.Attributes["data-remaining-ms"] = remainingMilliseconds.ToString("F0", CultureInfo.InvariantCulture);
            litExpiryLabel.Text = expired ? "Order number expired" : "Order number expires in";
            litExpiryTime.Text = (remainingSeconds / 60).ToString("00", CultureInfo.InvariantCulture) + ":" +
                (remainingSeconds % 60).ToString("00", CultureInfo.InvariantCulture);
            litExpiryHint.Text = expired
                ? "Start a new order to get a new number."
                : "Pay at the counter before the timer runs out.";
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
