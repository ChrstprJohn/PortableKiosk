using System;







































































using System.Web.UI;

namespace PortableKiosk.Shared.Layouts
{
    public partial class AdminLayout : MasterPage
    {
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

            litAdminName.Text = Server.HtmlEncode(
                Convert.ToString(
                    Session["StaffDisplayName"]));

            string pagePath =
                Request.AppRelativeCurrentExecutionFilePath;

            lnkCatalogConfig.Attributes["class"] =
                pagePath.EndsWith(
                    "CatalogConfig.aspx",
                    StringComparison.OrdinalIgnoreCase)
                        ? "active"
                        : string.Empty;

            lnkProducts.Attributes["class"] =
                pagePath.EndsWith(
                    "Products.aspx",
                    StringComparison.OrdinalIgnoreCase)
                        ? "active"
                        : string.Empty;

            lnkBundles.Attributes["class"] =
                pagePath.EndsWith(
                    "Bundles.aspx",
                    StringComparison.OrdinalIgnoreCase)
                        ? "active"
                        : string.Empty;

            lnkStaff.Attributes["class"] =
                pagePath.EndsWith(
                    "StaffAccounts.aspx",
                    StringComparison.OrdinalIgnoreCase)
                        ? "active"
                        : string.Empty;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
