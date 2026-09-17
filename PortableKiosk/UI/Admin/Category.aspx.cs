using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.UI.Admin
{
    public partial class CategoryList : System.Web.UI.Page
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
                LoadCategories();
            }
        }

        protected void btnAddCategory_Click(
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
                ShowError("Display order must be a valid number.");
                return;
            }



            Category category = new Category
            {
                CategoryName = txtCategoryName.Text.Trim(),
                DisplayOrder = displayOrder,
                IsAvailable = chkIsAvailable.Checked
            };

            try
            {
                CategoryRepository repository =
                    new CategoryRepository();

                // Calls the Add function in CategoryRepository.
                int categoryID = repository.Add(category);

                ShowSuccess(
                    "Category added successfully. ID: " +
                    categoryID);

                ClearForm();

                // Refresh the table after adding.
                LoadCategories();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "A category with this name already exists.");
                }
                else
                {
                    ShowError(
                        "The category could not be saved.");
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

        private void LoadCategories()
        {
            try
            {
                CategoryRepository repository =
                    new CategoryRepository();

                // Calls GetAll from CategoryRepository.
                List<Category> categories =
                    repository.GetAll();

                gridCategories.DataSource = categories;
                gridCategories.DataBind();

                gridCategories.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridCategories.Visible = false;

                lblLoadError.Text =
                    "Categories could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private void ClearForm()
        {
            txtCategoryName.Text = string.Empty;
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
