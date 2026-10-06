using System;







































































using System.Web.UI;
using System.Web.Script.Serialization;

namespace PortableKiosk.Shared.Layouts
{
    public partial class AdminLayout : MasterPage
    {
        public void ShowAlert(
            string type,
            string message,
            string title = null)
        {
            string alertOptions = new JavaScriptSerializer().Serialize(
                new
                {
                    type = type,
                    message = message,
                    title = title
                });

            string script =
                "window.setTimeout(function(){if(window.AdminAlert){window.AdminAlert.show(" +
                alertOptions +
                ");}},0);";

            ScriptManager.RegisterStartupScript(
                Page,
                GetType(),
                "AdminAlert_" + Guid.NewGuid().ToString("N"),
                script,
                true);
        }

        public void ShowSuccessAlert(string message)
        {
            ShowAlert("success", message, "Success");
        }

        public void ShowErrorAlert(string message)
        {
            ShowAlert("error", message, "Error");
        }

        public void ShowInformationAlert(string message)
        {
            ShowAlert("info", message, "Information");
        }

        public void ShowWarningAlert(string message)
        {
            ShowAlert("warning", message, "Warning");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Redirect("~/UI/Account/AdminLogin.aspx");
                return;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Redirect("~/UI/POS/Index.aspx");
                return;
            }

            ScriptManager.RegisterClientScriptInclude(
                Page,
                GetType(),
                "AdminAlertScript",
                ResolveUrl("~/Scripts/app/admin/alert.js"));

            string adminLastName = Convert.ToString(
                Session["StaffLastName"]);
            if (string.IsNullOrWhiteSpace(adminLastName))
            {
                string displayName = Convert.ToString(
                    Session["StaffDisplayName"]);
                string[] nameParts = (displayName ?? string.Empty).Split(
                    new[] { ' ' },
                    StringSplitOptions.RemoveEmptyEntries);
                adminLastName = nameParts.Length == 0
                    ? "Profile"
                    : nameParts[nameParts.Length - 1];
            }

            litAdminName.Text = Server.HtmlEncode(adminLastName);
            litAdminRole.Text = Server.HtmlEncode(
                string.Equals(
                    Convert.ToString(Session["StaffRole"]),
                    "ADMIN",
                    StringComparison.OrdinalIgnoreCase)
                    ? "Admin"
                    : Convert.ToString(Session["StaffRole"]));

            string pagePath =
                Request.AppRelativeCurrentExecutionFilePath;

            SetCurrentPage(lnkCatalogConfig, pagePath.EndsWith(
                "CatalogConfig.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkOrders, pagePath.EndsWith(
                "Orders.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkAnalytics, pagePath.EndsWith(
                "Analytics.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkProducts, pagePath.EndsWith(
                "Products.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkStaff, pagePath.EndsWith(
                "StaffAccounts.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkWebsiteQr, Page.AppRelativeVirtualPath.EndsWith(
                "WebsiteQr.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkSettings, pagePath.EndsWith(
                "Settings.aspx",
                StringComparison.OrdinalIgnoreCase));
        }

        private static void SetCurrentPage(
            System.Web.UI.HtmlControls.HtmlAnchor link,
            bool isCurrentPage)
        {
            if (isCurrentPage)
            {
                link.Attributes["aria-current"] = "page";
            }
            else
            {
                link.Attributes.Remove("aria-current");
            }
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
