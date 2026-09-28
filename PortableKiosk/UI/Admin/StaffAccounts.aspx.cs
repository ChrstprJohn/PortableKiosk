using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Admin
{
    public partial class StaffAccounts : System.Web.UI.Page
    {
        private readonly StaffAccountService staffAccountService =
            new StaffAccountService();

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

            if (!EnsureAdminAccess())
            {
                return;
            }

            if (!Page.IsValid)
            {
                ReopenAddStaffModal();
                return;
            }

            if (!string.Equals(
                txtPassword.Text,
                txtConfirmPassword.Text,
                StringComparison.Ordinal))
            {
                ShowStaffFormError("Passwords do not match.");
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
                if (string.Equals(
                    ddlRole.SelectedValue,
                    "ADMIN",
                    StringComparison.Ordinal))
                {
                    staffAccountService.AddAdmin(
                        account,
                        txtPassword.Text);
                }
                else
                {
                    staffAccountService.AddCrew(
                        account,
                        txtPassword.Text);
                }

                ShowSuccess(account.DisplayName + " added.");

                ClearForm();
                LoadStaff();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowStaffFormError(
                        "That email address already belongs to a staff account.");
                }
                else
                {
                    ShowStaffFormError(
                        "The staff account could not be created. Try again.");
                }
            }
            catch (ArgumentException exception)
            {
                ShowStaffFormError(exception.Message);
            }
            catch (Exception)
            {
                ShowStaffFormError("The staff account could not be created.");
            }
        }

        protected string GetRoleCss(object role)
        {
            return string.Equals(
                Convert.ToString(role),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase)
                    ? "inline-flex items-center rounded-md border border-slate-200 bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-700"
                    : "inline-flex items-center rounded-md border border-slate-200 bg-white px-2 py-0.5 text-xs font-medium text-slate-600";
        }

        protected string GetStatusCss(object isActive)
        {
            return Convert.ToBoolean(isActive)
                ? "inline-flex items-center rounded-md bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700"
                : "inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600";
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
                List<StaffAccount> accounts =
                    staffAccountService.GetAll();

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
                "mb-4 block rounded-md border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800";
            lblMessage.Visible = true;
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass =
                "mb-4 block rounded-md border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800";
            lblMessage.Visible = true;
        }

        private void ShowStaffFormError(string message)
        {
            ShowError(message);
            ReopenAddStaffModal();
        }

        private void ReopenAddStaffModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenAddStaffModal",
                "AppModal.open('addStaffModal');",
                true);
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
