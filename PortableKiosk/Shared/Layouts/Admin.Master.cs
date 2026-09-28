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

            SetCurrentPage(lnkCatalogConfig, pagePath.EndsWith(
                "CatalogConfig.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkProducts, pagePath.EndsWith(
                "Products.aspx",
                StringComparison.OrdinalIgnoreCase));
            SetCurrentPage(lnkStaff, pagePath.EndsWith(
                "StaffAccounts.aspx",
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
