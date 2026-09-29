using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI
{
    public partial class OrderStatus : Page
    {
        private readonly KitchenBoardService boardService = new KitchenBoardService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            try
            {
                List<KitchenOrderCard> orders = boardService.GetPublicStatusOrders();
                BindColumn(rptPreparing, emptyPreparing, orders, "PREPARING");
                BindColumn(rptServing, emptyServing, orders, "SERVING");
            }
            catch (SqlException)
            {
                lblError.Text = "Order status is unavailable. This page will retry shortly.";
                lblError.Visible = true;
            }
        }

        private static void BindColumn(Repeater repeater, PlaceHolder empty,
            List<KitchenOrderCard> orders, string status)
        {
            List<KitchenOrderCard> column = orders.Where(order => order.KitchenStatus == status).ToList();
            empty.Visible = column.Count == 0;
            repeater.DataSource = column;
            repeater.DataBind();
        }
    }
}
