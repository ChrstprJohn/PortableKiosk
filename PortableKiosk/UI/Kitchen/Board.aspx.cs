using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Kitchen
{
    public partial class Board : Page
    {
        private readonly OrderService orderService = new OrderService();
        private readonly OrderItemService itemService = new OrderItemService();

        protected class KitchenCard
        {
            public int OrderID { get; set; }
            public string OrderNumberDisplay { get; set; }
            public string TimeDisplay { get; set; }
            public string FulfillmentDisplay { get; set; }
            public string OrderTypeDisplay { get; set; }
            public string OrderTypeClass { get; set; }
            public string KitchenStatus { get; set; }
            public List<OrderItem> Items { get; set; }
        }

        protected string ProfileName { get; private set; }

        protected void Page_Init(object sender, EventArgs e)
        {
            if (IsAuthorized())
            {
                BindBoard();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAuthorized())
            {
                Response.Redirect("~/UI/Account/AdminLogin.aspx?mode=kitchen", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ProfileName = Convert.ToString(Session["StaffLastName"]);
            if (string.IsNullOrWhiteSpace(ProfileName))
            {
                ProfileName = Convert.ToString(Session["StaffDisplayName"]);
            }
            if (string.IsNullOrWhiteSpace(ProfileName))
            {
                ProfileName = "Profile";
            }
        }

        private bool IsAuthorized()
        {
            string role = Convert.ToString(Session["StaffRole"]);
            return Session["StaffAccountID"] != null &&
                (string.Equals(role, "CREW", StringComparison.OrdinalIgnoreCase) ||
                 string.Equals(role, "ADMIN", StringComparison.OrdinalIgnoreCase));
        }

        protected void StatusItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            KitchenCard card = e.Item.DataItem as KitchenCard;
            DropDownList status = e.Item.FindControl("ddlStatus") as DropDownList;
            if (card == null || status == null)
            {
                return;
            }

            if (card.KitchenStatus == "READY")
            {
                status.Items.Add(new ListItem("Completed", "COMPLETED"));
            }
            status.SelectedValue = card.KitchenStatus;
        }

        protected void StatusChanged(object sender, EventArgs e)
        {
            DropDownList status = sender as DropDownList;
            RepeaterItem item = status == null ? null : status.NamingContainer as RepeaterItem;
            HiddenField orderIDField = item == null ? null : item.FindControl("hidOrderID") as HiddenField;
            HiddenField currentField = item == null ? null : item.FindControl("hidCurrentStatus") as HiddenField;
            int orderID;
            if (orderIDField == null || currentField == null ||
                !int.TryParse(orderIDField.Value, out orderID))
            {
                ShowError("The order could not be identified. Refresh the board.");
                return;
            }

            string currentStatus = currentField.Value;
            string nextStatus = status.SelectedValue;
            if (currentStatus == nextStatus)
            {
                return;
            }

            try
            {
                if (!orderService.SetKitchenStatus(orderID, currentStatus, nextStatus))
                {
                    ShowError("This order changed or is no longer paid. The board has been refreshed.");
                }
                BindBoard();
            }
            catch (SqlException)
            {
                ShowError("The kitchen board could not update this order. Try again.");
            }
        }

        private void BindBoard()
        {
            try
            {
                List<KitchenCard> cards = orderService.GetPaidKitchenOrders()
                    .Select(o => new KitchenCard
                    {
                        OrderID = o.OrderID,
                        OrderNumberDisplay = FormatOrderNumber(o.OrderNumber),
                        KitchenStatus = o.KitchenStatus,
                        TimeDisplay = o.CreatedAt.AddHours(8).ToString("h:mm tt", CultureInfo.InvariantCulture),
                        OrderTypeDisplay = o.OrderType == "TAKEOUT" ? "Takeout" : "Dine in",
                        OrderTypeClass = o.OrderType == "TAKEOUT" ? "kitchen-type kitchen-type-takeout" : "kitchen-type kitchen-type-dinein",
                        FulfillmentDisplay = o.FulfillmentMethod == "TABLE_SERVICE"
                            ? "Table " + o.TableNumber
                            : "Counter pickup",
                        Items = itemService.GetByOrderID(o.OrderID)
                    }).ToList();

                BindColumn(rptQueued, litQueuedCount, emptyQueued, cards, "QUEUED");
                BindColumn(rptPreparing, litPreparingCount, emptyPreparing, cards, "PREPARING");
                BindColumn(rptServing, litServingCount, emptyServing, cards, "READY");
            }
            catch (SqlException)
            {
                ShowError("The kitchen board could not load. Refresh to try again.");
            }
        }

        private static void BindColumn(Repeater repeater, Literal count, PlaceHolder empty,
            List<KitchenCard> cards, string status)
        {
            List<KitchenCard> column = cards.Where(c => c.KitchenStatus == status).ToList();
            count.Text = column.Count.ToString(CultureInfo.InvariantCulture);
            empty.Visible = column.Count == 0;
            repeater.DataSource = column;
            repeater.DataBind();
        }

        private static string FormatOrderNumber(string orderNumber)
        {
            string value = (orderNumber ?? string.Empty).Trim().TrimStart('#');
            int numeric;
            return int.TryParse(value, out numeric)
                ? "#" + numeric.ToString("D4", CultureInfo.InvariantCulture)
                : "#" + value;
        }

        protected bool HasImage(object imagePath)
        {
            return !string.IsNullOrWhiteSpace(Convert.ToString(imagePath));
        }

        protected string ResolveProductImage(object imagePath)
        {
            string path = Convert.ToString(imagePath);
            return string.IsNullOrWhiteSpace(path) ? string.Empty : ResolveUrl(path);
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}
