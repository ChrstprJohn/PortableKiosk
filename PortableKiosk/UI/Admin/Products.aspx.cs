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

        private List<Size> variantSizes = new List<Size>();

        public class ProductCardViewModel
        {
            public int ProductID { get; set; }
            public int CategoryID { get; set; }
            public string CategoryName { get; set; }
            public string ProductName { get; set; }
            public string ProductDescription { get; set; }
            public bool IsAvailable { get; set; }
            public List<ProductVariant> Variants { get; set; }
            public string ExistingSizeKeys { get; set; }

            public ProductCardViewModel()
            {
                Variants = new List<ProductVariant>();
                ExistingSizeKeys = string.Empty;
            }
        }

        public class VariantInputRow
        {
            public int RowNumber { get; set; }
        }

        private class PendingVariantInput
        {
            public ProductVariant Variant { get; set; }
            public FileUpload ImageUpload { get; set; }
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
                ReopenAddProductModal();
                return;
            }

            int categoryID;
            if (!int.TryParse(ddlCategory.SelectedValue, out categoryID))
            {
                ShowAddProductError("Please select a valid category.");
                return;
            }

            Product product = new Product
            {
                CategoryID = categoryID,
                ProductName = txtProductName.Text.Trim(),
                IsAvailable = chkIsAvailable.Checked
            };

            try
            {
                productService.Add(product);

                ShowSuccess("Product added.");
                ClearProductForm();
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowAddProductError("A product with this name already exists in this category.");
                }
                else
                {
                    ShowAddProductError("The product could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowAddProductError(ex.Message);
            }
            catch (Exception)
            {
                ShowAddProductError("The product could not be added.");
            }
        }

        private void ShowAddProductError(string message)
        {
            ShowError(message);
            ReopenAddProductModal();
        }

        private void ReopenAddProductModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenAddProductModal",
                "AppModal.open('addProductModal');",
                true);
        }

        private void ClearProductForm()
        {
            ddlCategory.SelectedIndex = 0;
            txtProductName.Text = string.Empty;
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

            List<PendingVariantInput> pendingVariants =
                new List<PendingVariantInput>();

            foreach (RepeaterItem item in
                rptBulkVariantRows.Items)
            {
                DropDownList sizeField =
                    (DropDownList)item.FindControl(
                        "ddlBulkSize");

                if (sizeField == null ||
                    string.IsNullOrWhiteSpace(sizeField.SelectedValue))
                {
                    continue;
                }

                TextBox priceField =
                    (TextBox)item.FindControl(
                        "txtBulkPrice");

                FileUpload imageUpload =
                    (FileUpload)item.FindControl(
                        "uploadBulkImage");

                int? sizeID = null;
                int parsedSizeID;

                if (!string.Equals(
                        sizeField.SelectedValue,
                        "NONE",
                        StringComparison.OrdinalIgnoreCase))
                {
                    if (!int.TryParse(
                            sizeField.SelectedValue,
                            out parsedSizeID) ||
                        parsedSizeID <= 0)
                    {
                        ShowError("Choose a valid size or serving.");
                        return;
                    }

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
                        sizeField.SelectedItem.Text + ".");
                    return;
                }

                pendingVariants.Add(new PendingVariantInput
                {
                    Variant = new ProductVariant
                    {
                        ProductID = productID,
                        SizeID = sizeID,
                        Price = price,
                        IsAvailable =
                            chkModalIsAvailable.Checked
                    },
                    ImageUpload = imageUpload,
                    SizeName = sizeField.SelectedItem.Text
                });
            }

            if (pendingVariants.Count == 0)
            {
                ShowError(
                    "Add at least one size or serving before saving.");
                return;
            }

            List<ProductVariant> variants =
                new List<ProductVariant>();

            List<string> savedPhysicalPaths =
                new List<string>();

            foreach (PendingVariantInput pending in pendingVariants)
            {
                string imagePath;
                string savedPhysicalPath;
                string uploadError;

                if (!TrySaveImage(
                        pending.ImageUpload,
                        out imagePath,
                        out savedPhysicalPath,
                        out uploadError))
                {
                    DeleteSavedImages(savedPhysicalPaths);
                    ShowError(
                        "Image for " + pending.SizeName + ": " +
                        uploadError);
                    return;
                }

                pending.Variant.ImagePath = imagePath;
                variants.Add(pending.Variant);

                if (!string.IsNullOrWhiteSpace(savedPhysicalPath))
                {
                    savedPhysicalPaths.Add(savedPhysicalPath);
                }
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
                DeleteSavedImages(savedPhysicalPaths);

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
                DeleteSavedImages(savedPhysicalPaths);
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                DeleteSavedImages(savedPhysicalPaths);
                ShowError("An unexpected error occurred while saving the variant.");
            }
        }

        private void ClearModalForm()
        {
            hfModalProductID.Value = string.Empty;

            foreach (RepeaterItem item in
                rptBulkVariantRows.Items)
            {
                DropDownList sizeField =
                    (DropDownList)item.FindControl(
                        "ddlBulkSize");

                TextBox priceField =
                    (TextBox)item.FindControl(
                        "txtBulkPrice");

                sizeField.SelectedIndex = 0;
                priceField.Text = string.Empty;
            }

            chkModalIsAvailable.Checked = true;
        }

        protected void btnUpdateVariant_Click(
            object sender,
            EventArgs e)
        {
            lblGlobalMessage.Visible = false;
            Page.Validate("EditVariantForm");

            if (!Page.IsValid)
            {
                return;
            }

            int productVariantID;
            if (!int.TryParse(
                    hfEditVariantID.Value,
                    out productVariantID) ||
                productVariantID <= 0)
            {
                ShowError("The selected variant is invalid.");
                return;
            }

            int? sizeID = null;
            int parsedSizeID;

            if (!string.Equals(
                    ddlEditVariantSize.SelectedValue,
                    "NONE",
                    StringComparison.OrdinalIgnoreCase))
            {
                if (!int.TryParse(
                        ddlEditVariantSize.SelectedValue,
                        out parsedSizeID) ||
                    parsedSizeID <= 0)
                {
                    ShowError("Choose a valid size or serving.");
                    return;
                }

                sizeID = parsedSizeID;
            }

            decimal price;
            if (!decimal.TryParse(
                    txtEditVariantPrice.Text.Trim(),
                    out price) ||
                price < 0)
            {
                ShowError("Enter a valid non-negative price.");
                return;
            }

            ProductVariant existingVariant;

            try
            {
                existingVariant =
                    variantService.GetByID(productVariantID);
            }
            catch (Exception)
            {
                ShowError(
                    "The variant could not be loaded for editing.");
                return;
            }

            if (existingVariant == null)
            {
                ShowError("The variant no longer exists.");
                return;
            }

            string newImagePath;
            string savedPhysicalPath;
            string uploadError;

            if (!TrySaveImage(
                    uploadEditVariantImage,
                    out newImagePath,
                    out savedPhysicalPath,
                    out uploadError))
            {
                ShowError(uploadError);
                return;
            }

            ProductVariant updatedVariant = new ProductVariant
            {
                ProductVariantID = productVariantID,
                ProductID = existingVariant.ProductID,
                SizeID = sizeID,
                Price = price,
                ImagePath =
                    string.IsNullOrWhiteSpace(newImagePath)
                        ? existingVariant.ImagePath
                        : newImagePath,
                IsAvailable =
                    chkEditVariantIsAvailable.Checked
            };

            try
            {
                if (!variantService.Update(updatedVariant))
                {
                    DeleteSavedImage(savedPhysicalPath);
                    ShowError("The variant no longer exists.");
                    return;
                }

                if (!string.IsNullOrWhiteSpace(newImagePath))
                {
                    DeleteSavedImageByVirtualPath(
                        existingVariant.ImagePath);
                }

                ShowSuccess("Variant updated successfully.");
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                DeleteSavedImage(savedPhysicalPath);

                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowError(
                        "That size already exists for this product.");
                }
                else
                {
                    ShowError(
                        "The variant could not be updated due to a database error.");
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
                ShowError(
                    "An unexpected error occurred while updating the variant.");
            }
        }

        protected void btnDeleteVariant_Click(
            object sender,
            EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            int productVariantID;
            if (!int.TryParse(
                    hfDeleteVariantID.Value,
                    out productVariantID) ||
                productVariantID <= 0)
            {
                ShowError("The selected variant is invalid.");
                return;
            }

            try
            {
                ProductVariant existingVariant =
                    variantService.GetByID(productVariantID);

                if (existingVariant == null)
                {
                    ShowError("The variant no longer exists.");
                    return;
                }

                if (!variantService.Delete(productVariantID))
                {
                    ShowError("The variant no longer exists.");
                    return;
                }

                DeleteSavedImageByVirtualPath(
                    existingVariant.ImagePath);

                ShowSuccess("Variant deleted successfully.");
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                {
                    ShowError(
                        "This variant is used in an order. Mark it unavailable instead of deleting it.");
                }
                else
                {
                    ShowError(
                        "The variant could not be deleted due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                ShowError(
                    "An unexpected error occurred while deleting the variant.");
            }
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
                variantSizes = sizeService.GetAll();

                ddlEditVariantSize.Items.Clear();
                ddlEditVariantSize.Items.Add(
                    new ListItem(
                        "Choose size / serving",
                        ""));
                ddlEditVariantSize.Items.Add(
                    new ListItem(
                        "Standard / No size",
                        "NONE"));

                foreach (Size size in variantSizes)
                {
                    ddlEditVariantSize.Items.Add(
                        new ListItem(
                            size.SizeName,
                            size.SizeID.ToString()));
                }

                List<VariantInputRow> rows =
                    new List<VariantInputRow>();

                for (int rowIndex = 0;
                    rowIndex < variantSizes.Count + 1;
                    rowIndex++)
                {
                    rows.Add(new VariantInputRow
                    {
                        RowNumber = rowIndex + 1
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
                ddlEditVariantSize.Items.Clear();
                ddlEditVariantSize.Items.Add(
                    new ListItem(
                        "Sizes unavailable",
                        ""));
                ddlEditVariantSize.Enabled = false;
                btnSaveModalVariant.Enabled = false;
                btnUpdateVariant.Enabled = false;
                ShowError("Sizes could not be loaded.");
            }
        }

        protected void rptBulkVariantRows_ItemDataBound(
            object sender,
            RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            DropDownList sizeField =
                (DropDownList)e.Item.FindControl("ddlBulkSize");

            sizeField.Items.Add(
                new ListItem("Choose size / serving", ""));
            sizeField.Items.Add(
                new ListItem("Standard / No size", "NONE"));

            foreach (Size size in variantSizes)
            {
                sizeField.Items.Add(
                    new ListItem(
                        size.SizeName,
                        size.SizeID.ToString()));
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
                        ProductDescription = p.ProductDescription,
                        IsAvailable = p.IsAvailable
                    };

                    if (variantsByProduct.ContainsKey(p.ProductID))
                    {
                        vm.Variants = variantsByProduct[p.ProductID];
                    }

                    List<string> existingSizeKeys =
                        new List<string>();

                    foreach (ProductVariant variant in vm.Variants)
                    {
                        existingSizeKeys.Add(
                            variant.SizeID.HasValue
                                ? variant.SizeID.Value.ToString()
                                : "NONE");
                    }

                    vm.ExistingSizeKeys =
                        string.Join(",", existingSizeKeys);

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

        private bool TrySaveImage(
            FileUpload imageUpload,
            out string imagePath,
            out string savedPhysicalPath,
            out string errorMessage)
        {
            imagePath = null;
            savedPhysicalPath = null;
            errorMessage = null;

            if (imageUpload == null || !imageUpload.HasFile)
            {
                return true;
            }

            const int maximumFileSize = 3 * 1024 * 1024;
            if (imageUpload.PostedFile.ContentLength > maximumFileSize)
            {
                errorMessage = "The variant image cannot exceed 3 MB.";
                return false;
            }

            string extension = Path.GetExtension(imageUpload.FileName).ToLowerInvariant();
            bool allowedExtension = extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".webp";
            if (!allowedExtension)
            {
                errorMessage = "Only JPG, PNG, and WebP images are allowed.";
                return false;
            }

            string contentType = imageUpload.PostedFile.ContentType;
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

                imageUpload.SaveAs(savedPhysicalPath);
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

        private void DeleteSavedImages(
            IEnumerable<string> physicalPaths)
        {
            foreach (string physicalPath in physicalPaths)
            {
                DeleteSavedImage(physicalPath);
            }
        }

        private void DeleteSavedImageByVirtualPath(
            string virtualPath)
        {
            if (string.IsNullOrWhiteSpace(virtualPath) ||
                !virtualPath.StartsWith(
                    "~/Content/images/product-variants/",
                    StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            try
            {
                string imageFolder = Path.GetFullPath(
                    Server.MapPath(
                        "~/Content/images/product-variants/"));
                string physicalPath = Path.GetFullPath(
                    Server.MapPath(virtualPath));

                if (physicalPath.StartsWith(
                        imageFolder,
                        StringComparison.OrdinalIgnoreCase))
                {
                    DeleteSavedImage(physicalPath);
                }
            }
            catch
            {
                // A database change should not fail because an old image could not be removed.
            }
        }

        private void ShowSuccess(string message)
        {
            lblGlobalMessage.Text = message;
            lblGlobalMessage.CssClass = "mb-4 block rounded-md border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800";
            lblGlobalMessage.Visible = true;
        }

        private void ShowError(string message)
        {
            lblGlobalMessage.Text = message;
            lblGlobalMessage.CssClass = "mb-4 block rounded-md border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800";
            lblGlobalMessage.Visible = true;
        }

        #endregion
    }
}
