using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Layouts;

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

        public class ProductCategoryGroupViewModel
        {
            public int CategoryID { get; set; }
            public string CategoryName { get; set; }
            public List<ProductCardViewModel> Products { get; set; }

            public ProductCategoryGroupViewModel()
            {
                Products = new List<ProductCardViewModel>();
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

        protected void btnUpdateProduct_Click(object sender, EventArgs e)
        {

            if (!Page.IsValid)
            {
                ReopenEditProductModal();
                return;
            }

            int productID;
            int categoryID;
            if (!int.TryParse(hfEditProductID.Value, out productID) ||
                productID <= 0)
            {
                ShowEditProductError("The selected product is invalid.");
                return;
            }

            if (!int.TryParse(ddlEditProductCategory.SelectedValue, out categoryID))
            {
                ShowEditProductError("Please select a valid category.");
                return;
            }

            try
            {
                Product existingProduct = productService.GetByID(productID);
                if (existingProduct == null)
                {
                    ShowEditProductError("The product no longer exists.");
                    return;
                }

                Product updatedProduct = new Product
                {
                    ProductID = productID,
                    CategoryID = categoryID,
                    ProductName = txtEditProductName.Text.Trim(),
                    ProductDescription = txtEditProductDescription.Text.Trim(),
                    IsAvailable = chkEditProductIsAvailable.Checked
                };

                if (!productService.Update(updatedProduct))
                {
                    ShowEditProductError("The product could not be updated.");
                    return;
                }

                ShowSuccess("Product updated.");
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowEditProductError(
                        "A product with this name already exists in this category.");
                }
                else
                {
                    ShowEditProductError(
                        "The product could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowEditProductError(ex.Message);
            }
            catch (Exception)
            {
                ShowEditProductError("The product could not be updated.");
            }
        }

        protected void btnDeleteProduct_Click(object sender, EventArgs e)
        {

            int productID;
            if (!int.TryParse(hfDeleteProductID.Value, out productID) ||
                productID <= 0)
            {
                ShowError("The selected product is invalid.");
                return;
            }

            try
            {
                Product existingProduct = productService.GetByID(productID);
                if (existingProduct == null)
                {
                    ShowError("The product no longer exists.");
                    return;
                }

                List<ProductVariant> existingVariants =
                    variantService.GetByProductID(productID);

                if (!productService.Delete(productID))
                {
                    ShowError("The product no longer exists.");
                    return;
                }

                foreach (ProductVariant variant in existingVariants)
                {
                    DeleteSavedImageByVirtualPath(variant.ImagePath);
                }

                ShowSuccess("Product deleted.");
                LoadProductCards();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                {
                    ShowError(
                        "This product has order history and cannot be deleted. Mark it unavailable instead.");
                }
                else
                {
                    ShowError(
                        "The product could not be deleted due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                ShowError("The product could not be deleted.");
            }
        }

        private void ShowEditProductError(string message)
        {
            ShowError(message);
            ReopenEditProductModal();
        }

        private void ReopenEditProductModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenEditProductModal",
                "AppModal.open('editProductModal');",
                true);
        }

        #endregion

        #region Variant Creation via Modal

        protected void btnSaveModalVariant_Click(object sender, EventArgs e)
        {

            if (!Page.IsValid)
            {
                ReopenAddVariantModal();
                return;
            }

            int productID;
            if (!int.TryParse(hfModalProductID.Value, out productID) || productID <= 0)
            {
                ShowAddVariantError("Invalid product selected for adding variant.");
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
                        ShowAddVariantError("Choose a valid size or serving.");
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
                    ShowAddVariantError(
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
                ShowAddVariantError(
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
                    ShowAddVariantError(
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
                    ShowAddVariantError(
                        "One or more selected sizes already exist for this product.");
                }
                else
                {
                    ShowAddVariantError("The variant could not be saved due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                DeleteSavedImages(savedPhysicalPaths);
                ShowAddVariantError(ex.Message);
            }
            catch (Exception)
            {
                DeleteSavedImages(savedPhysicalPaths);
                ShowAddVariantError("An unexpected error occurred while saving the variant.");
            }
        }

        private void ShowAddVariantError(string message)
        {
            ShowError(message);
            ReopenAddVariantModal();
        }

        private void ReopenAddVariantModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenAddVariantModal",
                "AppModal.open('addVariantModal');",
                true);
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
            Page.Validate("EditVariantForm");

            if (!Page.IsValid)
            {
                ReopenEditVariantModal();
                return;
            }

            int productVariantID;
            if (!int.TryParse(
                    hfEditVariantID.Value,
                    out productVariantID) ||
                productVariantID <= 0)
            {
                ShowEditVariantError("The selected variant is invalid.");
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
                    ShowEditVariantError("Choose a valid size or serving.");
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
                ShowEditVariantError("Enter a valid non-negative price.");
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
                ShowEditVariantError(
                    "The variant could not be loaded for editing.");
                return;
            }

            if (existingVariant == null)
            {
                ShowEditVariantError("The variant no longer exists.");
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
                ShowEditVariantError(uploadError);
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
                    ShowEditVariantError("The variant no longer exists.");
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
                    ShowEditVariantError(
                        "That size already exists for this product.");
                }
                else
                {
                    ShowEditVariantError(
                        "The variant could not be updated due to a database error.");
                }
            }
            catch (ArgumentException ex)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowEditVariantError(ex.Message);
            }
            catch (Exception)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowEditVariantError(
                    "An unexpected error occurred while updating the variant.");
            }
        }

        private void ShowEditVariantError(string message)
        {
            ShowError(message);
            ReopenEditVariantModal();
        }

        private void ReopenEditVariantModal()
        {
            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "ReopenEditVariantModal",
                "AppModal.open('editVariantModal');",
                true);
        }

        protected void btnDeleteVariant_Click(
            object sender,
            EventArgs e)
        {

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
                ddlEditProductCategory.Items.Clear();
                ddlEditProductCategory.Items.Add(new ListItem("-- Select category --", ""));

                foreach (Category cat in categories)
                {
                    ddlCategory.Items.Add(new ListItem(cat.CategoryName, cat.CategoryID.ToString()));
                    ddlEditProductCategory.Items.Add(new ListItem(cat.CategoryName, cat.CategoryID.ToString()));
                }
            }
            catch (Exception)
            {
                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new ListItem("Categories unavailable", ""));
                ddlEditProductCategory.Items.Clear();
                ddlEditProductCategory.Items.Add(new ListItem("Categories unavailable", ""));
                ddlCategory.Enabled = false;
                ddlEditProductCategory.Enabled = false;
                btnAddProduct.Enabled = false;
                btnUpdateProduct.Enabled = false;
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
                        variant.ProductIsAvailable = p.IsAvailable;
                        existingSizeKeys.Add(
                            variant.SizeID.HasValue
                                ? variant.SizeID.Value.ToString()
                                : "NONE");
                    }

                    vm.ExistingSizeKeys =
                        string.Join(",", existingSizeKeys);

                    cardViewModels.Add(vm);
                }

                Dictionary<int, ProductCategoryGroupViewModel> groupsByCategory =
                    new Dictionary<int, ProductCategoryGroupViewModel>();
                List<ProductCategoryGroupViewModel> categoryGroups =
                    new List<ProductCategoryGroupViewModel>();

                foreach (ProductCardViewModel card in cardViewModels)
                {
                    ProductCategoryGroupViewModel group;
                    if (!groupsByCategory.TryGetValue(card.CategoryID, out group))
                    {
                        group = new ProductCategoryGroupViewModel
                        {
                            CategoryID = card.CategoryID,
                            CategoryName = card.CategoryName
                        };

                        groupsByCategory.Add(card.CategoryID, group);
                        categoryGroups.Add(group);
                    }

                    group.Products.Add(card);
                }

                categoryGroups.Sort((left, right) =>
                    StringComparer.CurrentCultureIgnoreCase.Compare(
                        left.CategoryName,
                        right.CategoryName));

                rptCategoryGroups.DataSource = categoryGroups;
                rptCategoryGroups.DataBind();

                pnlNoProducts.Visible = cardViewModels.Count == 0;
            }
            catch (Exception)
            {
                rptCategoryGroups.DataSource = null;
                rptCategoryGroups.DataBind();
                ShowError("Products and variants could not be loaded.");
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
            ((AdminLayout)Master).ShowSuccessAlert(message);
        }

        private void ShowError(string message)
        {
            ((AdminLayout)Master).ShowErrorAlert(message);
        }

        #endregion
    }
}
