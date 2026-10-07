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
        private readonly KitchenBoardService boardService = new KitchenBoardService();

        protected string ProfileName { get; private set; }
        protected KitchenCompletedFilter CompletedFilter { get; private set; }

        protected void Page_Init(object sender, EventArgs e)
        {
            CompletedFilter = KitchenCompletedFilter.Create(Request.QueryString["completed"],
                Request.QueryString["from"], Request.QueryString["to"], DateTime.UtcNow);
            if (IsAuthorized() && !IsPostBack)
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

            KitchenOrderCard card = e.Item.DataItem as KitchenOrderCard;
            DropDownList status = e.Item.FindControl("ddlStatus") as DropDownList;
            if (card == null || status == null)
            {
                return;
            }

            status.Items.Add(new ListItem("Completed", "COMPLETED"));
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
                    BindBoard();
                    return;
                }
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
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
                List<KitchenOrderCard> cards = boardService.GetPaidOrders(true, CompletedFilter);

                BindColumn(rptQueued, litQueuedCount, emptyQueued, cards, "QUEUED");
                BindColumn(rptPreparing, litPreparingCount, emptyPreparing, cards, "PREPARING");
                BindColumn(rptServing, litServingCount, emptyServing, cards, "SERVING");
                BindColumn(rptCompleted, litCompletedCount, emptyCompleted, cards, "COMPLETED");
            }
            catch (SqlException)
            {
                ShowError("The kitchen board could not load. Refresh to try again.");
            }
        }

        private static void BindColumn(Repeater repeater, Literal count, PlaceHolder empty,
            List<KitchenOrderCard> cards, string status)
        {
            List<KitchenOrderCard> column = cards.Where(c => c.KitchenStatus == status).ToList();
            if (status == "COMPLETED")
            {
                column.Reverse();
            }
            count.Text = column.Count.ToString(CultureInfo.InvariantCulture);
            empty.Visible = column.Count == 0;
            repeater.DataSource = column;
            repeater.DataBind();
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
