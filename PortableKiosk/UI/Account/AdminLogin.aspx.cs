using System;
using System.Data.SqlClient;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Security;

namespace PortableKiosk.UI.Account
{
    public partial class AdminLogin : System.Web.UI.Page
    {
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
                StaffAccountRepository repository =
                    new StaffAccountRepository();

                StaffAccount staff =
                    repository.GetByEmail(
                        txtEmail.Text.Trim());

                bool validLogin =
                    staff != null &&
                    staff.IsActive &&
                    IsSupportedRole(staff.StaffRole) &&
                    PasswordHasher.Verify(
                        txtPassword.Text,
                        staff.PasswordSalt,
                        staff.PasswordHash,
                        staff.PasswordIterations);

                if (!validLogin)
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

        private static bool IsSupportedRole(
            string staffRole)
        {
            return string.Equals(
                    staffRole,
                    "ADMIN",
                    StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    staffRole,
                    "CREW",
                    StringComparison.OrdinalIgnoreCase);
        }

        private void RedirectForRole(string staffRole)
        {
            string destination = string.Equals(
                staffRole,
                "ADMIN",
                StringComparison.OrdinalIgnoreCase)
                    ? "~/UI/Admin/Category.aspx"
                    : "~/UI/POS/Index.aspx";

            Response.Redirect(destination, false);

            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
