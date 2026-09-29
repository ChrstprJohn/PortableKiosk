using System;
using System.Data.SqlClient;
using System.Globalization;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Layouts;

namespace PortableKiosk.UI.Admin
{
    public partial class Settings : System.Web.UI.Page
    {
        private readonly KioskSettingsService settingsService = new KioskSettingsService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAdmin()) return;
            if (!IsPostBack) LoadSettings();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!IsAdmin()) return;

            int minutes;
            if (!int.TryParse(txtExpiryMinutes.Text, NumberStyles.None,
                CultureInfo.InvariantCulture, out minutes) || minutes < 1 || minutes > 1440)
            {
                ShowError("Enter an expiration from 1 to 1440 minutes.");
                return;
            }

            try
            {
                settingsService.Save(new KioskSettings
                {
                    IsAvailable = chkAvailable.Checked,
                    PendingPaymentExpiryMinutes = minutes
                });
                LoadSettings();
                ((AdminLayout)Master).ShowSuccessAlert("Kiosk settings saved.");
            }
            catch (SqlException)
            {
                ShowError("Settings could not be saved. Check the database connection and try again.");
            }
            catch (InvalidOperationException exception)
            {
                ShowError(exception.Message);
            }
        }

        private void LoadSettings()
        {
            try
            {
                KioskSettings settings = settingsService.Get();
                chkAvailable.Checked = settings.IsAvailable;
                txtExpiryMinutes.Text = settings.PendingPaymentExpiryMinutes.ToString(
                    CultureInfo.InvariantCulture);
            }
            catch (Exception exception)
            {
                if (!(exception is SqlException) && !(exception is InvalidOperationException)) throw;
                ShowError("Settings could not be loaded. Check that database migration 005 has been applied.");
                btnSave.Enabled = false;
            }
        }

        private bool IsAdmin()
        {
            return Session["StaffAccountID"] != null &&
                string.Equals(Convert.ToString(Session["StaffRole"]), "ADMIN",
                    StringComparison.OrdinalIgnoreCase);
        }

        private void ShowError(string message)
        {
            pnlMessage.Visible = true;
            litMessage.Text = Server.HtmlEncode(message);
        }
    }
}
