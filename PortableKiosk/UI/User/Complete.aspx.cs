using System;
using System.Collections.Generic;
using System.Globalization;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Helpers;
using PaymentModel = PortableKiosk.Core.Models.Payment;

namespace PortableKiosk.UI.User
{
    public partial class Complete : System.Web.UI.Page
    {
        private readonly OrderService orderService =
            new OrderService();

        private readonly OrderItemService orderItemService =
            new OrderItemService();

        private readonly PaymentService paymentService =
            new PaymentService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            int? completedOrderID =
                KioskSession.GetCompletedOrderID(Session);

            if (!completedOrderID.HasValue)
            {
                Redirect("~/UI/User/Fulfillment.aspx");
                return;
            }

            if (IsPostBack)
            {
                return;
            }

            Order order = orderService.GetByID(
                completedOrderID.Value);
            PaymentModel payment = paymentService.GetByOrderID(
                completedOrderID.Value);
            List<OrderItem> items =
                orderItemService.GetByOrderID(
                    completedOrderID.Value);

            if (order == null ||
                payment == null ||
                items.Count == 0)
            {
                KioskSession.ClearActiveOrder(Session);
                Redirect("~/Default.aspx");
                return;
            }

            BindReceipt(order, items, payment);
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
            Order order,
            IList<OrderItem> items,
            PaymentModel payment)
        {
            bool isTableService = string.Equals(
                order.FulfillmentMethod,
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase);
            bool isCashAtCounter = string.Equals(
                payment.PaymentMethod,
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase);
            bool isTakeout = string.Equals(
                order.OrderType,
                "TAKEOUT",
                StringComparison.OrdinalIgnoreCase);

            litOrderNumber.Text = Server.HtmlEncode(
                order.OrderNumber);
            litOrderType.Text = string.Equals(
                order.OrderType,
                "TAKEOUT",
                StringComparison.OrdinalIgnoreCase)
                    ? "Takeout"
                    : "Dine in";
            litPaymentMethod.Text = string.Equals(
                payment.PaymentMethod,
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase)
                    ? "Cash at counter"
                    : "Online payment";

            pnlTableNumber.Visible = isTableService;
            litTableNumber.Text = Server.HtmlEncode(
                order.TableNumber);

            if (isTableService && isCashAtCounter)
            {
                litInstruction.Text = Server.HtmlEncode(
                    "Bring this order number to the counter to pay, then place locator " +
                    order.TableNumber +
                    " where the crew can see it. " +
                    (isTakeout
                        ? "Your packed takeout order will be brought to you."
                        : "Your order will be served to you."));
            }
            else if (isTableService)
            {
                litInstruction.Text = Server.HtmlEncode(
                    "Payment complete. Place locator " +
                    order.TableNumber +
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

            rptReceiptItems.DataSource = items;
            rptReceiptItems.DataBind();
            litReceiptTotal.Text = FormatMoney(
                payment.Amount);
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
