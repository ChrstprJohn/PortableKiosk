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
            string mode = SelectedMode;
            rolePicker.Visible = mode == null;
            loginForm.Visible = mode != null;
            litWorkspace.Text = mode == "admin" ? "Admin" : mode == "kitchen" ? "Kitchen" : "POS";

            if (!IsPostBack &&
                Session["StaffAccountID"] != null && mode != null)
            {
                RedirectForRole(Convert.ToString(Session["StaffRole"]), mode);
                return;
            }
        }

        private string SelectedMode
        {
            get
            {
                string mode = (Request.QueryString["mode"] ?? string.Empty).ToLowerInvariant();
                return mode == "admin" || mode == "pos" || mode == "kitchen" ? mode : null;
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

            if (SelectedMode == null)
            {
                ShowError("Choose a workspace before signing in.");
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

                if (!CanAccess(staff.StaffRole, SelectedMode))
                {
                    ShowError("This account does not have access to the selected workspace.");
                    return;
                }

                Session.Clear();

                Session["StaffAccountID"] =
                    staff.StaffAccountID;

                Session["StaffDisplayName"] =
                    staff.DisplayName;

                Session["StaffLastName"] =
                    staff.LastName;

                Session["StaffEmail"] =
                    staff.Email;

                Session["StaffRole"] =
                    staff.StaffRole;

                RedirectForRole(staff.StaffRole, SelectedMode);
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
                "mt-6 block rounded-lg bg-red-50 px-4 py-3 text-sm text-red-800";
            lblMessage.Visible = true;
        }

        private static bool CanAccess(string staffRole, string mode)
        {
            if (string.Equals(staffRole, "ADMIN", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            return mode != "admin" &&
                string.Equals(staffRole, "CREW", StringComparison.OrdinalIgnoreCase);
        }

        private void RedirectForRole(string staffRole, string mode)
        {
            if (!CanAccess(staffRole, mode))
            {
                ShowError("This account does not have access to the selected workspace.");
                return;
            }

            string destination = mode == "admin"
                ? "~/UI/Admin/CatalogConfig.aspx"
                : mode == "kitchen" ? "~/UI/Kitchen/Board.aspx" : "~/UI/POS/Index.aspx";

            Response.Redirect(destination, false);

            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
