using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.POS
{
    public partial class Index : Page
    {
        private const string SessionKey = "PosRegisterState";
        private const string IdleStage = "IDLE";
        private const string QueueStage = "QUEUE";
        private const string RegisterStage = "REGISTER";
        private const string ChoiceStage = "CHOICE";
        private const string PaymentStage = "PAYMENT";
        private const string CashlessStage = "CASHLESS";
        private const string ReceiptStage = "RECEIPT";

        private readonly PosService posService = new PosService();
        private bool isAuthorized;

        [Serializable]
        private class RegisterState
        {
            public RegisterState()
            {
                Stage = IdleStage;
            }

            public string Stage { get; set; }
            public PosSale Sale { get; set; }
            public PosReceipt Receipt { get; set; }
        }

        private RegisterState Current
        {
            get
            {
                RegisterState state = Session[SessionKey] as RegisterState;
                if (state == null)
                {
                    state = new RegisterState();
                    Session[SessionKey] = state;
                }

                return state;
            }
        }

        protected string PaymentTotalValue { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            lblError.Text = string.Empty;
            lblError.Visible = false;

            if (Session["StaffAccountID"] == null)
            {
                Redirect("~/UI/Account/AdminLogin.aspx");
                return;
            }

            string role = Convert.ToString(Session["StaffRole"]);
            if (!string.Equals(role, "CREW", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(role, "ADMIN", StringComparison.OrdinalIgnoreCase))
            {
                Session.Clear();
                Redirect("~/UI/Account/AdminLogin.aspx");
                return;
            }

            isAuthorized = true;
            BindProfileLastName();
        }

        protected override void OnPreRender(EventArgs e)
        {
            if (isAuthorized)
            {
                BindStage();
            }

            base.OnPreRender(e);
        }

        protected void btnOpenKiosk_Click(object sender, EventArgs e)
        {
            if (!CanAct(IdleStage)) return;

            try
            {
                posService.CancelExpiredPendingOrders();
            }
            catch (Exception)
            {
                ShowError("Kiosk orders could not be checked. Try again.");
                return;
            }

            Current.Stage = QueueStage;
            txtOrderSearch.Text = string.Empty;
        }

        protected void btnNewSale_Click(object sender, EventArgs e)
        {
            if (!CanAct(IdleStage)) return;
            Current.Sale = posService.StartNewSale();
            Current.Receipt = null;
            Current.Stage = RegisterStage;
            ResetFilters();
        }

        protected void btnBackToIdle_Click(object sender, EventArgs e)
        {
            if (!isAuthorized || Current.Stage == ReceiptStage) return;
            Session[SessionKey] = new RegisterState();
            ResetFilters();
        }

        protected void btnSearchOrders_Click(object sender, EventArgs e)
        {
            if (!CanAct(QueueStage)) return;

            try
            {
                string orderNumber = txtOrderSearch.Text.Trim();
                if (orderNumber.StartsWith("#", StringComparison.Ordinal))
                {
                    orderNumber = orderNumber.Substring(1);
                }

                Current.Sale = posService.TakeKioskOrder(orderNumber);
                Current.Receipt = null;
                Current.Stage = RegisterStage;
                ResetFilters();
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
                ShowError("This kiosk order could not be opened. Check the number and try again.");
            }
        }

        protected void btnAddProduct_Click(object sender, EventArgs e)
        {
            if (!CanAct(RegisterStage)) return;

            int variantID;
            if (!int.TryParse(hdnProductVariantID.Value, out variantID) ||
                variantID <= 0)
            {
                ShowError("Choose a product from the menu.");
                return;
            }

            try
            {
                posService.AddProduct(Current.Sale, variantID, 1);
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
                ShowError("That product could not be added. Try again.");
            }
        }

        protected void btnLineAction_Click(object sender, EventArgs e)
        {
            if (!CanAct(RegisterStage)) return;

            int variantID;
            if (!int.TryParse(hdnProductVariantID.Value, out variantID) ||
                variantID <= 0)
            {
                ShowError("Choose an item from the receipt.");
                return;
            }

            try
            {
                switch (hdnLineAction.Value)
                {
                    case "increase":
                        posService.ChangeQuantity(Current.Sale, variantID, 1);
                        break;
                    case "decrease":
                        posService.ChangeQuantity(Current.Sale, variantID, -1);
                        break;
                    case "remove":
                        posService.RemoveProduct(Current.Sale, variantID);
                        break;
                    default:
                        ShowError("Choose a valid item action.");
                        break;
                }
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                ShowError(ex.Message);
            }
        }

        protected void btnDineIn_Click(object sender, EventArgs e)
        {
            SetNewOrderType("DINE_IN");
        }

        protected void btnTakeout_Click(object sender, EventArgs e)
        {
            SetNewOrderType("TAKEOUT");
        }

        protected void btnProceed_Click(object sender, EventArgs e)
        {
            if (!CanAct(RegisterStage)) return;
            if (Current.Sale == null || Current.Sale.Cart.IsEmpty)
            {
                ShowError("Add at least one product before payment.");
                return;
            }

            Current.Stage = ChoiceStage;
            txtTendered.Text = string.Empty;
        }

        protected void btnChooseCash_Click(object sender, EventArgs e)
        {
            if (!CanAct(ChoiceStage)) return;
            Current.Stage = PaymentStage;
        }

        protected void btnChooseCashless_Click(object sender, EventArgs e)
        {
            if (!CanAct(ChoiceStage)) return;
            Current.Stage = CashlessStage;
        }

        protected void btnBackToChoice_Click(object sender, EventArgs e)
        {
            if (!CanAct(PaymentStage) && !CanAct(CashlessStage)) return;
            Current.Stage = ChoiceStage;
        }

        protected void btnChoiceBackToSale_Click(object sender, EventArgs e)
        {
            if (!CanAct(ChoiceStage)) return;
            Current.Stage = RegisterStage;
        }

        protected void btnSimulatePayment_Click(object sender, EventArgs e)
        {
            if (!CanAct(CashlessStage)) return;
            try
            {
                Current.Receipt = posService.CompleteMockCashlessSale(Current.Sale);
                Current.Sale = null;
                Current.Stage = ReceiptStage;
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
                ShowError("Payment could not be completed. Check the order and try again.");
            }
        }

        protected void btnCompletePayment_Click(object sender, EventArgs e)
        {
            if (!CanAct(PaymentStage)) return;

            decimal tendered;
            if (!decimal.TryParse(
                txtTendered.Text,
                NumberStyles.Number,
                CultureInfo.GetCultureInfo("en-PH"),
                out tendered))
            {
                ShowError("Enter the cash amount received.");
                return;
            }

            try
            {
                PosReceipt receipt = posService.CompleteCashSale(
                    Current.Sale, tendered);
                Current.Receipt = receipt;
                Current.Sale = null;
                Current.Stage = ReceiptStage;
                txtTendered.Text = string.Empty;
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
                ShowError("Payment could not be completed. Check the order and try again.");
            }
        }

        protected void btnCloseReceipt_Click(object sender, EventArgs e)
        {
            if (!CanAct(ReceiptStage)) return;
            Session[SessionKey] = new RegisterState();
            ResetFilters();
        }

        private void SetNewOrderType(string orderType)
        {
            if (!CanAct(RegisterStage) || Current.Sale == null ||
                Current.Sale.SourceOrderID.HasValue)
            {
                return;
            }

            Current.Sale.OrderType = orderType;
        }

        private bool CanAct(string stage)
        {
            return isAuthorized && Current.Stage == stage;
        }

        private void BindStage()
        {
            RegisterState state = Current;
            if ((state.Stage == RegisterStage || state.Stage == ChoiceStage ||
                state.Stage == PaymentStage || state.Stage == CashlessStage) &&
                state.Sale == null)
            {
                state.Stage = IdleStage;
            }
            if (state.Stage == ReceiptStage && state.Receipt == null)
            {
                state.Stage = IdleStage;
            }

            pnlIdle.Visible = state.Stage == IdleStage;
            pnlQueue.Visible = state.Stage == QueueStage;
            pnlRegister.Visible = state.Stage == RegisterStage;
            pnlPaymentChoice.Visible = state.Stage == ChoiceStage;
            pnlPayment.Visible = state.Stage == PaymentStage;
            pnlCashless.Visible = state.Stage == CashlessStage;
            pnlReceipt.Visible = state.Stage == ReceiptStage;

            switch (state.Stage)
            {
                case RegisterStage:
                    BindRegister(state.Sale);
                    break;
                case PaymentStage:
                    BindPayment(state.Sale);
                    break;
                case ChoiceStage:
                case CashlessStage:
                    litCashlessTotal.Text = FormatMoney(state.Sale.Cart.TotalAmount);
                    break;
                case ReceiptStage:
                    BindReceipt(state.Receipt);
                    break;
            }
        }

        private void BindRegister(PosSale sale)
        {
            bool fromKiosk = sale.SourceOrderID.HasValue;
            pnlOrderTypeToolbar.Visible = !fromKiosk;
            pnlNewOrderType.Visible = !fromKiosk;
            pnlKioskDetails.Visible = fromKiosk;
            litKioskDetails.Text = Server.HtmlEncode(DescribeOrder(sale));

            bool dineIn = sale.OrderType == "DINE_IN";
            string selected = "text-slate-950";
            string unselected = "text-slate-600 hover:text-slate-950";
            btnDineIn.CssClass = GetChoiceClass() + (dineIn ? selected : unselected);
            btnTakeout.CssClass = GetChoiceClass() + (dineIn ? unselected : selected);
            btnDineIn.Attributes["aria-pressed"] = dineIn ? "true" : "false";
            btnTakeout.Attributes["aria-pressed"] = dineIn ? "false" : "true";
            orderTypeSlider.Attributes["class"] =
                "pointer-events-none absolute inset-y-1 left-1 w-[calc(50%-0.25rem)] rounded-full bg-white shadow-sm transition-transform duration-200 ease-out " +
                (dineIn ? "translate-x-0" : "translate-x-full");

            rptCartItems.DataSource = sale.Cart.Items;
            rptCartItems.DataBind();
            pnlCartEmpty.Visible = sale.Cart.IsEmpty;
            litCartTotal.Text = FormatMoney(sale.Cart.TotalAmount);
            btnProceed.Enabled = !sale.Cart.IsEmpty;

            try
            {
                List<PosCatalogItem> catalog =
                    posService.GetAvailableCatalog();
                pnlCatalogEmpty.Visible = catalog.Count == 0;

                rptCategories.DataSource = catalog
                    .GroupBy(item => item.CategoryID)
                    .Select(group => new
                    {
                        CategoryID = group.Key,
                        CategoryName = group.First().CategoryName
                    })
                    .ToList();
                rptCategories.DataBind();

                var sizes = catalog
                    .GroupBy(item => GetSizeKey(item.SizeID))
                    .Select(group => new
                    {
                        SizeKey = group.Key,
                        SizeName = group.First().SizeName,
                        Items = group.ToList()
                    })
                    .OrderBy(item => GetSizeOrder(item.SizeName))
                    .ThenBy(item => item.SizeName)
                    .ToList();
                rptProducts.DataSource = sizes;
                rptProducts.DataBind();

                List<int> categoryIDs = catalog.Select(item => item.CategoryID)
                    .Distinct().ToList();
                if (!categoryIDs.Any(id => id.ToString(CultureInfo.InvariantCulture) == hdnCategory.Value))
                {
                    hdnCategory.Value = categoryIDs.Count == 0
                        ? string.Empty
                        : categoryIDs[0].ToString(CultureInfo.InvariantCulture);
                }
            }
            catch (Exception)
            {
                ShowError("The menu could not be loaded. Refresh the page and try again.");
                rptProducts.DataSource = null;
                rptProducts.DataBind();
                rptCategories.DataSource = null;
                rptCategories.DataBind();
                pnlCatalogEmpty.Visible = true;
            }
        }

        protected void rptCategories_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            Literal icon = (Literal)e.Item.FindControl("litCategoryIcon");
            string categoryName = Convert.ToString(
                DataBinder.Eval(e.Item.DataItem, "CategoryName"));
            string normalized = (categoryName ?? string.Empty).Trim().ToLowerInvariant();
            string shape;

            if (normalized.Contains("burger") || normalized.Contains("sandwich"))
            {
                shape = "<path d=\"M4 10a8 8 0 0 1 16 0H4Zm-1 3h18v2H3Zm1 4h16a2 2 0 0 1-2 3H6a2 2 0 0 1-2-3Z\"/><path d=\"M8 13v2m4-2v2m4-2v2\"/>";
            }
            else if (normalized.Contains("chicken") || normalized.Contains("poultry"))
            {
                shape = "<path d=\"M14.5 5.5a4.5 4.5 0 0 0-6.4 6.4l3.9 3.9 6.4-6.4-3.9-3.9Z\"/><path d=\"m12 15.5 2.4 2.4m0 0a2 2 0 1 0 2.8-2.8m-2.8 2.8a2 2 0 1 0-2.8 2.8\"/>";
            }
            else if (normalized.Contains("side") || normalized.Contains("fries") || normalized.Contains("potato"))
            {
                shape = "<path d=\"m7 4 2 8m3-9v9m4-8-1 8M5 13h14l-1.5 7h-11L5 13Z\"/>";
            }
            else if (normalized.Contains("drink") || normalized.Contains("beverage") || normalized.Contains("coffee"))
            {
                shape = "<path d=\"M6 5h12l-1 15H7L6 5Zm3 0 5-3m-7 8h10\"/>";
            }
            else if (normalized.Contains("dessert") || normalized.Contains("sweet") || normalized.Contains("ice cream"))
            {
                shape = "<path d=\"M6 9a6 6 0 0 1 12 0c0 2.5-2 4.5-6 4.5S6 11.5 6 9Zm2 4.5 4 8 4-8M5 9h14\"/>";
            }
            else
            {
                shape = "<rect x=\"4\" y=\"4\" width=\"6\" height=\"6\" rx=\"1\"/><rect x=\"14\" y=\"4\" width=\"6\" height=\"6\" rx=\"1\"/><rect x=\"4\" y=\"14\" width=\"6\" height=\"6\" rx=\"1\"/><rect x=\"14\" y=\"14\" width=\"6\" height=\"6\" rx=\"1\"/>";
            }

            icon.Text = "<svg aria-hidden=\"true\" viewBox=\"0 0 24 24\" width=\"20\" height=\"20\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\" stroke-linecap=\"round\" stroke-linejoin=\"round\">" + shape + "</svg>";
        }

        protected void rptProducts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            Repeater tiles = (Repeater)e.Item.FindControl("rptProductTiles");
            tiles.DataSource = DataBinder.Eval(e.Item.DataItem, "Items");
            tiles.DataBind();
        }

        private void BindPayment(PosSale sale)
        {
            litPaymentContext.Text = Server.HtmlEncode(
                sale.SourceOrderID.HasValue
                    ? "Kiosk order #" + sale.SourceOrderNumber
                    : DescribeOrder(sale));
            rptPaymentItems.DataSource = sale.Cart.Items;
            rptPaymentItems.DataBind();
            litPaymentTotal.Text = FormatMoney(sale.Cart.TotalAmount);
            PaymentTotalValue = sale.Cart.TotalAmount.ToString(
                "0.00", CultureInfo.InvariantCulture);
        }

        private void BindReceipt(PosReceipt receipt)
        {
            DateTime paidAt = receipt.Payment.PaidAt ??
                receipt.Order.CreatedAt;
            litReceiptDate.Text = Server.HtmlEncode(
                DateTime.SpecifyKind(paidAt, DateTimeKind.Utc)
                    .ToLocalTime().ToString(
                        "MMM d, yyyy h:mm tt",
                        CultureInfo.GetCultureInfo("en-PH")));
            litReceiptNumber.Text = Server.HtmlEncode(
                receipt.Order.OrderNumber);
            litReceiptOrderDetails.Text = Server.HtmlEncode(
                DescribeOrder(receipt.Order));
            rptReceiptItems.DataSource = receipt.Items;
            rptReceiptItems.DataBind();
            litReceiptTotal.Text = FormatMoney(receipt.Payment.Amount);
            litReceiptTendered.Text = FormatMoney(receipt.Tendered);
            litReceiptChange.Text = FormatMoney(receipt.Change);
            bool cashless = receipt.Payment.PaymentMethod == "CASHLESS";
            pnlReceiptCash.Visible = !cashless;
            pnlReceiptCashless.Visible = cashless;
        }

        protected string FormatMoney(object value)
        {
            decimal amount = Convert.ToDecimal(value);
            return "\u20B1" + amount.ToString(
                "N2", CultureInfo.GetCultureInfo("en-PH"));
        }

        protected string GetSizeKey(object value)
        {
            return value == null || value == DBNull.Value
                ? "standard"
                : Convert.ToString(value, CultureInfo.InvariantCulture);
        }

        private static int GetSizeOrder(string sizeName)
        {
            switch ((sizeName ?? string.Empty).Trim().ToLowerInvariant())
            {
                case "regular": return 0;
                case "medium": return 1;
                case "large": return 2;
                case "standard": return -1;
                default: return 3;
            }
        }

        protected bool HasImage(object value)
        {
            return !string.IsNullOrWhiteSpace(Convert.ToString(value));
        }

        protected string ResolveProductImage(object value)
        {
            string path = Convert.ToString(value);
            return string.IsNullOrWhiteSpace(path)
                ? string.Empty
                : ResolveUrl(path);
        }

        private static string GetChoiceClass()
        {
            return "relative z-10 min-h-8 flex-1 cursor-pointer rounded-full px-3 text-sm font-semibold transition-colors " +
                "focus-visible:outline-2 focus-visible:outline-offset-2 " +
                "focus-visible:outline-blue-700 ";
        }

        private static string DescribeOrder(PosSale sale)
        {
            return Humanize(sale.OrderType) + " · " +
                DescribeFulfillment(
                    sale.FulfillmentMethod, sale.TableNumber);
        }

        private static string DescribeOrder(Order order)
        {
            return Humanize(order.OrderType) + " · " +
                DescribeFulfillment(
                    order.FulfillmentMethod, order.TableNumber);
        }

        private static string DescribeFulfillment(
            string fulfillment, string tableNumber)
        {
            if (fulfillment == "TABLE_SERVICE")
            {
                return string.IsNullOrWhiteSpace(tableNumber)
                    ? "Table service"
                    : "Table service · locator " + tableNumber;
            }

            return "Counter pickup";
        }

        private static string Humanize(string value)
        {
            return string.Equals(value, "DINE_IN", StringComparison.OrdinalIgnoreCase)
                ? "Dine in"
                : string.Equals(value, "TAKEOUT", StringComparison.OrdinalIgnoreCase)
                    ? "Takeout"
                    : value ?? string.Empty;
        }

        private void ResetFilters()
        {
            hdnCategory.Value = string.Empty;
        }

        private void BindProfileLastName()
        {
            string lastName = Convert.ToString(Session["StaffLastName"]);
            if (string.IsNullOrWhiteSpace(lastName))
            {
                int staffAccountID;
                if (int.TryParse(
                    Convert.ToString(Session["StaffAccountID"]),
                    out staffAccountID) && staffAccountID > 0)
                {
                    try
                    {
                        StaffAccount staff =
                            new StaffAccountService().GetByID(staffAccountID);
                        if (staff != null)
                        {
                            lastName = staff.LastName;
                        }
                    }
                    catch (Exception)
                    {
                        // Keep the active register usable if profile lookup is unavailable.
                    }
                }
            }

            if (string.IsNullOrWhiteSpace(lastName))
            {
                string displayName = Convert.ToString(
                    Session["StaffDisplayName"]);
                string[] nameParts = (displayName ?? string.Empty).Split(
                    new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                lastName = nameParts.Length == 0
                    ? "Profile"
                    : nameParts[nameParts.Length - 1];
            }

            Session["StaffLastName"] = lastName;
            litProfileLastName.Text = Server.HtmlEncode(lastName);
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
