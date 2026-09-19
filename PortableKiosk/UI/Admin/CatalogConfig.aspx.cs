using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Admin
{
    public partial class CatalogConfig : System.Web.UI.Page
    {
        private readonly CategoryService categoryService =
            new CategoryService();

        private readonly SizeService sizeService =
            new SizeService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Response.Redirect("~/UI/Account/AdminLogin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/UI/POS/Index.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadCategories();
                LoadSizes();
            }
        }

        #region Categories

        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            lblCategoryMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtCategoryDisplayOrder.Text.Trim(), out displayOrder))
            {
                ShowCategoryError("Display order must be a valid number.");
                return;
            }

            Category category = new Category
            {
                CategoryName = txtCategoryName.Text.Trim(),
                DisplayOrder = displayOrder,
                IsAvailable = chkCategoryIsAvailable.Checked
            };

            try
            {
                int categoryID =
                    categoryService.Add(category);

                ShowCategorySuccess("Category \"" + category.CategoryName + "\" added successfully (ID: " + categoryID + ").");
                ClearCategoryForm();
                LoadCategories();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowCategoryError("A category with this name already exists.");
                }
                else
                {
                    ShowCategoryError("The category could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowCategoryError(ex.Message);
            }
            catch (Exception)
            {
                ShowCategoryError("An unexpected error occurred while saving the category.");
            }
        }

        protected void btnUpdateCategory_Click(
            object sender,
            EventArgs e)
        {
            lblCategoryMessage.Visible = false;
            Page.Validate("EditCategoryForm");

            if (!Page.IsValid)
            {
                return;
            }

            int categoryID;
            int displayOrder;

            if (!int.TryParse(
                    hfEditCategoryID.Value,
                    out categoryID) ||
                categoryID <= 0)
            {
                ShowCategoryError(
                    "The selected category is invalid.");
                return;
            }

            if (!int.TryParse(
                    txtEditCategoryDisplayOrder.Text.Trim(),
                    out displayOrder))
            {
                ShowCategoryError(
                    "Display order must be a valid number.");
                return;
            }

            Category category = new Category
            {
                CategoryID = categoryID,
                CategoryName =
                    txtEditCategoryName.Text.Trim(),
                DisplayOrder = displayOrder,
                IsAvailable =
                    chkEditCategoryIsAvailable.Checked
            };

            try
            {
                if (!categoryService.Update(category))
                {
                    ShowCategoryError(
                        "The category no longer exists.");
                    return;
                }

                ShowCategorySuccess(
                    "Category \"" +
                    category.CategoryName +
                    "\" updated successfully.");
                LoadCategories();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowCategoryError(
                        "A category with this name already exists.");
                }
                else
                {
                    ShowCategoryError(
                        "The category could not be updated due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowCategoryError(ex.Message);
            }
            catch (Exception)
            {
                ShowCategoryError(
                    "An unexpected error occurred while updating the category.");
            }
        }

        protected void btnDeleteCategory_Click(
            object sender,
            EventArgs e)
        {
            lblCategoryMessage.Visible = false;

            int categoryID;
            if (!int.TryParse(
                    hfDeleteCategoryID.Value,
                    out categoryID) ||
                categoryID <= 0)
            {
                ShowCategoryError(
                    "The selected category is invalid.");
                return;
            }

            try
            {
                if (!categoryService.Delete(categoryID))
                {
                    ShowCategoryError(
                        "The category no longer exists.");
                    return;
                }

                ShowCategorySuccess(
                    "Category deleted successfully.");
                LoadCategories();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                {
                    ShowCategoryError(
                        "This category still contains products. Move or delete those products first.");
                }
                else
                {
                    ShowCategoryError(
                        "The category could not be deleted due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowCategoryError(ex.Message);
            }
            catch (Exception)
            {
                ShowCategoryError(
                    "An unexpected error occurred while deleting the category.");
            }
        }

        private void LoadCategories()
        {
            try
            {
                List<Category> categories =
                    categoryService.GetAll();

                gridCategories.DataSource = categories;
                gridCategories.DataBind();

                gridCategories.Visible = true;
                lblCategoryLoadError.Visible = false;
                lblCategoryCount.Text = categories.Count.ToString() + " Categories";
            }
            catch (Exception)
            {
                gridCategories.Visible = false;
                lblCategoryLoadError.Text = "Categories could not be loaded.";
                lblCategoryLoadError.Visible = true;
            }
        }

        private void ClearCategoryForm()
        {
            txtCategoryName.Text = string.Empty;
            txtCategoryDisplayOrder.Text = "0";
            chkCategoryIsAvailable.Checked = true;
        }

        private void ShowCategorySuccess(string message)
        {
            lblCategoryMessage.Text = message;
            lblCategoryMessage.CssClass = "alert alert-success d-block";
            lblCategoryMessage.Visible = true;
        }

        private void ShowCategoryError(string message)
        {
            lblCategoryMessage.Text = message;
            lblCategoryMessage.CssClass = "alert alert-danger d-block";
            lblCategoryMessage.Visible = true;
        }

        #endregion

        #region Sizes

        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            lblSizeMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtSizeDisplayOrder.Text.Trim(), out displayOrder))
            {
                ShowSizeError("Display order must be a valid number.");
                return;
            }

            Size size = new Size
            {
                SizeName = txtSizeName.Text.Trim(),
                DisplayOrder = displayOrder
            };

            try
            {
                int sizeID = sizeService.Add(size);

                ShowSizeSuccess("Size \"" + size.SizeName + "\" added successfully (ID: " + sizeID + ").");
                ClearSizeForm();
                LoadSizes();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowSizeError("A size with this name already exists.");
                }
                else
                {
                    ShowSizeError("The size could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowSizeError(ex.Message);
            }
            catch (Exception)
            {
                ShowSizeError("An unexpected error occurred while saving the size.");
            }
        }

        protected void btnUpdateSize_Click(
            object sender,
            EventArgs e)
        {
            lblSizeMessage.Visible = false;
            Page.Validate("EditSizeForm");

            if (!Page.IsValid)
            {
                return;
            }

            int sizeID;
            int displayOrder;

            if (!int.TryParse(
                    hfEditSizeID.Value,
                    out sizeID) ||
                sizeID <= 0)
            {
                ShowSizeError("The selected size is invalid.");
                return;
            }

            if (!int.TryParse(
                    txtEditSizeDisplayOrder.Text.Trim(),
                    out displayOrder))
            {
                ShowSizeError(
                    "Display order must be a valid number.");
                return;
            }

            Size size = new Size
            {
                SizeID = sizeID,
                SizeName = txtEditSizeName.Text.Trim(),
                DisplayOrder = displayOrder
            };

            try
            {
                if (!sizeService.Update(size))
                {
                    ShowSizeError("The size no longer exists.");
                    return;
                }

                ShowSizeSuccess(
                    "Size \"" +
                    size.SizeName +
                    "\" updated successfully.");
                LoadSizes();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowSizeError(
                        "A size with this name already exists.");
                }
                else
                {
                    ShowSizeError(
                        "The size could not be updated due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowSizeError(ex.Message);
            }
            catch (Exception)
            {
                ShowSizeError(
                    "An unexpected error occurred while updating the size.");
            }
        }

        protected void btnDeleteSize_Click(
            object sender,
            EventArgs e)
        {
            lblSizeMessage.Visible = false;

            int sizeID;
            if (!int.TryParse(
                    hfDeleteSizeID.Value,
                    out sizeID) ||
                sizeID <= 0)
            {
                ShowSizeError("The selected size is invalid.");
                return;
            }

            try
            {
                if (!sizeService.Delete(sizeID))
                {
                    ShowSizeError("The size no longer exists.");
                    return;
                }

                ShowSizeSuccess("Size deleted successfully.");
                LoadSizes();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                {
                    ShowSizeError(
                        "This size is assigned to product variants. Change or delete those variants first.");
                }
                else
                {
                    ShowSizeError(
                        "The size could not be deleted due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowSizeError(ex.Message);
            }
            catch (Exception)
            {
                ShowSizeError(
                    "An unexpected error occurred while deleting the size.");
            }
        }

        private void LoadSizes()
        {
            try
            {
                List<Size> sizes = sizeService.GetAll();

                gridSizes.DataSource = sizes;
                gridSizes.DataBind();

                gridSizes.Visible = true;
                lblSizeLoadError.Visible = false;
                lblSizeCount.Text = sizes.Count.ToString() + " Sizes";
            }
            catch (Exception)
            {
                gridSizes.Visible = false;
                lblSizeLoadError.Text = "Sizes could not be loaded.";
                lblSizeLoadError.Visible = true;
            }
        }

        private void ClearSizeForm()
        {
            txtSizeName.Text = string.Empty;
            txtSizeDisplayOrder.Text = "0";
        }

        private void ShowSizeSuccess(string message)
        {
            lblSizeMessage.Text = message;
            lblSizeMessage.CssClass = "alert alert-success d-block";
            lblSizeMessage.Visible = true;
        }

        private void ShowSizeError(string message)
        {
            lblSizeMessage.Text = message;
            lblSizeMessage.CssClass = "alert alert-danger d-block";
            lblSizeMessage.Visible = true;
        }

        #endregion
    }
}
