using System;
using System.Globalization;
using PortableKiosk.Core.Models;
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

            Cart cart = KioskSession.GetCart(Session);
            string paymentMethod =
                KioskSession.GetPaymentMethod(Session);
            string fulfillmentMethod =
                KioskSession.GetFulfillmentMethod(Session);

            if (cart.IsEmpty ||
                string.IsNullOrWhiteSpace(paymentMethod) ||
                !KioskSession.CanContinueFromPayment(Session))
            {
                Redirect("~/UI/User/Cart.aspx");
                return;
            }

            if (string.IsNullOrWhiteSpace(fulfillmentMethod))
            {
                Redirect("~/UI/User/Fulfillment.aspx");
                return;
            }

            if (string.Equals(
                    fulfillmentMethod,
                    "TABLE_SERVICE",
                    StringComparison.OrdinalIgnoreCase) &&
                string.IsNullOrWhiteSpace(
                    KioskSession.GetTableNumber(Session)))
            {
                Redirect("~/UI/User/TableNumber.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindReceipt(
                    cart,
                    paymentMethod,
                    fulfillmentMethod);
            }
        }

        protected void btnFinish_Click(
            object sender,
            EventArgs e)
        {
            KioskSession.ClearActiveOrder(Session);
            Redirect("~/Default.aspx");
        }

        protected string FormatMoney(object amount)
        {
            return string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                Convert.ToDecimal(amount));
        }

        private void BindReceipt(
            Cart cart,
            string paymentMethod,
            string fulfillmentMethod)
        {
            string tableNumber =
                KioskSession.GetTableNumber(Session);
            bool isTableService = string.Equals(
                fulfillmentMethod,
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase);
            bool isCashAtCounter = string.Equals(
                paymentMethod,
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase);
            bool isTakeout = string.Equals(
                KioskSession.GetOrderType(Session),
                "TAKEOUT",
                StringComparison.OrdinalIgnoreCase);

            litOrderNumber.Text = Server.HtmlEncode(
                KioskSession.GetOrCreatePreviewOrderNumber(
                    Session));
            litOrderType.Text = string.Equals(
                KioskSession.GetOrderType(Session),
                "TAKEOUT",
                StringComparison.OrdinalIgnoreCase)
                    ? "Takeout"
                    : "Dine in";
            litPaymentMethod.Text = string.Equals(
                paymentMethod,
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase)
                    ? "Cash at counter"
                    : "Online payment";

            pnlTableNumber.Visible = isTableService;
            litTableNumber.Text = Server.HtmlEncode(tableNumber);

            if (isTableService && isCashAtCounter)
            {
                litInstruction.Text = Server.HtmlEncode(
                    "Bring this order number to the counter to pay, then place locator " +
                    tableNumber +
                    " where the crew can see it. " +
                    (isTakeout
                        ? "Your packed takeout order will be brought to you."
                        : "Your order will be served to you."));
            }
            else if (isTableService)
            {
                litInstruction.Text = Server.HtmlEncode(
                    "Payment complete. Place locator " +
                    tableNumber +
                    " where the crew can see it. " +
                    (isTakeout
                        ? "Your packed takeout order will be brought to you."
                        : "Your order will be served to you."));
            }
            else if (isCashAtCounter)
            {
                litInstruction.Text =
                    "Bring this order number to the counter to pay and collect your order.";
            }
            else
            {
                litInstruction.Text =
                    "Payment complete. Please wait near the counter until your order number is called.";
            }

            rptReceiptItems.DataSource = cart.Items;
            rptReceiptItems.DataBind();
            litReceiptTotal.Text = FormatMoney(
                cart.TotalAmount);
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
