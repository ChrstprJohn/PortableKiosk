using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace PortableKiosk.UI.Admin
{
    public partial class ProductVariantManagement :
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
                LoadProducts();
                LoadSizes();
                LoadVariants();
            }
        }

        protected void btnAddVariant_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int productID;

            if (!int.TryParse(
                ddlProduct.SelectedValue,
                out productID))
            {
                ShowError(
                    "Please select a valid product.");
                return;
            }

            int? sizeID = null;

            if (!string.IsNullOrWhiteSpace(
                ddlSize.SelectedValue))
            {
                int parsedSizeID;

                if (!int.TryParse(
                    ddlSize.SelectedValue,
                    out parsedSizeID))
                {
                    ShowError(
                        "Please select a valid size.");
                    return;
                }

                sizeID = parsedSizeID;
            }

            decimal price;

            if (!decimal.TryParse(
                txtPrice.Text.Trim(),
                out price))
            {
                ShowError(
                    "Price must be a valid number.");
                return;
            }

            if (price < 0)
            {
                ShowError(
                    "Price cannot be negative.");
                return;
            }

            string imagePath;
            string savedPhysicalPath;
            string uploadError;

            if (!TrySaveImage(
                out imagePath,
                out savedPhysicalPath,
                out uploadError))
            {
                ShowError(uploadError);
                return;
            }

            ProductVariant variant =
                new ProductVariant
                {
                    ProductID = productID,
                    SizeID = sizeID,
                    Price = price,
                    ImagePath = imagePath,
                    IsAvailable =
                        chkIsAvailable.Checked
                };

            try
            {
                ProductVariantRepository repository =
                    new ProductVariantRepository();

                int productVariantID =
                    repository.Add(variant);

                ShowSuccess(
                    "Product variant added successfully. ID: " +
                    productVariantID);

                ClearForm();
                LoadVariants();
            }
            catch (SqlException exception)
            {
                DeleteSavedImage(savedPhysicalPath);

                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "This product and size combination already exists.");
                }
                else
                {
                    ShowError(
                        "The product variant could not be saved.");
                }
            }
            catch (ArgumentException exception)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowError(exception.Message);
            }
            catch (Exception)
            {
                DeleteSavedImage(savedPhysicalPath);

                ShowError(
                    "An unexpected error occurred.");
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

                ddlProduct.Items.Clear();

                ddlProduct.Items.Add(
                    new ListItem(
                        "-- Select product --",
                        ""));

                foreach (Product product in products)
                {
                    string displayText =
                        product.CategoryName +
                        " - " +
                        product.ProductName;

                    ddlProduct.Items.Add(
                        new ListItem(
                            displayText,
                            product.ProductID.ToString()));
                }
            }
            catch (Exception)
            {
                ddlProduct.Items.Clear();

                ddlProduct.Items.Add(
                    new ListItem(
                        "Products unavailable",
                        ""));

                ddlProduct.Enabled = false;
                btnAddVariant.Enabled = false;

                ShowError(
                    "Products could not be loaded.");
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

                ddlSize.DataSource = sizes;
                ddlSize.DataTextField = "SizeName";
                ddlSize.DataValueField = "SizeID";
                ddlSize.DataBind();

                ddlSize.Items.Insert(
                    0,
                    new ListItem(
                        "-- No size --",
                        ""));
            }
            catch (Exception)
            {
                ddlSize.Items.Clear();

                ddlSize.Items.Add(
                    new ListItem(
                        "Sizes unavailable",
                        ""));

                ddlSize.Enabled = false;
                btnAddVariant.Enabled = false;

                ShowError(
                    "Sizes could not be loaded.");
            }
        }

        private void LoadVariants()
        {
            try
            {
                ProductVariantRepository repository =
                    new ProductVariantRepository();

                List<ProductVariant> variants =
                    repository.GetAll();

                gridVariants.DataSource = variants;
                gridVariants.DataBind();

                gridVariants.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridVariants.Visible = false;

                lblLoadError.Text =
                    "Product variants could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private bool TrySaveImage(
            out string imagePath,
            out string savedPhysicalPath,
            out string errorMessage)
        {
            imagePath = null;
            savedPhysicalPath = null;
            errorMessage = null;

            if (!uploadImage.HasFile)
            {
                return true;
            }

            const int maximumFileSize =
                3 * 1024 * 1024;

            if (uploadImage.PostedFile.ContentLength >
                maximumFileSize)
            {
                errorMessage =
                    "The image cannot exceed 3 MB.";
                return false;
            }

            string extension =
                Path.GetExtension(
                    uploadImage.FileName)
                    .ToLowerInvariant();

            bool allowedExtension =
                extension == ".jpg" ||
                extension == ".jpeg" ||
                extension == ".png" ||
                extension == ".webp";

            if (!allowedExtension)
            {
                errorMessage =
                    "Only JPG, PNG, and WebP images are allowed.";
                return false;
            }

            string contentType =
                uploadImage.PostedFile.ContentType;

            bool allowedContentType =
                string.Equals(
                    contentType,
                    "image/jpeg",
                    StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    contentType,
                    "image/png",
                    StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    contentType,
                    "image/webp",
                    StringComparison.OrdinalIgnoreCase);

            if (!allowedContentType)
            {
                errorMessage =
                    "The uploaded file is not a supported image.";
                return false;
            }

            try
            {
                string virtualFolder =
                    "~/Content/images/product-variants/";

                string physicalFolder =
                    Server.MapPath(virtualFolder);

                Directory.CreateDirectory(
                    physicalFolder);

                string fileName =
                    Guid.NewGuid().ToString("N") +
                    extension;

                savedPhysicalPath =
                    Path.Combine(
                        physicalFolder,
                        fileName);

                uploadImage.SaveAs(
                    savedPhysicalPath);

                imagePath =
                    virtualFolder + fileName;

                return true;
            }
            catch (Exception)
            {
                imagePath = null;
                savedPhysicalPath = null;

                errorMessage =
                    "The image could not be uploaded.";

                return false;
            }
        }

        private void DeleteSavedImage(
            string physicalPath)
        {
            if (string.IsNullOrWhiteSpace(
                physicalPath))
            {
                return;
            }

            try
            {
                if (File.Exists(physicalPath))
                {
                    File.Delete(physicalPath);
                }
            }
            catch
            {
                // Do not replace the original database error.
            }
        }

        private void ClearForm()
        {
            ddlProduct.SelectedIndex = 0;
            ddlSize.SelectedIndex = 0;
            txtPrice.Text = string.Empty;
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