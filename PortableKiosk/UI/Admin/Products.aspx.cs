using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Admin
{
    public partial class ProductManagement : Page
    {
        private readonly CategoryService categoryService =
            new CategoryService();

        private readonly SizeService sizeService =
            new SizeService();

        private readonly ProductService productService =
            new ProductService();

        private readonly ProductVariantService variantService =
            new ProductVariantService();

        public class ProductCardViewModel
        {
            public int ProductID { get; set; }
            public int CategoryID { get; set; }
            public string CategoryName { get; set; }
            public string ProductName { get; set; }
            public bool IsAvailable { get; set; }
            public int DisplayOrder { get; set; }
            public List<ProductVariant> Variants { get; set; }

            public ProductCardViewModel()
            {
                Variants = new List<ProductVariant>();
            }
        }

        public class VariantInputRow
        {
            public int? SizeID { get; set; }
            public string SizeName { get; set; }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (Session["StaffAccountID"] != null &&
                string.Equals(
                    Convert.ToString(Session["StaffRole"]),
                    "ADMIN",
                    StringComparison.OrdinalIgnoreCase))
            {
                LoadSizes();
            }
        }

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
                LoadProductCards();
            }
        }

        #region Product Creation

        protected void btnAddProduct_Click(object sender, EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int categoryID;
            if (!int.TryParse(ddlCategory.SelectedValue, out categoryID))
            {
                ShowError("Please select a valid category.");
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtDisplayOrder.Text.Trim(), out displayOrder))
            {
                ShowError("Display order must be a valid integer.");
                return;
            }

            Product product = new Product
            {
                CategoryID = categoryID,
                ProductName = txtProductName.Text.Trim(),
                DisplayOrder = displayOrder,
                IsAvailable = chkIsAvailable.Checked
            };

            try
            {
                int productID =
                    productService.Add(product);

                ShowSuccess("Product \"" + product.ProductName + "\" added successfully. You can now add size variants below!");
                ClearProductForm();
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowError("A product with this name already exists in this category.");
                }
                else
                {
                    ShowError("The product could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                ShowError("An unexpected error occurred while adding the product.");
            }
        }

        private void ClearProductForm()
        {
            ddlCategory.SelectedIndex = 0;
            txtProductName.Text = string.Empty;
            txtDisplayOrder.Text = "0";
            chkIsAvailable.Checked = true;
        }

        #endregion

        #region Variant Creation via Modal

        protected void btnSaveModalVariant_Click(object sender, EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int productID;
            if (!int.TryParse(hfModalProductID.Value, out productID) || productID <= 0)
            {
                ShowError("Invalid product selected for adding variant.");
                return;
            }

            List<ProductVariant> variants =
                new List<ProductVariant>();

            foreach (RepeaterItem item in
                rptBulkVariantRows.Items)
            {
                CheckBox selected =
                    (CheckBox)item.FindControl(
                        "chkBulkSelected");

                if (selected == null || !selected.Checked)
                {
                    continue;
                }

                HiddenField sizeField =
                    (HiddenField)item.FindControl(
                        "hfBulkSizeID");

                Label sizeNameLabel =
                    (Label)item.FindControl(
                        "lblBulkSizeName");

                TextBox priceField =
                    (TextBox)item.FindControl(
                        "txtBulkPrice");

                int? sizeID = null;
                int parsedSizeID;

                if (!string.IsNullOrWhiteSpace(
                        sizeField.Value) &&
                    int.TryParse(
                        sizeField.Value,
                        out parsedSizeID))
                {
                    sizeID = parsedSizeID;
                }

                decimal price;
                if (!decimal.TryParse(
                        priceField.Text.Trim(),
                        out price) ||
                    price < 0)
                {
                    ShowError(
                        "Enter a valid non-negative price for " +
                        sizeNameLabel.Text + ".");
                    return;
                }

                variants.Add(new ProductVariant
                {
                    ProductID = productID,
                    SizeID = sizeID,
                    Price = price,
                    IsAvailable =
                        chkModalIsAvailable.Checked
                });
            }

            if (variants.Count == 0)
            {
                ShowError(
                    "Select at least one size or serving to add.");
                return;
            }

            string imagePath;
            string savedPhysicalPath;
            string uploadError;

            if (!TrySaveImage(out imagePath, out savedPhysicalPath, out uploadError))
            {
                ShowError(uploadError);
                return;
            }

            foreach (ProductVariant variant in variants)
            {
                variant.ImagePath = imagePath;
            }

            try
            {
                List<int> variantIDs =
                    variantService.AddRange(variants);

                ShowSuccess(
                    variantIDs.Count +
                    (variantIDs.Count == 1
                        ? " variant was"
                        : " variants were") +
                    " added successfully to Product #" +
                    productID + ".");
                ClearModalForm();
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                DeleteSavedImage(savedPhysicalPath);

                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowError(
                        "One or more selected sizes already exist for this product.");
                }
                else
                {
                    ShowError("The variant could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowError("An unexpected error occurred while saving the variant.");
            }
        }

        private void ClearModalForm()
        {
            hfModalProductID.Value = string.Empty;

            foreach (RepeaterItem item in
                rptBulkVariantRows.Items)
            {
                CheckBox selected =
                    (CheckBox)item.FindControl(
                        "chkBulkSelected");

                TextBox priceField =
                    (TextBox)item.FindControl(
                        "txtBulkPrice");

                selected.Checked = false;
                priceField.Text = string.Empty;
            }

            chkModalIsAvailable.Checked = true;
        }

        #endregion

        #region Loading Data & Rendering

        private void LoadCategories()
        {
            try
            {
                List<Category> categories =
                    categoryService.GetAll();

                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new ListItem("-- Select category --", ""));

                foreach (Category cat in categories)
                {
                    ddlCategory.Items.Add(new ListItem(cat.CategoryName, cat.CategoryID.ToString()));
                }
            }
            catch (Exception)
            {
                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new ListItem("Categories unavailable", ""));
                ddlCategory.Enabled = false;
                btnAddProduct.Enabled = false;
                ShowError("Failed to load categories.");
            }
        }

        private void LoadSizes()
        {
            try
            {
                List<Size> sizes = sizeService.GetAll();

                List<VariantInputRow> rows =
                    new List<VariantInputRow>
                    {
                        new VariantInputRow
                        {
                            SizeID = null,
                            SizeName = "Standard / No size"
                        }
                    };

                foreach (Size s in sizes)
                {
                    rows.Add(new VariantInputRow
                    {
                        SizeID = s.SizeID,
                        SizeName = s.SizeName
                    });
                }

                rptBulkVariantRows.DataSource = rows;
                rptBulkVariantRows.DataBind();
            }
            catch (Exception)
            {
                rptBulkVariantRows.DataSource =
                    new List<VariantInputRow>();
                rptBulkVariantRows.DataBind();
                btnSaveModalVariant.Enabled = false;
                ShowError("Sizes could not be loaded.");
            }
        }

        private void LoadProductCards()
        {
            try
            {
                List<Product> products =
                    productService.GetAll();
                List<ProductVariant> variants =
                    variantService.GetAll();

                // Group variants by ProductID
                Dictionary<int, List<ProductVariant>> variantsByProduct = new Dictionary<int, List<ProductVariant>>();
                foreach (ProductVariant v in variants)
                {
                    if (!variantsByProduct.ContainsKey(v.ProductID))
                    {
                        variantsByProduct[v.ProductID] = new List<ProductVariant>();
                    }
                    variantsByProduct[v.ProductID].Add(v);
                }

                List<ProductCardViewModel> cardViewModels = new List<ProductCardViewModel>();
                foreach (Product p in products)
                {
                    ProductCardViewModel vm = new ProductCardViewModel
                    {
                        ProductID = p.ProductID,
                        CategoryID = p.CategoryID,
                        CategoryName = p.CategoryName,
                        ProductName = p.ProductName,
                        IsAvailable = p.IsAvailable,
                        DisplayOrder = p.DisplayOrder
                    };

                    if (variantsByProduct.ContainsKey(p.ProductID))
                    {
                        vm.Variants = variantsByProduct[p.ProductID];
                    }

                    cardViewModels.Add(vm);
                }

                rptProductCards.DataSource = cardViewModels;
                rptProductCards.DataBind();

                pnlNoProducts.Visible = cardViewModels.Count == 0;
                lblProductStats.Text = products.Count + " Products &bull; " + variants.Count + " Total Variants";
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                rptProductCards.DataSource = null;
                rptProductCards.DataBind();
                lblLoadError.Text = "Products and variants could not be loaded.";
                lblLoadError.Visible = true;
            }
        }

        #endregion

        #region File Upload & Notification Helpers

        private bool TrySaveImage(out string imagePath, out string savedPhysicalPath, out string errorMessage)
        {
            imagePath = null;
            savedPhysicalPath = null;
            errorMessage = null;

            if (!uploadModalImage.HasFile)
            {
                return true;
            }

            const int maximumFileSize = 3 * 1024 * 1024;
            if (uploadModalImage.PostedFile.ContentLength > maximumFileSize)
            {
                errorMessage = "The variant image cannot exceed 3 MB.";
                return false;
            }

            string extension = Path.GetExtension(uploadModalImage.FileName).ToLowerInvariant();
            bool allowedExtension = extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".webp";
            if (!allowedExtension)
            {
                errorMessage = "Only JPG, PNG, and WebP images are allowed.";
                return false;
            }

            string contentType = uploadModalImage.PostedFile.ContentType;
            bool allowedContentType =
                string.Equals(contentType, "image/jpeg", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(contentType, "image/png", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(contentType, "image/webp", StringComparison.OrdinalIgnoreCase);

            if (!allowedContentType)
            {
                errorMessage = "The uploaded file is not a supported image.";
                return false;
            }

            try
            {
                string virtualFolder = "~/Content/images/product-variants/";
                string physicalFolder = Server.MapPath(virtualFolder);

                Directory.CreateDirectory(physicalFolder);

                string fileName = Guid.NewGuid().ToString("N") + extension;
                savedPhysicalPath = Path.Combine(physicalFolder, fileName);

                uploadModalImage.SaveAs(savedPhysicalPath);
                imagePath = virtualFolder + fileName;

                return true;
            }
            catch (Exception)
            {
                imagePath = null;
                savedPhysicalPath = null;
                errorMessage = "The image could not be uploaded.";
                return false;
            }
        }

        private void DeleteSavedImage(string physicalPath)
        {
            if (string.IsNullOrWhiteSpace(physicalPath))
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
                // Silent fail to preserve original error
            }
        }

        private void ShowSuccess(string message)
        {
            lblGlobalMessage.Text = "<i class=\"bi bi-check-circle-fill me-1\"></i> " + message;
            lblGlobalMessage.CssClass = "alert alert-success d-block shadow-sm mb-4";
            lblGlobalMessage.Visible = true;
        }

        private void ShowError(string message)
        {
            lblGlobalMessage.Text = "<i class=\"bi bi-exclamation-triangle-fill me-1\"></i> " + message;
            lblGlobalMessage.CssClass = "alert alert-danger d-block shadow-sm mb-4";
            lblGlobalMessage.Visible = true;
        }

        #endregion
    }
}
