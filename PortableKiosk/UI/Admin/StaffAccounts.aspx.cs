using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.UI.Admin
{
    public partial class StaffAccounts : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureAdminAccess())
            {
                return;
            }

            if (!IsPostBack)
            {
                LoadStaff();
            }
        }

        protected void btnCreateStaff_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!EnsureAdminAccess() || !Page.IsValid)
            {
                return;
            }

            if (!string.Equals(
                txtPassword.Text,
                txtConfirmPassword.Text,
                StringComparison.Ordinal))
            {
                ShowError("Passwords do not match.");
                return;
            }

            StaffAccount account = new StaffAccount
            {
                FirstName = txtFirstName.Text,
                MiddleName = txtMiddleName.Text,
                LastName = txtLastName.Text,
                Suffix = txtSuffix.Text,
                Email = txtEmail.Text,
                IsActive = chkIsActive.Checked
            };

            try
            {
                StaffAccountRepository repository =
                    new StaffAccountRepository();

                int accountID;

                if (string.Equals(
                    ddlRole.SelectedValue,
                    "ADMIN",
                    StringComparison.Ordinal))
                {
                    accountID = repository.AddAdmin(
                        account,
                        txtPassword.Text);
                }
                else
                {
                    accountID = repository.AddCrew(
                        account,
                        txtPassword.Text);
                }

                ShowSuccess(
                    account.DisplayName +
                    " was created as " +
                    account.StaffRole +
                    ". Account ID: " +
                    accountID +
                    ".");

                ClearForm();
                LoadStaff();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "That email address already belongs to a staff account.");
                }
                else
                {
                    ShowError(
                        "The staff account could not be created. Try again.");
                }
            }
            catch (ArgumentException exception)
            {
                ShowError(exception.Message);
            }
            catch (Exception)
            {
                ShowError(
                    "An unexpected error occurred while creating the account.");
            }
        }

        protected string GetRoleCss(object role)
        {
            return string.Equals(
                Convert.ToString(role),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase)
                    ? "role-badge role-admin"
                    : "role-badge role-crew";
        }

        protected string GetStatusCss(object isActive)
        {
            return Convert.ToBoolean(isActive)
                ? "status-badge status-active"
                : "status-badge status-inactive";
        }

        protected string GetStatusText(object isActive)
        {
            return Convert.ToBoolean(isActive)
                ? "Active"
                : "Inactive";
        }

        private bool EnsureAdminAccess()
        {
            if (Session["StaffAccountID"] == null)
            {
                Redirect("~/UI/Account/AdminLogin.aspx");
                return false;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Redirect("~/UI/POS/Index.aspx");
                return false;
            }

            return true;
        }

        private void LoadStaff()
        {
            try
            {
                StaffAccountRepository repository =
                    new StaffAccountRepository();

                List<StaffAccount> accounts =
                    repository.GetAll();

                gridStaff.DataSource = accounts;
                gridStaff.DataBind();
                gridStaff.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridStaff.Visible = false;
                lblLoadError.Text =
                    "Staff accounts could not be loaded. Refresh the page to try again.";
                lblLoadError.Visible = true;
            }
        }

        private void ClearForm()
        {
            txtFirstName.Text = string.Empty;
            txtMiddleName.Text = string.Empty;
            txtLastName.Text = string.Empty;
            txtSuffix.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
            ddlRole.SelectedValue = "CREW";
            chkIsActive.Checked = true;
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass =
                "alert alert-success d-block";
            lblMessage.Visible = true;
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass =
                "alert alert-danger d-block";
            lblMessage.Visible = true;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
