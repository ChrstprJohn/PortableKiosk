using System;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
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
