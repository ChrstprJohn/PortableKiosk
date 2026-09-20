using System;
using System.Text.RegularExpressions;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class TableNumber : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            if (!string.Equals(
                KioskSession.GetFulfillmentMethod(Session),
                "TABLE_SERVICE",
                StringComparison.OrdinalIgnoreCase))
            {
                Redirect("~/UI/User/Fulfillment.aspx");
            }
        }

        protected void btnContinue_Click(
            object sender,
            EventArgs e)
        {
            string tableNumber = txtTableNumber.Text.Trim();

            if (!Regex.IsMatch(tableNumber, "^[0-9]{1,20}$"))
            {
                lblTableNumberError.Text =
                    "Enter the number printed on your locator.";
                lblTableNumberError.Visible = true;
                return;
            }

            KioskSession.SetTableNumber(
                Session,
                tableNumber);
            KioskSession.GetOrCreatePreviewOrderNumber(Session);
            Redirect("~/UI/User/Complete.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
