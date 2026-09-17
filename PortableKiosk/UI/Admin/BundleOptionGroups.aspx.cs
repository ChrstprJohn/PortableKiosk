using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace PortableKiosk.UI.Admin
{
    public partial class BundleOptionGroupManagement :
        System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Response.Redirect(
                    "~/UI/Account/AdminLogin.aspx",
                    false);

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect(
                    "~/UI/POS/Index.aspx",
                    false);

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }

            if (!IsPostBack)
            {
                LoadOptionGroups();
            }
        }

        protected void btnAddOptionGroup_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int displayOrder;

            if (!int.TryParse(
                txtDisplayOrder.Text.Trim(),
                out displayOrder))
            {
                ShowError(
                    "Display order must be a valid number.");
                return;
            }

            BundleOptionGroup optionGroup =
                new BundleOptionGroup
                {
                    OptionGroupName =
                        txtOptionGroupName.Text.Trim(),

                    IsAvailable =
                        chkIsAvailable.Checked,

                    DisplayOrder =
                        displayOrder
                };

            try
            {
                BundleOptionGroupRepository repository =
                    new BundleOptionGroupRepository();

                int optionGroupID =
                    repository.Add(optionGroup);

                ShowSuccess(
                    "Option group added successfully. ID: " +
                    optionGroupID);

                ClearForm();
                LoadOptionGroups();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "An option group with this name already exists.");
                }
                else
                {
                    ShowError(
                        "The option group could not be saved.");
                }
            }
            catch (ArgumentException exception)
            {
                ShowError(exception.Message);
            }
            catch (Exception)
            {
                ShowError(
                    "An unexpected error occurred.");
            }
        }

        private void LoadOptionGroups()
        {
            try
            {
                BundleOptionGroupRepository repository =
                    new BundleOptionGroupRepository();

                List<BundleOptionGroup> optionGroups =
                    repository.GetAll();

                gridOptionGroups.DataSource =
                    optionGroups;

                gridOptionGroups.DataBind();

                gridOptionGroups.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridOptionGroups.Visible = false;

                lblLoadError.Text =
                    "Option groups could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private void ClearForm()
        {
            txtOptionGroupName.Text =
                string.Empty;

            txtDisplayOrder.Text = "0";
            chkIsAvailable.Checked = true;
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
    }
}