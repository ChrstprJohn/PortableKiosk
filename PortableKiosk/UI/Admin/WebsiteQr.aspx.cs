using System;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Admin
{
    public partial class WebsiteQr : System.Web.UI.Page
    {
        private readonly WebsiteQrCodeService service = new WebsiteQrCodeService();

        private bool IsAdmin()
        {
            return Session["StaffAccountID"] != null &&
                string.Equals(Convert.ToString(Session["StaffRole"]), "ADMIN",
                    StringComparison.OrdinalIgnoreCase);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAdmin() || IsPostBack) return;
            try
            {
                WebsiteQrCode code = service.Get();
                txtWebsiteUrl.Text = code == null
                    ? new Uri(Request.Url, ResolveUrl("~/Default.aspx")).AbsoluteUri
                    : code.WebsiteUrl;
                BindCode(code);
            }
            catch (SqlException exception)
            {
                HandleDatabaseError(exception);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!IsAdmin()) return;
            try
            {
                service.Save(txtWebsiteUrl.Text);
                WebsiteQrCode code = service.Get();
                txtWebsiteUrl.Text = code.WebsiteUrl;
                BindCode(code);
                ShowMessage("Website link saved. The QR code is ready to print.");
            }
            catch (ArgumentException exception)
            {
                ShowMessage(exception.Message, true);
            }
            catch (SqlException exception)
            {
                HandleDatabaseError(exception);
            }
        }

        private void BindCode(WebsiteQrCode code)
        {
            bool hasCode = code != null;
            litFormHeading.Text = hasCode ? "Edit website link" : "Add website link";
            btnSave.Text = hasCode ? "Save changes" : "Save and generate QR code";
            pnlEmpty.Visible = !hasCode;
            websiteQrPrintArea.Visible = hasCode;
            if (hasCode)
            {
                lnkWebsite.NavigateUrl = code.WebsiteUrl;
                lnkWebsite.Text = Server.HtmlEncode(code.WebsiteUrl);
            }
        }

        private void HandleDatabaseError(SqlException exception)
        {
            bool missingSchema = exception.Number == 208 || exception.Number == 2812;
            ShowMessage(missingSchema
                ? "QR setup is missing. Apply database migration 007 and install the WebsiteQrCode stored procedures, then reload this page."
                : "The website link could not be loaded or saved. Check the database connection and try again.", true);
            btnSave.Enabled = !missingSchema;
        }

        private void ShowMessage(string message, bool isError = false)
        {
            pnlMessage.Visible = true;
            pnlMessage.Attributes["role"] = isError ? "alert" : "status";
            litMessage.Text = Server.HtmlEncode(message);
        }
    }
}
