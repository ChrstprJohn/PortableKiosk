using System;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Account
{
    public partial class AdminLogin : System.Web.UI.Page
    {
        private readonly StaffAccountService staffAccountService =
            new StaffAccountService();

        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!IsPostBack &&
                Session["StaffAccountID"] != null)
            {
                RedirectForRole(
                    Convert.ToString(
                        Session["StaffRole"]));
                return;
            }
        }

        protected void btnLogin_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            try
            {
                StaffAccount staff =
                    staffAccountService.Authenticate(
                        txtEmail.Text.Trim(),
                        txtPassword.Text);

                if (staff == null)
                {
                    ShowError(
                        "The email or password is incorrect.");

                    return;
                }

                Session.Clear();

                Session["StaffAccountID"] =
                    staff.StaffAccountID;

                Session["StaffDisplayName"] =
                    staff.DisplayName;

                Session["StaffEmail"] =
                    staff.Email;

                Session["StaffRole"] =
                    staff.StaffRole;

                RedirectForRole(staff.StaffRole);
            }
            catch (SqlException)
            {
                ShowError(
                    "The login service is currently unavailable.");
            }
            catch (Exception)
            {
                ShowError(
                    "An unexpected error occurred while signing in.");
            }
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass =
                "alert alert-danger d-block";
            lblMessage.Visible = true;
        }

        private void RedirectForRole(string staffRole)
        {
            string destination = string.Equals(
                staffRole,
                "ADMIN",
                StringComparison.OrdinalIgnoreCase)
                    ? "~/UI/Admin/CatalogConfig.aspx"
                    : "~/UI/POS/Index.aspx";

            Response.Redirect(destination, false);

            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
