using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Constants;
using PortableKiosk.Shared.Layouts;

namespace PortableKiosk.UI.Admin
{
    public partial class Orders : Page
    {
        private readonly OrderService orderService =
            new OrderService();

        private readonly OrderItemService orderItemService =
            new OrderItemService();

        private readonly PaymentService paymentService =
            new PaymentService();

        public class OrderListRow
        {
            public int OrderID { get; set; }
            public string OrderNumber { get; set; }
            public DateTime CreatedAt { get; set; }
            public string CreatedAtDisplay { get; set; }
            public string ExpiresAtDisplay { get; set; }
            public string OrderTypeDisplay { get; set; }
            public string FulfillmentDisplay { get; set; }
            public string KitchenStatusDisplay { get; set; }
            public string PaymentStatus { get; set; }
            public string PaymentStatusDisplay { get; set; }
            public string PaymentMethodDisplay { get; set; }
            public string AmountDisplay { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Response.Redirect("~/UI/Account/AdminLogin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/UI/POS/Index.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                BindOrders();
            }
        }

        protected void btnSearchOrders_Click(object sender, EventArgs e)
        {
            gridOrders.PageIndex = 0;
            BindOrders();
        }

        protected void ddlPaymentStatus_SelectedIndexChanged(
            object sender,
            EventArgs e)
        {
            gridOrders.PageIndex = 0;
            BindOrders();
        }

        protected void gridOrders_PageIndexChanging(
            object sender,
            GridViewPageEventArgs e)
        {
            gridOrders.PageIndex = e.NewPageIndex;
            BindOrders();
        }

        protected void gridOrders_RowCommand(
            object sender,
            GridViewCommandEventArgs e)
        {
            if (!string.Equals(
                e.CommandName,
                "ViewDetails",
                StringComparison.Ordinal))
            {
                return;
            }

            int orderID;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out orderID) ||
                orderID <= 0)
            {
                ShowError("The selected order is invalid.");
                return;
            }

            try
            {
                orderService.CancelExpiredPendingOrders();
                Order order = orderService.GetByID(orderID);
                if (order == null)
                {
                    ShowError("This order could not be found. Refresh the list and try again.");
                    return;
                }

                List<OrderItem> items =
                    orderItemService.GetByOrderID(orderID);
                Payment payment =
                    paymentService.GetByOrderID(orderID);

                BindOrderDetails(order, items, payment);
                Page.ClientScript.RegisterStartupScript(
                    GetType(),
                    "OpenOrderDetailsModal",
                    "AppModal.open('orderDetailsModal');",
                    true);
            }
            catch (Exception)
            {
                ShowError("Order details could not be loaded. Refresh the list and try again.");
            }
        }

        private void BindOrders()
        {
            try
            {
                orderService.CancelExpiredPendingOrders();
                List<Order> orders = orderService.GetAll();
                Dictionary<int, Payment> payments = paymentService.GetAll()
                    .ToDictionary(payment => payment.OrderID);

                string search = txtOrderSearch.Text.Trim();
                string selectedPaymentStatus = ddlPaymentStatus.SelectedValue;

                List<OrderListRow> rows = new List<OrderListRow>();

                foreach (Order order in orders)
                {
                    Payment payment;
                    payments.TryGetValue(order.OrderID, out payment);
                    DateTime? expiresAt = GetEffectiveExpiryAt(
                        order,
                        payment);
                    bool isExpired = IsExpired(
                        payment,
                        expiresAt,
                        DateTime.UtcNow);
                    string paymentStatus = payment == null
                        ? null
                        : isExpired
                            ? "EXPIRED"
                            : payment.PaymentStatus;

                    OrderListRow row = new OrderListRow
                    {
                        OrderID = order.OrderID,
                        OrderNumber = order.OrderNumber,
                        CreatedAt = order.CreatedAt,
                        CreatedAtDisplay = FormatOrderDate(order.CreatedAt),
                        ExpiresAtDisplay = expiresAt.HasValue
                            ? FormatOrderDate(expiresAt.Value)
                            : "\u2014",
                        OrderTypeDisplay = Humanize(order.OrderType),
                        FulfillmentDisplay = GetFulfillmentDisplay(order),
                        KitchenStatusDisplay = Humanize(order.KitchenStatus),
                        PaymentStatus = paymentStatus,
                        PaymentStatusDisplay = payment == null
                            ? "Not recorded"
                            : Humanize(paymentStatus),
                        PaymentMethodDisplay = payment == null
                            ? "Not recorded"
                            : GetPaymentMethodDisplay(payment.PaymentMethod),
                        AmountDisplay = payment == null
                            ? "\u2014"
                            : FormatAmount(payment.Amount)
                    };

                    if (!string.IsNullOrWhiteSpace(search) &&
                        (row.OrderNumber ?? string.Empty).IndexOf(
                            search,
                            StringComparison.OrdinalIgnoreCase) < 0)
                    {
                        continue;
                    }

                    if (selectedPaymentStatus == "NOT_RECORDED" &&
                        row.PaymentStatus != null)
                    {
                        continue;
                    }

                    if (!string.IsNullOrWhiteSpace(selectedPaymentStatus) &&
                        selectedPaymentStatus != "NOT_RECORDED" &&
                        !string.Equals(
                            row.PaymentStatus,
                            selectedPaymentStatus,
                            StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    rows.Add(row);
                }

                gridOrders.DataSource = rows;
                gridOrders.DataBind();
                gridOrders.Visible = true;
                lblOrderCount.Text = rows.Count == 1
                    ? "1 order"
                    : rows.Count.ToString(CultureInfo.CurrentCulture) + " orders";
            }
            catch (Exception)
            {
                gridOrders.Visible = false;
                ((AdminLayout)Master).ShowErrorAlert(
                    "Orders could not be loaded. Refresh the page to try again.");
            }
        }

        private void BindOrderDetails(
            Order order,
            List<OrderItem> items,
            Payment payment)
        {
            litDetailsOrderNumber.Text =
                HttpUtility.HtmlEncode(order.OrderNumber ?? string.Empty);
            litDetailsCreatedAt.Text =
                HttpUtility.HtmlEncode(FormatOrderDate(order.CreatedAt));
            litDetailsOrderType.Text =
                HttpUtility.HtmlEncode(Humanize(order.OrderType));
            litDetailsFulfillment.Text =
                HttpUtility.HtmlEncode(GetFulfillmentDisplay(order));
            DateTime? expiresAt = GetEffectiveExpiryAt(order, payment);
            bool isExpired = IsExpired(
                payment,
                expiresAt,
                DateTime.UtcNow);
            string kitchenStatusDisplay = Humanize(order.KitchenStatus);
            lblDetailsKitchenStatus.Text = HttpUtility.HtmlEncode(
                kitchenStatusDisplay);
            lblDetailsKitchenStatus.CssClass =
                "inline-flex whitespace-nowrap rounded-full px-2.5 py-1 text-xs font-medium " +
                KitchenStatusCss(kitchenStatusDisplay);
            string paymentStatusDisplay = payment == null
                ? "Not recorded"
                : isExpired
                    ? "Expired"
                    : Humanize(payment.PaymentStatus);
            lblDetailsPaymentStatus.Text = HttpUtility.HtmlEncode(
                paymentStatusDisplay);
            lblDetailsPaymentStatus.CssClass =
                "inline-flex whitespace-nowrap rounded-full px-2.5 py-1 text-xs font-medium " +
                PaymentStatusCss(paymentStatusDisplay);
            litDetailsExpiresAt.Text = HttpUtility.HtmlEncode(
                expiresAt.HasValue
                    ? FormatOrderDate(expiresAt.Value)
                    : "\u2014");
            rptOrderItems.DataSource = items;
            rptOrderItems.DataBind();
            pnlOrderItems.Visible = items.Count > 0;
            pnlNoOrderItems.Visible = items.Count == 0;

            decimal itemTotal = items.Sum(item => item.LineTotal);
            decimal total = payment == null ? itemTotal : payment.Amount;
            litDetailsPayment.Text = payment == null
                ? "Not recorded"
                : HttpUtility.HtmlEncode(
                    GetPaymentMethodDisplay(payment.PaymentMethod));
            litDetailsTotal.Text = HttpUtility.HtmlEncode(FormatAmount(total));
        }

        protected string PaymentStatusCss(object value)
        {
            string status = Convert.ToString(value).ToUpperInvariant();

            switch (status)
            {
                case "PAID":
                    return "bg-emerald-50 text-emerald-700";
                case "PENDING":
                    return "bg-amber-50 text-amber-800";
                case "FAILED":
                case "CANCELLED":
                case "EXPIRED":
                    return "bg-red-50 text-red-700";
                default:
                    return "bg-slate-100 text-slate-600";
            }
        }

        protected string KitchenStatusCss(object value)
        {
            string status = Convert.ToString(value)
                .Trim()
                .Replace(' ', '_')
                .ToUpperInvariant();

            switch (status)
            {
                case "AWAITING_PAYMENT":
                    return "bg-amber-50 text-amber-800";
                case "QUEUED":
                    return "bg-sky-50 text-sky-700";
                case "PREPARING":
                    return "bg-blue-50 text-blue-800";
                case "SERVING":
                    return "bg-emerald-50 text-emerald-700";
                case "COMPLETED":
                    return "bg-slate-100 text-slate-700";
                case "CANCELLED":
                case "EXPIRED":
                    return "bg-red-50 text-red-700";
                default:
                    return "bg-slate-100 text-slate-600";
            }
        }

        protected string FormatAmount(decimal amount)
        {
            return "\u20B1" + amount.ToString("N2", CultureInfo.CurrentCulture);
        }

        protected bool HasImage(object imagePath)
        {
            return !string.IsNullOrWhiteSpace(
                Convert.ToString(imagePath));
        }

        protected string ResolveProductImage(object imagePath)
        {
            string path = Convert.ToString(imagePath);
            return string.IsNullOrWhiteSpace(path)
                ? string.Empty
                : ResolveUrl(path);
        }

        private static string FormatOrderDate(DateTime createdAt)
        {
            DateTime localTime = DateTime.SpecifyKind(
                createdAt,
                DateTimeKind.Utc).ToLocalTime();

            return localTime.ToString(
                "MMM d, yyyy h:mm tt",
                CultureInfo.CurrentCulture);
        }

        private static string Humanize(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return "Not recorded";
            }

            string normalized = value.Trim().Replace('_', ' ').ToLowerInvariant();
            return CultureInfo.CurrentCulture.TextInfo.ToTitleCase(normalized);
        }

        private static string GetPaymentMethodDisplay(string paymentMethod)
        {
            if (string.Equals(
                paymentMethod,
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase))
            {
                return "Cash at counter";
            }

            return Humanize(paymentMethod);
        }

        private static string GetFulfillmentDisplay(Order order)
        {
            if (string.Equals(
                order.FulfillmentMethod,
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase))
            {
                return string.IsNullOrWhiteSpace(order.TableNumber)
                    ? "Table service"
                    : "Table service \u00B7 " + order.TableNumber;
            }

            return "Counter pickup";
        }

        private static DateTime? GetEffectiveExpiryAt(
            Order order,
            Payment payment)
        {
            if (order == null)
            {
                return null;
            }

            if (order.ExpiresAt.HasValue)
            {
                return order.ExpiresAt.Value;
            }

            if (payment != null &&
                string.Equals(
                    payment.PaymentMethod,
                    "CASH_COUNTER",
                    StringComparison.OrdinalIgnoreCase) &&
                string.Equals(
                    payment.PaymentStatus,
                    "PENDING",
                    StringComparison.OrdinalIgnoreCase))
            {
                return order.CreatedAt.AddMinutes(
                    OrderSettings.LegacyPendingPaymentExpiryMinutes);
            }

            return null;
        }

        private static bool IsExpired(
            Payment payment,
            DateTime? expiresAt,
            DateTime utcNow)
        {
            return payment != null &&
                string.Equals(
                    payment.PaymentMethod,
                    "CASH_COUNTER",
                    StringComparison.OrdinalIgnoreCase) &&
                string.Equals(
                    payment.PaymentStatus,
                    "PENDING",
                    StringComparison.OrdinalIgnoreCase) &&
                expiresAt.HasValue &&
                expiresAt.Value <= utcNow;
        }

        private void ShowError(string message)
        {
            ((AdminLayout)Master).ShowErrorAlert(message);
        }
    }
}
