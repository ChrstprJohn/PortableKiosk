using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PortableKiosk.UI.Admin
{
    public partial class ProductManagement :
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
                LoadCategories();
                LoadProducts();
            }
        }

        protected void btnAddProduct_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int categoryID;

            if (!int.TryParse(
                ddlCategory.SelectedValue,
                out categoryID))
            {
                ShowError(
                    "Please select a valid category.");
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

            Product product = new Product
            {
                CategoryID = categoryID,
                ProductName =
                    txtProductName.Text.Trim(),
                IsAvailable =
                    chkIsAvailable.Checked,
                DisplayOrder = displayOrder
            };

            try
            {
                ProductRepository repository =
                    new ProductRepository();

                int productID =
                    repository.Add(product);

                ShowSuccess(
                    "Product added successfully. ID: " +
                    productID);

                ClearForm();
                LoadProducts();
            }
            catch (SqlException)
            {
                ShowError(
                    "The product could not be saved.");
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

                List<Category> categories =
                    repository.GetAll();

                ddlCategory.DataSource = categories;
                ddlCategory.DataTextField =
                    "CategoryName";
                ddlCategory.DataValueField =
                    "CategoryID";
                ddlCategory.DataBind();

                ddlCategory.Items.Insert(
                    0,
                    new ListItem(
                        "-- Select category --",
                        ""));
            }
            catch (Exception)
            {
                ddlCategory.Items.Clear();

                ddlCategory.Items.Add(
                    new ListItem(
                        "Categories unavailable",
                        ""));

                ddlCategory.Enabled = false;
                btnAddProduct.Enabled = false;

                ShowError(
                    "Categories could not be loaded.");
            }
        }

        private void LoadProducts()
        {
            try
            {
                ProductRepository repository =
                    new ProductRepository();

                List<Product> products =
                    repository.GetAll();

                gridProducts.DataSource = products;
                gridProducts.DataBind();

                gridProducts.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridProducts.Visible = false;

                lblLoadError.Text =
                    "Products could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private void ClearForm()
        {
            ddlCategory.SelectedIndex = 0;
            txtProductName.Text = string.Empty;
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