using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Layouts;

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
                ShowPendingSuccessAlert();
            }
        }

        #region Categories

        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                ReopenAddCategoryModal();
                return;
            }

            Category category = new Category
            {
                CategoryName = txtCategoryName.Text.Trim(),
                IsAvailable = chkCategoryIsAvailable.Checked
            };

            try
            {
                categoryService.Add(category);

                RedirectAfterSuccess(
                    "Category \"" + category.CategoryName + "\" added successfully.");
                return;
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
                ReopenAddCategoryModal();
            }
            catch (ArgumentException ex)
            {
                ShowCategoryError(ex.Message);
                ReopenAddCategoryModal();
            }
            catch (Exception)
            {
                ShowCategoryError("An unexpected error occurred while saving the category.");
                ReopenAddCategoryModal();
            }
        }

        private void ReopenAddCategoryModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenAddCategoryModal",
                "AppModal.open('addCategoryModal');",
                true);
        }

        private void ReopenEditCategoryModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenEditCategoryModal",
                "AppModal.open('editCategoryModal');",
                true);
        }

        protected void btnUpdateCategory_Click(
            object sender,
            EventArgs e)
        {
            Page.Validate("EditCategoryForm");

            if (!Page.IsValid)
            {
                ReopenEditCategoryModal();
                return;
            }

            int categoryID;

            if (!int.TryParse(
                    hfEditCategoryID.Value,
                    out categoryID) ||
                categoryID <= 0)
            {
                ShowEditCategoryError(
                    "The selected category is invalid.");
                return;
            }

            Category category = new Category
            {
                CategoryID = categoryID,
                CategoryName =
                    txtEditCategoryName.Text.Trim(),
                IsAvailable =
                    chkEditCategoryIsAvailable.Checked
            };

            try
            {
                if (!categoryService.Update(category))
                {
                    ShowEditCategoryError(
                        "The category no longer exists.");
                    return;
                }

                RedirectAfterSuccess(
                    "Category \"" +
                    category.CategoryName +
                    "\" updated successfully.");
                return;
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowEditCategoryError(
                        "A category with this name already exists.");
                }
                else
                {
                    ShowEditCategoryError(
                        "The category could not be updated due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowEditCategoryError(ex.Message);
            }
            catch (Exception)
            {
                ShowEditCategoryError(
                    "An unexpected error occurred while updating the category.");
            }
        }

        protected void btnDeleteCategory_Click(
            object sender,
            EventArgs e)
        {
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

                RedirectAfterSuccess("Category deleted successfully.");
                return;
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
                lblCategoryCount.Text = categories.Count.ToString() + " Categories";
            }
            catch (Exception)
            {
                gridCategories.Visible = false;
                ((AdminLayout)Master).ShowErrorAlert(
                    "Categories could not be loaded.");
            }
        }

        private void ShowCategoryError(string message)
        {
            ((AdminLayout)Master).ShowErrorAlert(message);
        }

        private void ShowEditCategoryError(string message)
        {
            ShowCategoryError(message);
            ReopenEditCategoryModal();
        }

        #endregion

        #region Sizes

        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                ReopenAddSizeModal();
                return;
            }

            Size size = new Size
            {
                SizeName = txtSizeName.Text.Trim()
            };

            try
            {
                sizeService.Add(size);

                RedirectAfterSuccess(
                    "Size \"" + size.SizeName + "\" added successfully.");
                return;
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
                ReopenAddSizeModal();
            }
            catch (ArgumentException ex)
            {
                ShowSizeError(ex.Message);
                ReopenAddSizeModal();
            }
            catch (Exception)
            {
                ShowSizeError("An unexpected error occurred while saving the size.");
                ReopenAddSizeModal();
            }
        }

        private void ReopenAddSizeModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenAddSizeModal",
                "AppModal.open('addSizeModal');",
                true);
        }

        private void ReopenEditSizeModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenEditSizeModal",
                "AppModal.open('editSizeModal');",
                true);
        }

        protected void btnUpdateSize_Click(
            object sender,
            EventArgs e)
        {
            Page.Validate("EditSizeForm");

            if (!Page.IsValid)
            {
                ReopenEditSizeModal();
                return;
            }

            int sizeID;

            if (!int.TryParse(
                    hfEditSizeID.Value,
                    out sizeID) ||
                sizeID <= 0)
            {
                ShowEditSizeError("The selected size is invalid.");
                return;
            }

            Size size = new Size
            {
                SizeID = sizeID,
                SizeName = txtEditSizeName.Text.Trim()
            };

            try
            {
                if (!sizeService.Update(size))
                {
                    ShowEditSizeError("The size no longer exists.");
                    return;
                }

                RedirectAfterSuccess(
                    "Size \"" +
                    size.SizeName +
                    "\" updated successfully.");
                return;
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowEditSizeError(
                        "A size with this name already exists.");
                }
                else
                {
                    ShowEditSizeError(
                        "The size could not be updated due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowEditSizeError(ex.Message);
            }
            catch (Exception)
            {
                ShowEditSizeError(
                    "An unexpected error occurred while updating the size.");
            }
        }

        protected void btnDeleteSize_Click(
            object sender,
            EventArgs e)
        {
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

                RedirectAfterSuccess("Size deleted successfully.");
                return;
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
                lblSizeCount.Text = sizes.Count.ToString() + " Sizes";
            }
            catch (Exception)
            {
                gridSizes.Visible = false;
                ((AdminLayout)Master).ShowErrorAlert(
                    "Sizes could not be loaded.");
            }
        }

        private void RedirectAfterSuccess(string message)
        {
            Session["CatalogConfig.SuccessMessage"] = message;
            Response.Redirect(
                ResolveUrl("~/UI/Admin/CatalogConfig.aspx"),
                false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowPendingSuccessAlert()
        {
            string message =
                Session["CatalogConfig.SuccessMessage"] as string;

            if (message == null)
            {
                return;
            }

            Session.Remove("CatalogConfig.SuccessMessage");
            ((AdminLayout)Master).ShowSuccessAlert(message);
        }

        private void ShowSizeError(string message)
        {
            ((AdminLayout)Master).ShowErrorAlert(message);
        }

        private void ShowEditSizeError(string message)
        {
            ShowSizeError(message);
            ReopenEditSizeModal();
        }

        #endregion
    }
}
