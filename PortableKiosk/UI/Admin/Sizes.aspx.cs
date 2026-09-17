using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.UI.Admin
{
    public partial class SizeManagement : System.Web.UI.Page
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

                Context.ApplicationInstance.CompleteRequest();
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

                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadSizes();
            }
        }

        protected void btnAddSize_Click(
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

            Size size = new Size
            {
                SizeName = txtSizeName.Text.Trim(),
                DisplayOrder = displayOrder
            };

            try
            {
                SizeRepository repository =
                    new SizeRepository();

                int sizeID = repository.Add(size);

                ShowSuccess(
                    "Size added successfully. ID: " +
                    sizeID);

                ClearForm();
                LoadSizes();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "A size with this name already exists.");
                }
                else
                {
                    ShowError(
                        "The size could not be saved.");
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

        private void LoadSizes()
        {
            try
            {
                SizeRepository repository =
                    new SizeRepository();

                List<Size> sizes =
                    repository.GetAll();

                gridSizes.DataSource = sizes;
                gridSizes.DataBind();

                gridSizes.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridSizes.Visible = false;

                lblLoadError.Text =
                    "Sizes could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private void ClearForm()
        {
            txtSizeName.Text = string.Empty;
            txtDisplayOrder.Text = "0";
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