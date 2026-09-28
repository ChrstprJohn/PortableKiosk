using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Layouts;

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

        protected void gridStaff_RowCommand(
            object sender,
            GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ViewStaff" &&
                e.CommandName != "EditStaff")
            {
                return;
            }

            if (!EnsureAdminAccess())
            {
                return;
            }

            int staffAccountID;

            if (!int.TryParse(
                Convert.ToString(e.CommandArgument),
                out staffAccountID))
            {
                ShowError("The selected staff account could not be found.");
                return;
            }

            try
            {
                StaffAccount account =
                    staffAccountService.GetByID(staffAccountID);

                if (account == null)
                {
                    ShowError("The selected staff account could not be found.");
                    LoadStaff();
                    return;
                }

                if (e.CommandName == "ViewStaff")
                {
                    ShowStaffDetails(account);
                }
                else
                {
                    PopulateEditForm(account);
                }
            }
            catch (Exception)
            {
                ShowError("The selected staff account could not be loaded.");
            }
        }

        protected void btnUpdateStaff_Click(
            object sender,
            EventArgs e)
        {
            if (!EnsureAdminAccess())
            {
                return;
            }

            if (!Page.IsValid)
            {
                ReopenEditStaffModal();
                return;
            }

            int staffAccountID;

            if (!int.TryParse(
                hfEditStaffAccountID.Value,
                out staffAccountID))
            {
                ShowError("The selected staff account could not be found.");
                return;
            }

            StaffAccount account = new StaffAccount
            {
                StaffAccountID = staffAccountID,
                FirstName = txtEditStaffFirstName.Text,
                MiddleName = txtEditStaffMiddleName.Text,
                LastName = txtEditStaffLastName.Text,
                Suffix = txtEditStaffSuffix.Text,
                Email = txtEditStaffEmail.Text,
                StaffRole = ddlEditStaffRole.SelectedValue,
                IsActive = chkEditStaffIsActive.Checked
            };

            try
            {
                if (!staffAccountService.Update(account))
                {
                    ShowEditStaffFormError("The staff account could not be updated.");
                    return;
                }

                ShowSuccess(account.DisplayName + " updated.");
                LoadStaff();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowEditStaffFormError(
                        "That email address already belongs to a staff account.");
                }
                else
                {
                    ShowEditStaffFormError(
                        "The staff account could not be updated. Try again.");
                }
            }
            catch (ArgumentException exception)
            {
                ShowEditStaffFormError(exception.Message);
            }
            catch (Exception)
            {
                ShowEditStaffFormError(
                    "The staff account could not be updated.");
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

        private void ShowStaffDetails(StaffAccount account)
        {
            lblViewStaffName.Text =
                System.Web.HttpUtility.HtmlEncode(account.DisplayName);
            lblViewStaffEmail.Text =
                System.Web.HttpUtility.HtmlEncode(account.Email);
            lblViewStaffRole.Text =
                string.Equals(
                    account.StaffRole,
                    "ADMIN",
                    StringComparison.OrdinalIgnoreCase)
                    ? "Admin"
                    : "Crew";
            lblViewStaffStatus.Text = account.IsActive
                ? "Active"
                : "Inactive";
            lblViewStaffStatus.CssClass = account.IsActive
                ? "inline-flex items-center rounded-md bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700"
                : "inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600";
            lblViewStaffCreated.Text =
                account.CreatedAt.ToString("MMM d, yyyy");

            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "OpenViewStaffModal",
                "AppModal.open('viewStaffModal');",
                true);
        }

        private void PopulateEditForm(StaffAccount account)
        {
            hfEditStaffAccountID.Value =
                account.StaffAccountID.ToString();
            txtEditStaffFirstName.Text = account.FirstName;
            txtEditStaffMiddleName.Text = account.MiddleName;
            txtEditStaffLastName.Text = account.LastName;
            txtEditStaffSuffix.Text = account.Suffix;
            txtEditStaffEmail.Text = account.Email;
            ddlEditStaffRole.SelectedValue = account.StaffRole;
            chkEditStaffIsActive.Checked = account.IsActive;

            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "OpenEditStaffModal",
                "AppModal.open('editStaffModal');",
                true);
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
            }
            catch (Exception)
            {
                gridStaff.Visible = false;
                ((AdminLayout)Master).ShowErrorAlert(
                    "Staff accounts could not be loaded. Refresh the page to try again.");
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
            ((AdminLayout)Master).ShowSuccessAlert(message);
        }

        private void ShowError(string message)
        {
            ((AdminLayout)Master).ShowErrorAlert(message);
        }

        private void ShowStaffFormError(string message)
        {
            ShowError(message);
            ReopenAddStaffModal();
        }

        private void ShowEditStaffFormError(string message)
        {
            ShowError(message);
            ReopenEditStaffModal();
        }

        private void ReopenAddStaffModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenAddStaffModal",
                "AppModal.open('addStaffModal');",
                true);
        }

        private void ReopenEditStaffModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenEditStaffModal",
                "AppModal.open('editStaffModal');",
                true);
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
